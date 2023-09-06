// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnet" "subnet" {
  filter {
    name   = "tag:Name"
    values = var.subnet_names
  }
  vpc_id = data.aws_vpc.vpc.id
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ami_names
  }

  filter {
    name   = "virtualization-type"
    values = var.ami_virt_types
  }

  owners = var.ami_owners
}

data "aws_availability_zones" "available" {}

data "aws_iam_instance_profile" "iam_instance_profile" {
  count = var.iam_instance_profile_name == "" ? 0 : 1

  name = var.iam_instance_profile_name
}

module "security_group_dev_servers" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.17"

  vpc_id                   = var.vpc_id
  name                     = module.resource_names["ec2_sg"].standard
  description              = var.security_group_description
  ingress_cidr_blocks      = coalesce(try(lookup(var.security_group, "ingress_cidr_blocks", []), []), [])
  ingress_rules            = coalesce(try(lookup(var.security_group, "ingress_rules", []), []), [])
  ingress_with_cidr_blocks = coalesce(try(lookup(var.security_group, "ingress_with_cidr_blocks", []), []), [])
  egress_cidr_blocks       = coalesce(try(lookup(var.security_group, "egress_cidr_blocks", []), []), [])
  egress_rules             = coalesce(try(lookup(var.security_group, "egress_rules", []), []), [])
  egress_with_cidr_blocks  = coalesce(try(lookup(var.security_group, "egress_with_cidr_blocks", []), []), [])

  tags = merge(var.tags, { resource_name = module.resource_names["ec2_sg"].standard })
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.2"

  # File system
  name           = module.resource_names["efs_fs"].standard
  creation_token = module.resource_names["efs_fs"].standard
  encrypted      = true
  # kms_key_arn    = module.kms.key_arn

  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode

  lifecycle_policy = var.efs_lifecycle_policy

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false
  policy_statements                  = var.efs_policy_statements

  # Mount targets / security group
  mount_targets              = { for k, v in zipmap([local.azs[0]], [data.aws_subnet.subnet.id]) : k => { subnet_id = v } }
  security_group_description = var.efs_security_group_description
  security_group_vpc_id      = data.aws_vpc.vpc.id
  security_group_rules = {
    vpc = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      # cidr_blocks = data.aws_vpc.vpc.cidr
      cidr_blocks = [data.aws_subnet.subnet.cidr_block]
    }
  }

  # Backup policy
  enable_backup_policy = var.efs_backup_policy_enabled

  # Replication configuration - results in:
  # creating EFS Replication Configuration (fs-07f2...): AccessDeniedException: User is not authorized to perform that action on the specified resource
  # so setting to false
  create_replication_configuration = false
  # replication_configuration_destination = {
  #   region = "us-west-2"
  # }

  tags = local.tags
}


# This module generates the resource-name of resources based on resource_type, naming_prefix, env etc.
module "resource_names" {
  source = "github.com/nexient-llc/tf-module-resource_name.git?ref=0.2.0"

  for_each = var.resource_names_map

  logical_product_name = var.naming_prefix
  region               = join("", split("-", var.region))
  class_env            = var.environment
  cloud_resource_type  = each.value.name
  instance_env         = var.environment_number
  instance_resource    = var.resource_number
  maximum_length       = each.value.max_length
}


module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  count = length(var.user_list)

  key_name   = "${module.resource_names["ec2_instance"].standard}-${var.user_list[count.index].username}"
  public_key = var.user_list[count.index].public_key
  tags       = var.tags
}

resource "aws_efs_access_point" "efs_ap" {
  count = length(var.user_list)

  file_system_id = module.efs.id

  root_directory {
    creation_info {
      owner_gid   = var.efs_volume_gid
      owner_uid   = var.efs_volume_uid
      permissions = "0750"
    }
    path = "${var.efs_volume_basepath}/${var.user_list[count.index].username}"
  }

  posix_user {
    gid = var.efs_volume_gid
    uid = var.efs_volume_uid
  }

  tags = merge(local.tags, { resource_name = module.resource_names["ec2_instance"].standard, Name = module.resource_names["ec2_instance"].standard })
}

resource "aws_instance" "instance" {
  count = length(var.user_list)

  ami                         = data.aws_ami.ami.id
  instance_type               = var.ami_instance_type
  associate_public_ip_address = false
  availability_zone           = var.availability_zone
  subnet_id                   = data.aws_subnet.subnet.id
  key_name                    = module.key_pair[count.index].key_pair_name
  vpc_security_group_ids      = [module.security_group_dev_servers.security_group_id]

  iam_instance_profile = var.iam_instance_profile_name == "" ? null : data.aws_iam_instance_profile.iam_instance_profile[0].name

  user_data = base64encode(templatefile("${path.module}/files/user_data.tftpl", {
    uname   = var.user_list[count.index].username,
    fs      = module.efs.id,
    fsap    = aws_efs_access_point.efs_ap[count.index].id,
    githost = var.git_server_host
    }
  ))
  # set to false so we don't destroy existing instances if we update the user data template
  user_data_replace_on_change = false

  root_block_device {
    volume_size = var.root_volume_size
  }

  tags = merge(local.tags, {
    resource_name = "${module.resource_names["ec2_instance"].standard}-${var.user_list[count.index].username}",
    Name          = "${module.resource_names["ec2_instance"].standard}-${var.user_list[count.index].username}"
  })
}
