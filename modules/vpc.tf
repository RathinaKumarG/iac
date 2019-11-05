resource "aws_vpc" "eks-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.app}-${var.env}-vpc"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = "${aws_vpc.eks-vpc.id}"
  cidr_block              = "${var.pub_subnet_1}"
  availability_zone       = "${var.region}a"
  tags = {
    Name        = "${var.app}-${var.env}-public-subnet-1"
    Environment = "${var.env}"
  }
}
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = "${aws_vpc.eks-vpc.id}"
  cidr_block              = "${var.pub_subnet_2}"
  availability_zone       = "${var.region}b"
  tags = {
    Name        = "${var.app}-${var.env}-public-subnet-2"
    Environment = "${var.env}"
  }
}
resource "aws_subnet" "public-subnet-3" {
  vpc_id                  = "${aws_vpc.eks-vpc.id}"
  cidr_block              = "${var.pub_subnet_3}"
  availability_zone       = "${var.region}c"
  tags = {
    Name        = "${var.app}-${var.env}-public-subnet-3"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = "${aws_vpc.eks-vpc.id}"
  cidr_block              = "${var.priv_subnet_1}"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.app}-${var.env}-private-subnet-1"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = "${aws_vpc.eks-vpc.id}"
  cidr_block              = "${var.priv_subnet_2}"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.app}-${var.env}-private-subnet-2"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "private-subnet-3" {
  vpc_id                  = "${aws_vpc.eks-vpc.id}"
  cidr_block              = "${var.priv_subnet_3}"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.app}-${var.env}-private-subnet-3"
    Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "route-1" {
  route_table_id   = "${aws_route_table.rtb_public.id}"
  subnet_id        = "${aws_subnet.public-subnet-1.id}"
}

resource "aws_route_table_association" "route-2" {
  route_table_id   = "${aws_route_table.rtb_public.id}"
  subnet_id        = "${aws_subnet.public-subnet-2.id}"
}

resource "aws_route_table_association" "route-3" {
  route_table_id   = "${aws_route_table.rtb_public.id}"
  subnet_id        = "${aws_subnet.public-subnet-3.id}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.eks-vpc.id}"
  tags   = {
  Name   = "${var.app}-${var.env}-ig"
  Environment = "${var.env}"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.eks-vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags   = {
  Name   = "${var.app}-${var.env}-rtb-public"
  Environment = "${var.env}"
  }
}

resource "aws_main_route_table_association" "main-rt" {
  vpc_id         = "${aws_vpc.eks-vpc.id}"
  route_table_id = "${aws_route_table.rtb_public.id}"
}

resource "aws_eip" "nat-eip" {
vpc      = true
  tags   = {
  Name   = "${var.app}-${var.env}-nat-eip"
  Environment = "${var.env}"
  }
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = "${aws_subnet.public-subnet-1.id}"
  allocation_id = "${aws_eip.nat-eip.id}"
  tags   = {
  Name   = "${var.app}-${var.env}-ngw"
  Environment = "${var.env}"
  }

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "rtb_private" {
  vpc_id = "${aws_vpc.eks-vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.ngw.id}"
  }
  tags   = {
  Name   = "${var.app}-${var.env}-rtb-private"
  Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "private-route-1" {
  route_table_id   = "${aws_route_table.rtb_private.id}"
  subnet_id        = "${aws_subnet.private-subnet-1.id}"
}

resource "aws_route_table_association" "private-route-2" {
  route_table_id   = "${aws_route_table.rtb_private.id}"
  subnet_id        = "${aws_subnet.private-subnet-2.id}"
}

resource "aws_route_table_association" "private-route-3" {
  route_table_id   = "${aws_route_table.rtb_private.id}"
  subnet_id        = "${aws_subnet.private-subnet-3.id}"
}

output "vpc_id" {
value = "${aws_vpc.eks-vpc.id}"
}

output "public-subnet-1" {
value = "${aws_subnet.public-subnet-1.id}"
}

output "public-subnet-2" {
value = "${aws_subnet.public-subnet-2.id}"
}

output "public-subnet-3" {
value = "${aws_subnet.public-subnet-3.id}"
}

output "private-subnet-1" {
value = "${aws_subnet.private-subnet-1.id}"
}

output "private-subnet-2" {
value = "${aws_subnet.private-subnet-2.id}"
}

output "private-subnet-3" {
value = "${aws_subnet.private-subnet-3.id}"
}




