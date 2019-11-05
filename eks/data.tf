data "aws_vpc" "selected" {
  tags = {
    Name = "${var.app}-${var.vpcenv}-vpc"
  }
}

data "aws_subnet" "private-subnet-1" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags = {
    Name = "${var.app}-${var.vpcenv}-private-subnet-1"
  }
}

data "aws_subnet" "private-subnet-2" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags = {
    Name = "${var.app}-${var.vpcenv}-private-subnet-2"
  }
}

data "aws_subnet" "private-subnet-3" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags = {
    Name = "${var.app}-${var.vpcenv}-private-subnet-3"
  }
}

data "aws_subnet" "public-subnet-1" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags = {
    Name = "${var.app}-${var.vpcenv}-public-subnet-1"
  }
}

data "aws_subnet" "public-subnet-2" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags = {
    Name = "${var.app}-${var.vpcenv}-public-subnet-2"
  }
}

data "aws_subnet" "public-subnet-3" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags = {
    Name = "${var.app}-${var.vpcenv}-public-subnet-3"
  }
}

data "aws_security_group" "bastion-sg" {
  tags = {
    Name = "${var.app}-${var.vpcenv}-bastion-sg"
  }
}
