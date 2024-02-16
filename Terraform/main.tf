# Define your provider, for example, AWS
provider "aws" {
  region = "us-east-1" # Set your AWS region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Define your VPC data source (assuming you already have a VPC)
data "aws_vpc" "existing_vpc" {
  id = "vpc-042d606255c381138" # Provide your existing VPC ID
}

# Define your subnet data source (assuming you already have a subnet in the existing VPC)
data "aws_subnet" "existing_subnet" {
  vpc_id = data.aws_vpc.existing_vpc.id
  id      = "subnet-07552c0c81f4bc194" # Provide your existing subnet ID
}

# Define your security group
resource "aws_security_group" "cicd-sg" {
  vpc_id = data.aws_vpc.existing_vpc.id

  # Define your security group rules as needed
  # Example inbound rule allowing SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh login purpose"
  }
  # Add other ingress rules as needed
}

# Create multiple EC2 instances with count
resource "aws_instance" "example_instance" {
  count         = length(var.instances)
  ami           = "ami-053b0d53c279acc90" # Set your desired AMI
  instance_type = "t2.medium"     # Set your desired instance type
  subnet_id     = data.aws_subnet.existing_subnet.id
  key_name      = "PROJECT" # Provide the name of your existing key pair
  user_data     = var.instances[count.index].user_data # Use different user data for each instance

  # Attach the security group to the instance
  security_groups = [aws_security_group.cicd-sg.name]

  # Name the instance
  tags = {
    Name = var.instances[count.index].name
  }
}