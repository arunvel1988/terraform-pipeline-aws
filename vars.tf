variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "ap-south-1"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1  = "ami-13be557e"
    us-west-2  = "ami-06b94666"
    eu-west-1  = "ami-0d729a60"
    ap-south-1 = "ami-0c50b6f7dc3701ddd"
  }
}

