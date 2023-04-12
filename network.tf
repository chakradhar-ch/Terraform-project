# Creating Internet-Gateway

resource "aws_internet_gateway" "card-webapp-IG" {
  vpc_id = aws_vpc.card-webapp-vpc.id

  tags = {
    Name = "Card-Webapp-IG"
  }
}

# Creating Route-Table

resource "aws_route_table" "card-webapp-RT" {
  vpc_id = aws_vpc.card-webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.card-webapp-IG.id
  }

  tags = {
    Name = "Card-Webapp-RT"
  }
}

resource "aws_route_table_association" "card-webapp-RT-asso-1a" {
  subnet_id      = aws_subnet.card-webapp-subnet-1a.id
  route_table_id = aws_route_table.card-webapp-RT.id
}

resource "aws_route_table_association" "card-webapp-RT-asso-2a" {
  subnet_id      = aws_subnet.card-webapp-subnet-2a.id
  route_table_id = aws_route_table.card-webapp-RT.id
}

# Creating Security Groups

resource "aws_security_group" "allow-SSH" {
  name        = "allow-SSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.card-webapp-vpc.id

  ingress {
    description      = "tcp from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow-SSH"
  }
}