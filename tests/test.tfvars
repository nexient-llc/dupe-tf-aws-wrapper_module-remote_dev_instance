
vpc_id        = "vpc-090b01d6a4af719d6"
naming_prefix = "test"
tags = {
  "env" : "terratest",
  "provisioner" : "Terraform"
  "usage" : "remote-development"
}
# override with smaller instance type to tgest EFS mount.  need larger to actually run.
ami_instance_type = "t3.micro"

# subnet_names = ["main-private-us-east-2a", "main-private-us-east-2b", "main-private-us-east-2"]
subnet_names = ["main-private-us-east-2a"]

user_list = [{ username = "test1", public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMR9ItIVXkkapl941pP/95l+6R0hk580HZW9ZxkHrEPqkzl3uDpC//LYelY9eSSUmBiLAYOYY84UMgwH4/8L43tkD4QWGH1v72iTvtY+mlliafoCSaDEyfSHyr9sUbXrkfn4X9CZXr3pWxickojYsHu5BgZFIpnXSYYtrTJXCxBSFfmb3bQmhUnbUBgQfmhjQoGeGLDFJIDzyEIXfhCxhZ5VE1Du+WhHZ4NC7cyUweYX5q1G4fWuZcLUyIkRBqVDP78lf02YiECFmeSU+I31cQ+/MgnUHTQW1Ks04Nqt2/nNXL8RW7R2YRsApmf9++Oh4pfZtASUFbF7xrTNbeuxW5evPZ5/8mVlYs921e3qR8PCwFAxgx7NH6K5CG+gQFvV96ekNro3gLbuZHUNszw+SVvw3beM9JTi6y8Tzyucn4O1vzXxk78muVXrKNjeqm++4j3+Qr3yQKV3RJ9Rh15URiNn8oOwCspble4WPovIwuZendQFo2RlxsrzF0te8eH3M= someone@example.com" }]
