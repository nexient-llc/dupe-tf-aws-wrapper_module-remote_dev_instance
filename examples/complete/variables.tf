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


variable "ami_instance_type" {
  type    = string
  default = "t3a.xlarge"
}

variable "availability_zone" {
  description = "availability zones for the instance"
  type        = string
  default     = "us-east-1a"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  default     = "000"
}

variable "git_server_host" {
  type        = string
  description = "name of the git server to put into the .netrc template"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM profile name to use for instances"
  default     = ""
}

variable "naming_prefix" {
  description = "Prefix for the provisioned resources."
  type        = string
  default     = "devsrvr"
}

variable "region" {
  description = "AWS Region in which the infra needs to be provisioned"
  default     = "us-east-2"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  default     = "000"
}

variable "root_volume_size" {
  description = "Size of the root volume in GiB"
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

variable "subnet_names" {
  description = "list of subnet names for the instance"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of custom tags to be attached to this resource"
  type        = map(string)
  default     = {}
}

variable "user_list" {
  description = "list of map with username and public_key_file"
  type        = list(map(string))
  default     = []
}

variable "vpc_id" {
  description = "VPC ID to put this instance in"
  type        = string
  default     = ""
}
