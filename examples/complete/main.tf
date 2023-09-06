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

locals {
  prefix = "test-dev"
}

module "dev_instance" {
  source = "../.."

  vpc_id            = var.vpc_id
  subnet_names      = var.subnet_names
  availability_zone = var.availability_zone
  naming_prefix     = var.naming_prefix

  user_list                 = var.user_list
  region                    = var.region
  environment               = var.environment
  ami_instance_type         = var.ami_instance_type
  root_volume_size          = var.root_volume_size
  iam_instance_profile_name = var.iam_instance_profile_name
  git_server_host           = var.git_server_host

  security_group = var.security_group

  tags = var.tags
}
