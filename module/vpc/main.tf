#Creating a VPC with CIDR block 
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "main-vpc"
  }
}

#internet gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }

}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


#Creating public subnet in availability zone 1
resource "aws_subnet" "public_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_az1_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_az1"
    Environment = "dev"
  }
}
#Creating public subnet in az 2
resource "aws_subnet" "public_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_az2_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_az2"
    Environment = "dev"
  }
}


#Creating private subnet in az 1
resource "aws_subnet" "private_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_az1_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]


  tags = {
    Name = "private_subnet_az1"
  }
}

#Creating private subnet in az 2
resource "aws_subnet" "private_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_az2_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[1]

  tags = {
    Name = "private_subnet_az2"
  }
}

#Creating route table for public subnets 

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_az1_assoc" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_rt.id

}


resource "aws_route_table_association" "public_az2_assoc" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public_rt.id

}

#Creating elastic IP for NAT gateway

resource "aws_eip" "nat_eip" {                
    domain = "vpc"
    depends_on = [aws_internet_gateway.igw]
}

#Creating NAT gateway in public subnet az1
#NAT Gateway = ₹3000–₹4000/month if left running
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_az1.id

    tags = {
        Name = "main-nat-gw"
    }
}

#Creating route table for private subnets
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }

    tags = {
      Name = "private-rt"
    }
}

#Associating private subnets with private route table 

resource "aws_route_table_association" "private_az1_assoc" {
    subnet_id = aws_subnet.private_az1.id
    route_table_id = aws_route_table.private_rt.id  
}

resource "aws_route_table_association" "private_az2_assoc" {
    subnet_id = aws_subnet.private_az2.id
    route_table_id = aws_route_table.private_rt.id
  
}