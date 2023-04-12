# Creating VPC

resource "aws_vpc" "card-webapp-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Card-Webapp"
  }
}

# Creating Subnets in AZ-1

resource "aws_subnet" "card-webapp-subnet-1a" {
  vpc_id     = aws_vpc.card-webapp-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Card-Webapp-Subnet-1A"
  }
}

resource "aws_subnet" "card-webapp-subnet-1b" {
  vpc_id     = aws_vpc.card-webapp-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  
  tags = {
    Name = "Card-Webapp-Subnet-1B"
  }
}

# Creating Subnets in AZ-2

resource "aws_subnet" "card-webapp-subnet-2a" {
  vpc_id     = aws_vpc.card-webapp-vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1b"
  
  tags = {
    Name = "Card-Webapp-Subnet-2A"
  }
}

resource "aws_subnet" "card-webapp-subnet-2b" {
  vpc_id     = aws_vpc.card-webapp-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  
  tags = {
    Name = "Card-Webapp-Subnet-2B"
  }
}

# Creating key-pair

resource "aws_key_pair" "card-webapp-keypair" {
  key_name   = "card-webapp-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoP8JGLeUMkkux021PquSSYh2Ox0lqtaRLr/t76voKyd8IZdh4KviJ3gYUo10kTCIcFR6aNOXcmXlBWB4TayHIirVimyp+PZtr6xFtNLBKFs5OoNk9Dn6YlJNnXHmteUKdD86/5GleEvzfAe4OepNmHxI7OyTTh4q+cELuhlE/nddA7bQHgVTJmAwyExdPhQf7aT5B/IsCaTxn48dS26hlvIqYyCO0y9+4m+LTMJJrLubSJEBYBeYR+Md4UtiML9WnGoWIweAyx8h2oBdZABRi7weCI/rBmy/ylXbQHOtzRCk0HvmRd53FqdPI7lSgCnttNpmWKBkZVhsJ/l+JXiruumAcEUcOTx12km8a9KNMQKKzUs7y4jjB3Tf6zifX1nVC9u2FYwHF6SZ1JNmu+MRu6W3FS9HHn7/KcmSBMbVzl5+FyfjwRKC74xZ3iR3YDL0uHwPJ2xi7wNBeEbv5n7FQBl50PjMTehFu3WvCZl7+O/6EIyRXRPzIb5tJqDuDNjc= user@chakra"
}


# Creating LB-TG

resource "aws_lb_target_group" "card-webapp-LB-TG" {
  name     = "card-webapp-LB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.card-webapp-vpc.id
}

# Creating LB-Listener

resource "aws_lb_listener" "card-webapp-LB-Listener" {
  load_balancer_arn = aws_lb.card-webapp-LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.card-webapp-LB-TG.arn
  }
}

# Creating Load Balancer

resource "aws_lb" "card-webapp-LB" {
  name               = "card-webapp-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow-SSH.id]
  subnets            = [aws_subnet.card-webapp-subnet-1a.id,aws_subnet.card-webapp-subnet-2a.id]

  tags = {
    Environment = "production"
  }
}

# Creating ASG

resource "aws_autoscaling_group" "card-webapp-ASG" {
  # availability_zones = ["ap-south-1a,ap-south-1b"]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.card-webapp-subnet-1a.id,aws_subnet.card-webapp-subnet-2a.id ]
  target_group_arns = [aws_lb_target_group.card-webapp-LB-TG.arn]

  launch_template {
    id      = aws_launch_template.card-webapp-launch-template.id
    version = "$Latest"
  }
}

# Creating Launch Template

resource "aws_launch_template" "card-webapp-launch-template" {
  name = "card-webapp-launch-template"
  image_id = var.instance_id
  instance_type = var.instance_type
  key_name = aws_key_pair.card-webapp-keypair.id
  vpc_security_group_ids = [aws_security_group.allow-SSH.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Card-Webapp"
    }
  }

  user_data = filebase64("example.sh")
}
