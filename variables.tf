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

variable "ami_id" {
  type        = string
  description = "Optional supply a specific AMI ID"
  default     = null
}

variable "ami_instance_type" {
  description = "instance type (ex: t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "ami_names" {
  type        = list(string)
  description = "Name to filter for the ami"
  default     = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

variable "ami_owners" {
  type        = list(string)
  description = "Owner to filter for the ami"
  default     = ["099720109477"] # Canonical
}

variable "ami_virt_types" {
  type        = list(string)
  description = "Virtualization type to filter for the ami"
  default     = ["hvm"]
}

variable "availability_zone" {
  description = "availability zones for the instance"
  type        = string
  default     = "us-east-2a"
}

variable "efs_backup_policy_enabled" {
  type        = bool
  description = "EFS backup enabled?"
  default     = true
}

variable "efs_lifecycle_policy" {
  type        = map(string)
  description = "EFS lifecycle policy (map)"
  default = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
}

variable "efs_performance_mode" {
  type        = string
  description = "EFS performance mode"
  default     = "generalPurpose"
}

variable "efs_policy_statements" {
  type = list(object(
    {
      sid     = string
      effect  = string
      actions = list(string)
      principals = list(object(
        {
          type        = string
          identifiers = list(string)
        }
      ))
      conditions = list(object(
        {
          test     = string
          variable = string
          values   = list(bool)
        }
      ))
    }
  ))
  description = "EFS access policy"
  default = [
    {
      sid    = "RestrictToAccessPoints"
      effect = "Allow"
      actions = [
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientMount"
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
      conditions = [
        {
          test     = "Bool"
          variable = "elasticfilesystem:AccessedViaMountTarget"
          values   = [true]
        }
      ]
    }
  ]
}

variable "efs_security_group_description" {
  type        = string
  description = "Name for EFS security group"
  default     = "Dev-Server EFS security group"
}

variable "efs_throughput_mode" {
  type        = string
  description = "EFS throughput mode"
  default     = "elastic"
}

variable "efs_volume_uid" {
  type        = number
  default     = 1000
  description = "UID for ownership of files in EFS volume access point"
}

variable "efs_volume_gid" {
  type        = number
  default     = 1000
  description = "GID for ownership of files in EFS volume access point"
}

variable "efs_volume_basepath" {
  type        = string
  description = "base path for access points in efs volume"
  default     = "/developers"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "git_server_host" {
  type        = string
  description = "name of the git server to put into the .netrc template"
  default     = "github.com"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM profile name to use for instances"
  default     = ""
}

variable "kms_key_arn" {
  type        = string
  description = "ARN for the KMS key used for encryption"
  default     = null
}

variable "naming_prefix" {
  description = "Prefix for the provisioned resources."
  type        = string
  default     = "devsrvr"
}

variable "region" {
  description = "AWS Region in which the infra needs to be provisioned"
  type        = string
  default     = "us-east-2"
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-module-resource_name to generate resource names"
  type = map(object(
    {
      name       = string
      max_length = optional(number, 60)
    }
  ))
  default = {
    ec2_instance = {
      name = "devsrvr"
    }
    ec2_sg = {
      name = "devsg"
    }
    efs_fs = {
      name = "devefsfs"
    }
  }
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "root_volume_size" {
  description = "Size of the instance root volume in GiB"
  type        = number
  default     = 20
}

variable "security_group" {
  description = "Default security group to be attached"
  type = object({
    ingress_rules            = optional(list(string))
    ingress_cidr_blocks      = optional(list(string))
    ingress_with_cidr_blocks = optional(list(map(string)))
    egress_rules             = optional(list(string))
    egress_cidr_blocks       = optional(list(string))
    egress_with_cidr_blocks  = optional(list(map(string)))
  })

  default = null
}

variable "security_group_description" {
  description = "name given to security group"
  type        = string
  default     = "Security Group for Dev Servers"
}

variable "subnet_names" {
  description = "names of subnets to find for placement"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of custom tags to be attached to this resource"
  type        = map(string)
  default     = {}
}

variable "user_list" {
  description = "A map of user names and ssh public keys"
  type = list(object(
    {
      username        = string
      public_key_file = optional(string)
      public_key      = string
    }
  ))
  default = []
}

variable "vpc_id" {
  description = "VPC ID to put this instance in"
  type        = string
  default     = ""
}
