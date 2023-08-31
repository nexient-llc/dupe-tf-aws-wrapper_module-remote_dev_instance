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

terraform {
  required_version = ">= 1.1.0"

  required_providers {

    # aws = "~> 5.10.0"
    # results in:
    # Warning: [Fixable] Legacy version constraint for provider "aws" in `required_providers` (terraform_required_providers)
    # on versions.tf line 17:
    # 17:     aws = "~> 5.10.0"
    # Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.4.0/docs/rules/terraform_required_providers.md

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10.0"
    }
  }
}
