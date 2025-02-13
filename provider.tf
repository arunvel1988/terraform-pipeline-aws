/*
provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}

*/

provider "aws" {
  region = "ap-south-1" # Optional if you set it in the AWS CLI
}
