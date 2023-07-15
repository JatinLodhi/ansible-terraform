

# Create a key-pair

resource "aws_key_pair" "web-key" {
  key_name   = "web-key"
  public_key = file ("${path.module}/id-rsa.pub")
}


# Create an instance.

resource "aws_instance" "web" {
  ami           = "ami-0d13e3e640877b0b9"
  instance_type = "t2.micro"
  security_groups = [ "allow_ssh_http" ]
  key_name     = "web-key"
  
  tags = {
    Name = "Web-Page" 
  }
}


# Create a aws_security_group

resource "aws_security_group" "sg" {
  name        = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id      = "vpc-0a13748d218c925b8"


  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }



  tags = {
    Name = "allow_ssh_http"
  }

}





resource "null_resource" "nullremote1" {
### Stablished a connection.
provisioner "remote-exec" {
  
connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("${path.module}/id-rsa")
    host     = aws_instance.web.public_ip
  }

 
# To run a command on remote.

     inline = [
     "sudo yum install python -y ",
     
     ]
  }

provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${aws_instance.web.public_ip},' --private-key file(${path.module}/id-rsa) -e 'pub_key=file(${path.module}/id-rsa.pub'  ./ansible/web-configure.yml"
  }

}

 



