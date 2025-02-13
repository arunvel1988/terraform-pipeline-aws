###############################################################################################################
# basic ec2
###############################################################################################################
/*
resource "aws_instance" "example" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
}
*/
###############################################################################################################


###############################################################################################################
# basic ec2 with tag
###############################################################################################################
/*

resource "aws_instance" "webserver" {
  ami           = "ami-0c50b6f7dc3701ddd"
  instance_type = "t2.micro"

  tags = {
    Name = "webserver"
    Env  = "Dev"
  }
}
*/

###############################################################################################################

###############################################################################################################
# ec2 with key pair, sg, local-exec, remote-exec
###############################################################################################################
# Generate a new key pair and save the private key locally
resource "tls_private_key" "web_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "web_key" {
  key_name   = "webserver-key"
  public_key = tls_private_key.web_key.public_key_openssh
}

# Create a security group to allow SSH access
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows SSH from anywhere; restrict for better security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch the EC2 instance
resource "aws_instance" "webserver" {
  ami           = "ami-0c50b6f7dc3701ddd"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.web_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "webserver"
    Env  = "Dev"
  }

  # Save the private key to a local file
  provisioner "local-exec" {
    command = "echo '${tls_private_key.web_key.private_key_pem}' > webserver-key.pem && chmod 400 webserver-key.pem"
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
    connection {
      type        = "ssh"
      user        = "ec2-user"           # For Amazon Linux. Use "ubuntu" for Ubuntu AMIs.
      private_key = tls_private_key.web_key.private_key_pem
      host        = self.public_ip       # Use the public IP of the instance
  }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"  # For Amazon Linux. Use "ubuntu" for Ubuntu AMIs.
      private_key = tls_private_key.web_key.private_key_pem
      host        = self.public_ip
    }

    inline = [
      "sudo yum update -y",               # For Amazon Linux. Use "apt-get" for Ubuntu.
      "sudo yum install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo mv /tmp/index.html /usr/share/nginx/html/index.html",
      "sudo chown nginx:nginx /usr/share/nginx/html/index.html"
    ]
  }


}

###############################################################################################################



###############################################################################################################
# sg = dynamic
###############################################################################################################
/*
resource "aws_security_group" "web_sg_dynamic" {
  name_prefix = "web-sg-dynamic"

  dynamic "ingress" {
    for_each = [
      { from_port = 22, to_port = 22, protocol = "tcp", description = "SSH access" },
      { from_port = 80, to_port = 80, protocol = "tcp", description = "HTTP access" }
    ]

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]  # You can change this to a more secure IP range
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


*/
###############################################################################################################


