# Remote Development (via SSH)

## Notes:

* `dev-ide-servers` -> name of the terragrunt repo that uses this module
* `env/dir` -> directory for the target environment within `dev-ide-servers`
* `PROJECTPREFIX` -> derived prefix name for this project's resources
* `AWSPROFILE` -> AWS profile name for the environment

## User Add and Delete - Admin function

Create the remote instance.  You will need each user's git user ID and ssh public key.

```
# checkout the dev-ide-servers and cd into it
cd env/dir/000
export AWS_PROFILE=AWSPROFILE
aws sso login --profile ${AWS_PROFILE} # or other authenication
# Edit inputs.yaml to add/delete users and their public keys
terragrunt apply
```

Note the IP address for the users to add.

## User Setup

Using the IP address returned by the above (referred to below as `REMOTE_IP_ADDRESS`), connect to that address from the IntelliJ IDE:

1. Create a new SSH project:
    1. Username is `ubuntu`
    1. Host is `REMOTE_IP_ADDRESS`
    1. You might need to point the IDE at your private key.  It uses the windows location by default.
    1. Click OK on accepting the remote host authenticity.
    1. Click "open an SSH terminal"

1. Edit `~/.netrc`.  Update the `login` and `password` fields to match your remote git ID and an HTTP_ACCESS_TOKEN from bitbucket or a token from github.  Save the file.
1. execute the following:

    ```
    cd ~/projects
    git clone REMOTE_URL
    cd REMOTE_PROJECT_NAME
    cut -d' ' -f1 .tool-versions | xargs -I{} asdf plugin add {}
    asdf install
    make configure
    make platform/devenv/configure
    zsh
    make aws_configure_sso
    ```
1. Click `...` and select the project you just cloned from `/home/ubuntu/projects/REMOTE_PROJECT_NAME`
1. Ensure the correct IDE is selected
1. Click Download and Connect IDE
1. Allow connections in Windows Defender popups
1. Install the `Makefile` plugin into IntelliJ from the marketplace (both host and client)
1. Set IntelliJ to use Compose V2:
    1. Settings
    1. Build, Execution, Deployment
    1. Docker
    1. Tools (Host)
    1. Select "Use Compose V2"
    1. Click OK

## Start of Workday

1. Connect to the VPN if needed.

1. Start the remote VM in AWS, which requires that you be authenticated to AWS on the `AWSPROFILE` account:

    ```
    export AWS_PROFILE=awsprofile
    aws sso login --profile ${AWS_PROFILE}
    # Optional (if no VPN)
    aws ssm start-session --target $(aws ec2 describe-instances --profile AWSPROFILE --filters "Name=tag:Name,Values=PROJECTPREFIX-devsrvr-000-sdowd" | jq -r '.Reservations[] | .Instances[] | .InstanceId') --document-name AWS-StartPortForwardingSession --parameters '{"portNumber": ["22"], "localPortNumber": ["2222"]}'
    ```

1. Control-click the link (or copy/paste) into a browser, authenticate and authorize the connection.

1. Next, start your remote instance:

    ```
    aws ec2 start-instances --profile AWSPROFILE --instance-ids $(aws ec2 describe-instances --profile AWSPROFILE --filters "Name=tag:Name,Values=PROJECTPREFIX-devsrvr-000-${USER}" "Name=instance-state-name,Values=stopped" | jq -r '.Reservations[] | .Instances[] | .InstanceId')
    # Optional (if no VPN)
    aws ssm start-session --target $(aws ec2 describe-instances --profile AWSPROFILE --filters "Name=tag:Name,Values=PROJECTPREFIX-devsrvr-000-sdowd" | jq -r '.Reservations[] | .Instances[] | .InstanceId') --document-name AWS-StartPortForwardingSession --parameters '{"portNumber": ["22"], "localPortNumber": ["2222"]}'
    ```

    Note: if this command fails, try replacing `"${USER}"` with `flast` (as in `jsmith`).

1. You can now start your IDEA workbench.  Inside the workbench, open a new terminal and execute:

    ```
    make aws_refresh
    ```
1. Setup a port forward for port 8080 (optional, you can also directly access http://REMOTE_IP_ADDRESS:8080):

    ```
    ssh -L localhost:8080:REMOTE_IP_ADDRESS:8080 ubuntu@REMOTE_IP_ADDRESS
    ```


## End of Workday

Ensure you stop your instance at the end of your workday to avoid excess AWS charges.

You need to be authenticated.  If you are not, repeat the authentication steps above.

1. First stop your IDEA workbench and stop the remote process as well (Close and Stop).

2. Then stop your instance:

    ```
    aws ec2 stop-instances --profile AWSPROFILE --instance-ids $(aws ec2 describe-instances --profile AWSPROFILE --filters "Name=tag:Name,Values=PROJECTPREFIX-devsrvr-000-${USER}" "Name=instance-state-name,Values=running" | jq -r '.Reservations[] | .Instances[] | .InstanceId')
    ```

    Note: if this command fails, try replacing `"${USER}"` with `flast` (as in `jsmith`).
