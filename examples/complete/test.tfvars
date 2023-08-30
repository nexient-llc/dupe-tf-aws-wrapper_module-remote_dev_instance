naming_prefix      = "test"
resource_number    = "000"
region             = "us-east-1"
environment        = "dev"
environment_number = "000"

vpc_id            = "vpc-0b1e120c29021ea0f"
subnet_names      = ["-private-us-east-1b"]
availability_zone = "us-east-1b"

# override with smaller instance type to test EFS mount.  need larger to actually run.
ami_instance_type = "t3.micro"

user_list = [
  {
    username   = "test1",
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMR9ItIVXkkapl941pP/95l+6R0hk580HZW9ZxkHrEPqkzl3uDpC//LYelY9eSSUmBiLAYOYY84UMgwH4/8L43tkD4QWGH1v72iTvtY+mlliafoCSaDEyfSHyr9sUbXrkfn4X9CZXr3pWxickojYsHu5BgZFIpnXSYYtrTJXCxBSFfmb3bQmhUnbUBgQfmhjQoGeGLDFJIDzyEIXfhCxhZ5VE1Du+WhHZ4NC7cyUweYX5q1G4fWuZcLUyIkRBqVDP78lf02YiECFmeSU+I31cQ+/MgnUHTQW1Ks04Nqt2/nNXL8RW7R2YRsApmf9++Oh4pfZtASUFbF7xrTNbeuxW5evPZ5/8mVlYs921e3qR8PCwFAxgx7NH6K5CG+gQFvV96ekNro3gLbuZHUNszw+SVvw3beM9JTi6y8Tzyucn4O1vzXxk78muVXrKNjeqm++4j3+Qr3yQKV3RJ9Rh15URiNn8oOwCspble4WPovIwuZendQFo2RlxsrzF0te8eH3M= someone@example.com"
  },
  {
    username   = "test2",
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMR9ItIVXkkapl941pP/95l+6R0hk580HZW9ZxkHrEPqkzl3uDpC//LYelY9eSSUmBiLAYOYY84UMgwH4/8L43tkD4QWGH1v72iTvtY+mlliafoCSaDEyfSHyr9sUbXrkfn4X9CZXr3pWxickojYsHu5BgZFIpnXSYYtrTJXCxBSFfmb3bQmhUnbUBgQfmhjQoGeGLDFJIDzyEIXfhCxhZ5VE1Du+WhHZ4NC7cyUweYX5q1G4fWuZcLUyIkRBqVDP78lf02YiECFmeSU+I31cQ+/MgnUHTQW1Ks04Nqt2/nNXL8RW7R2YRsApmf9++Oh4pfZtASUFbF7xrTNbeuxW5evPZ5/8mVlYs921e3qR8PCwFAxgx7NH6K5CG+gQFvV96ekNro3gLbuZHUNszw+SVvw3beM9JTi6y8Tzyucn4O1vzXxk78muVXrKNjeqm++4j3+Qr3yQKV3RJ9Rh15URiNn8oOwCspble4WPovIwuZendQFo2RlxsrzF0te8eH3M= someone@example.com"
  }
]

security_group = {

  ingress_with_cidr_blocks = [
    {
      "from_port" = "22"
      "to_port"   = "22"
      "protocol"  = "tcp"
    },
    {
      "from_port" = "8080"
      "to_port"   = "8080"
      "protocol"  = "tcp"
    },
    {
      "from_port" = "8787"
      "to_port"   = "8787"
      "protocol"  = "tcp"
    },
  ]
  ingress_cidr_blocks = ["192.168.0.1/32"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_with_cidr_blocks = [
    {
      "from_port" = "443"
      "to_port"   = "443"
      "protocol"  = "tcp"
    },
    {
      "from_port" = "80"
      "to_port"   = "80"
      "protocol"  = "tcp"
    },
    {
      "from_port" = "2049"
      "to_port"   = "2049"
      "protocol"  = "tcp"
    },
    {
      "from_port" = "7999"
      "to_port"   = "7999"
      "protocol"  = "tcp"
    }
  ]
}

git_server_host = "github.com"

tags = {
  "env" : "terratest",
  "provisioner" : "Terraform"
  "usage" : "remote-development"
}
