# tf-aws-wrapper_module-remote_dev_instance

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This module creates a set of EC2 instances which each mount a user directory from a shared EFS volume.  Users are created from a list of user names and SSH public keys defined in the `user_list` variable; one instance is created for each user name.  The instances are intended for use in a hybrid local/cloud development environment, moving the IDE (IntelliJ IDEA or Visual Studio Code) and docker container runtime to the remote instance so that the local machine is not overloaded.  The connection between local and remote is done via SSH (required by IntelliJ and VSCode).  Instances do not receive a public IP address and connections are restricted to the CIDR blocks defined by the `ingress_cidr_blocks` list in the `security_groups` variable.  Connection to that may require a VPN is the CIDR block is part of that VPN.  Connection can also be accomplished via AWS SSM sessions using the `AWS-StartPortForwardingSession` document.

User data is stored in a shared EFS volume where each user's data is mounted in their instance under `/projects` and linked to from the `ubuntu` user's home directory as `~/projects`.  This data is retained even if their instance is deleted (by remiving their entry from the `user_lsit` variable).  If a user with the same name is added later, the data will be available at the mount point (provided the entire stack has not been `terraform destroy`ed.)

For details on setup, see [REMOTE-DEVELOPMENT.md](REMOTE-DEVELOPMENT.md)

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `azure_env.sh` file on local workstation. Devloper would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Service principle used for authentication(value of ARM_CLIENT_ID) should have below privileges on resource group within the subscription.

```
"Microsoft.Resources/subscriptions/resourceGroups/write"
"Microsoft.Resources/subscriptions/resourceGroups/read"
"Microsoft.Resources/subscriptions/resourceGroups/delete"
```

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `azure` specific. If primitive/segment under development uses any other cloud provider than azure, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "azurerm" {
  features {}
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.16.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_security_group_dev_servers"></a> [security\_group\_dev\_servers](#module\_security\_group\_dev\_servers) | terraform-aws-modules/security-group/aws | ~> 4.17 |
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | ~> 1.2 |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | github.com/nexient-llc/tf-module-resource_name.git | 0.2.0 |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.efs_ap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_instance.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_instance_profile.iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) | data source |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Optional supply a specific AMI ID | `string` | `null` | no |
| <a name="input_ami_instance_type"></a> [ami\_instance\_type](#input\_ami\_instance\_type) | instance type (ex: t2.micro) | `string` | `"t2.micro"` | no |
| <a name="input_ami_names"></a> [ami\_names](#input\_ami\_names) | Name to filter for the ami | `list(string)` | <pre>[<br>  "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"<br>]</pre> | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | Owner to filter for the ami | `list(string)` | <pre>[<br>  "099720109477"<br>]</pre> | no |
| <a name="input_ami_virt_types"></a> [ami\_virt\_types](#input\_ami\_virt\_types) | Virtualization type to filter for the ami | `list(string)` | <pre>[<br>  "hvm"<br>]</pre> | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | availability zones for the instance | `string` | `"us-east-2a"` | no |
| <a name="input_efs_backup_policy_enabled"></a> [efs\_backup\_policy\_enabled](#input\_efs\_backup\_policy\_enabled) | EFS backup enabled? | `bool` | `true` | no |
| <a name="input_efs_lifecycle_policy"></a> [efs\_lifecycle\_policy](#input\_efs\_lifecycle\_policy) | EFS lifecycle policy (map) | `map(string)` | <pre>{<br>  "transition_to_ia": "AFTER_30_DAYS",<br>  "transition_to_primary_storage_class": "AFTER_1_ACCESS"<br>}</pre> | no |
| <a name="input_efs_performance_mode"></a> [efs\_performance\_mode](#input\_efs\_performance\_mode) | EFS performance mode | `string` | `"generalPurpose"` | no |
| <a name="input_efs_policy_statements"></a> [efs\_policy\_statements](#input\_efs\_policy\_statements) | EFS access policy | <pre>list(object(<br>    {<br>      sid     = string<br>      effect  = string<br>      actions = list(string)<br>      principals = list(object(<br>        {<br>          type        = string<br>          identifiers = list(string)<br>        }<br>      ))<br>      conditions = list(object(<br>        {<br>          test     = string<br>          variable = string<br>          values   = list(bool)<br>        }<br>      ))<br>    }<br>  ))</pre> | <pre>[<br>  {<br>    "actions": [<br>      "elasticfilesystem:ClientWrite",<br>      "elasticfilesystem:ClientMount"<br>    ],<br>    "conditions": [<br>      {<br>        "test": "Bool",<br>        "values": [<br>          true<br>        ],<br>        "variable": "elasticfilesystem:AccessedViaMountTarget"<br>      }<br>    ],<br>    "effect": "Allow",<br>    "principals": [<br>      {<br>        "identifiers": [<br>          "*"<br>        ],<br>        "type": "AWS"<br>      }<br>    ],<br>    "sid": "RestrictToAccessPoints"<br>  }<br>]</pre> | no |
| <a name="input_efs_security_group_description"></a> [efs\_security\_group\_description](#input\_efs\_security\_group\_description) | Name for EFS security group | `string` | `"Dev-Server EFS security group"` | no |
| <a name="input_efs_throughput_mode"></a> [efs\_throughput\_mode](#input\_efs\_throughput\_mode) | EFS throughput mode | `string` | `"elastic"` | no |
| <a name="input_efs_volume_uid"></a> [efs\_volume\_uid](#input\_efs\_volume\_uid) | UID for ownership of files in EFS volume access point | `number` | `1000` | no |
| <a name="input_efs_volume_gid"></a> [efs\_volume\_gid](#input\_efs\_volume\_gid) | GID for ownership of files in EFS volume access point | `number` | `1000` | no |
| <a name="input_efs_volume_basepath"></a> [efs\_volume\_basepath](#input\_efs\_volume\_basepath) | base path for access points in efs volume | `string` | `"/developers"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_git_server_host"></a> [git\_server\_host](#input\_git\_server\_host) | name of the git server to put into the .netrc template | `string` | `"github.com"` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | IAM profile name to use for instances | `string` | `""` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN for the KMS key used for encryption | `string` | `null` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for the provisioned resources. | `string` | `"devsrvr"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"us-east-2"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-module-resource\_name to generate resource names | <pre>map(object(<br>    {<br>      name       = string<br>      max_length = optional(number, 60)<br>    }<br>  ))</pre> | <pre>{<br>  "ec2_instance": {<br>    "name": "devsrvr"<br>  },<br>  "ec2_sg": {<br>    "name": "devsg"<br>  },<br>  "efs_fs": {<br>    "name": "devefsfs"<br>  }<br>}</pre> | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Size of the instance root volume in GiB | `number` | `20` | no |
| <a name="input_security_group"></a> [security\_group](#input\_security\_group) | Default security group to be attached | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | name given to security group | `string` | `"Security Group for Dev Servers"` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | names of subnets to find for placement | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be attached to this resource | `map(string)` | `{}` | no |
| <a name="input_user_list"></a> [user\_list](#input\_user\_list) | A map of user names and ssh public keys | <pre>list(object(<br>    {<br>      username        = string<br>      public_key_file = optional(string)<br>      public_key      = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to put this instance in | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_ip"></a> [instance\_ip](#output\_instance\_ip) | n/a |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
