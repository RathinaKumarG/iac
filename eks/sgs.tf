data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.app}-${var.vpcenv}-vpc"
  }
}

data "aws_security_group" "jenkins-sg" {
  tags = {
    Name = "${var.app}-${var.vpcenv}-jenkins-sg"
  }
}

resource "aws_security_group" "albapi-sg" {
  name        = "${var.app}-${var.env}-albapi-sg"
  description = "EKS albapi security group"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  tags = {
    Name = "${var.app}-${var.env}-albapi-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "albui-sg" {
  name        = "${var.app}-${var.env}-albui-sg"
  description = "EKS albapi security group"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  tags = {
    Name = "${var.app}-${var.env}-albui-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "eksmaster-sg" {
  name        = "${var.app}-${var.env}-eksmaster-sg"
  description = "EKS master security group"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  tags = {
    Name = "${var.app}-${var.env}-eksmaster-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "eksworker-sg" {
  name        = "${var.app}-${var.env}-eksworker-sg"
  description = "EKS worker security group"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  tags = {
    Name = "${var.app}-${var.env}-eksworker-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "data-sg" {
  name        = "${var.app}-${var.env}-data-sg"
  description = "EKS data security group"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  tags = {
    Name = "${var.app}-${var.env}-data-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group_rule" "albapi-sg_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.albapi-sg.id}"
}

resource "aws_security_group_rule" "albapi-sg_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.albapi-sg.id}"
}

resource "aws_security_group_rule" "albui-sg_ingress_aspire_ip" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["103.5.78.10/32","103.66.221.10/32","182.156.252.230/32","61.12.35.115/32"]
  security_group_id = "${aws_security_group.albui-sg.id}"
  description = "Aspire IP"
}

resource "aws_security_group_rule" "albui-sg_ingress_pearson_ip" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["12.124.244.202/32","159.182.1.4/32"]
  security_group_id = "${aws_security_group.albui-sg.id}"
  description = "Pearson IP"
}

resource "aws_security_group_rule" "albui-sg_ingress_aspire_ip_80" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["103.5.78.10/32","103.66.221.10/32","182.156.252.230/32","61.12.35.115/32"]
  security_group_id = "${aws_security_group.albui-sg.id}"
  description = "Aspire IP"
}

resource "aws_security_group_rule" "albui-sg_ingress_pearson_ip_80" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["12.124.244.202/32","159.182.1.4/32"]
  security_group_id = "${aws_security_group.albui-sg.id}"
  description = "Pearson IP"
}

resource "aws_security_group_rule" "albapi-sg_ingress_aspire_ip" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["103.5.78.10/32","103.66.221.10/32","182.156.252.230/32","61.12.35.115/32"]
  security_group_id = "${aws_security_group.albapi-sg.id}"
  description = "Aspire IP"
}

resource "aws_security_group_rule" "albapi-sg_ingress_pearson_ip" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["12.124.244.202/32","159.182.1.4/32"]
  security_group_id = "${aws_security_group.albapi-sg.id}"
  description = "Pearson IP"
}

resource "aws_security_group_rule" "albapi-sg_ingress_aspire_ip_80" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["103.5.78.10/32","103.66.221.10/32","182.156.252.230/32","61.12.35.115/32"]
  security_group_id = "${aws_security_group.albapi-sg.id}"
  description = "Aspire IP"
}

resource "aws_security_group_rule" "albapi-sg_ingress_pearson_ip_80" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["12.124.244.202/32","159.182.1.4/32"]
  security_group_id = "${aws_security_group.albapi-sg.id}"
  description = "Pearson IP"
}


resource "aws_security_group_rule" "albui-sg_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.albui-sg.id}"
}

resource "aws_security_group_rule" "eksworker-sg_ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  source_security_group_id = "${aws_security_group.eksworker-sg.id}"
  security_group_id = "${aws_security_group.eksworker-sg.id}"
}

resource "aws_security_group_rule" "eksworker-sg_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.eksworker-sg.id}"
}

resource "aws_security_group_rule" "eksworker-sg_ingress_2" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.eksmaster-sg.id}"
  security_group_id = "${aws_security_group.eksworker-sg.id}"
}

resource "aws_security_group_rule" "eksworker-sg_ingress_3" {
  type        = "ingress"
  from_port   = 1025
  to_port     = 65535
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.eksmaster-sg.id}"
  security_group_id = "${aws_security_group.eksworker-sg.id}"
}

resource "aws_security_group_rule" "eksworker-sg_ingress_4" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = "${data.aws_security_group.jenkins-sg.id}"
  security_group_id = "${aws_security_group.eksworker-sg.id}"
}

resource "aws_security_group_rule" "eksworker-sg_ingress_0_65535_api" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.albapi-sg.id}"
  security_group_id = "${aws_security_group.eksworker-sg.id}"
}

resource "aws_security_group_rule" "eksworker-sg_ingress_0_65535_ui" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.albui-sg.id}"
  security_group_id = "${aws_security_group.eksworker-sg.id}"
}

# *** Completed eksworker-sg rules ***

# *** Strting eksmaster-sg rules ***

resource "aws_security_group_rule" "eksmaster-sg_ingress_443" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.eksworker-sg.id}"
  security_group_id = "${aws_security_group.eksmaster-sg.id}"
}

resource "aws_security_group_rule" "eksmaster-sg_egress_1025_to_65535" {
  type        = "egress"
  from_port   = 1025
  to_port     = 65535
  protocol    = "tcp"
  source_security_group_id = "${data.aws_security_group.jenkins-sg.id}"
  security_group_id = "${aws_security_group.eksmaster-sg.id}"
}

resource "aws_security_group_rule" "eksmaster-sg_ingress_443_2" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  source_security_group_id = "${data.aws_security_group.jenkins-sg.id}"
  security_group_id = "${aws_security_group.eksmaster-sg.id}"
}

resource "aws_security_group_rule" "eksmaster-sg_egress_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  source_security_group_id = "${aws_security_group.eksworker-sg.id}"
  security_group_id = "${aws_security_group.eksmaster-sg.id}"
}


# *** Completed eksmaster-sg rules ***

# *** Starting data-sg rules ***

resource "aws_security_group_rule" "data-sg_ingress_5432" {
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.eksworker-sg.id}"
  security_group_id = "${aws_security_group.data-sg.id}"
}

resource "aws_security_group_rule" "data-sg_ingress_27015" {
  type        = "ingress"
  from_port   = 27015
  to_port     = 27017
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.eksworker-sg.id}"
  security_group_id = "${aws_security_group.data-sg.id}"
}


# *** Completed data-sg rules ***

# *** Started bastion-sg rules ***

resource "aws_security_group_rule" "jenkins-sg_egress_443" {
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.eksmaster-sg.id}"
  security_group_id = "${data.aws_security_group.jenkins-sg.id}"
}

resource "aws_security_group_rule" "jenkins-sg_egress_22" {
  type        = "egress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = "${aws_security_group.eksworker-sg.id}"
  security_group_id = "${data.aws_security_group.jenkins-sg.id}"
}
