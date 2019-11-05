module "vpc" {
  source = "../modules"
  env    = "${var.env}"
  region = "${var.region}"
  app    = "${var.app}"
  vpc_cidr = "${var.vpc_cidr}"
  pub_subnet_1 = "${var.pub_subnet_1}"
  pub_subnet_2 = "${var.pub_subnet_2}"
  pub_subnet_3 = "${var.pub_subnet_3}"
  priv_subnet_1 = "${var.priv_subnet_1}"
  priv_subnet_2 = "${var.priv_subnet_2}"
  priv_subnet_3 = "${var.priv_subnet_3}"
  bastion_ami   = "${var.bastion_ami}"
  bastion_size = "${var.bastion_size}"
  KeyPair      = "${var.KeyPair}" 
}

resource "aws_security_group_rule" "bastion-sg_ingress_22" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = "${module.vpc.bastion-sg}"
  security_group_id = "${module.vpc.bastion-sg}"
}

resource "aws_security_group_rule" "bastion-sg_ingress_pearson_ip" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.network_ip}"]
  security_group_id = "${module.vpc.bastion-sg}"
  description = "Network IP"
}


resource "aws_security_group_rule" "bastion-sg_egress_any" {
  type= "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${module.vpc.bastion-sg}"
}

resource "aws_security_group" "jenkins-sg" {
  name        = "${var.app}-${var.env}-jenkins-sg"
  description = "EKS Jenkins security group"
  vpc_id      = "${module.vpc.vpc_id}"
  
  tags = {
    Name = "${var.app}-${var.env}-jenkins-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group_rule" "jenkins-sg_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  source_security_group_id = "${module.vpc.bastion-sg}"
  security_group_id = "${aws_security_group.jenkins-sg.id}"
}

resource "aws_security_group_rule" "jenkins-sg_egress_443" {
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-sg.id}"
}

resource "aws_security_group_rule" "jenkins-sg_egress_80" {
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-sg.id}"
}

resource "aws_security_group_rule" "jenkins-sg_ingress_443" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${var.network_ip}"]
  security_group_id = "${aws_security_group.jenkins-sg.id}"
}

resource "aws_security_group_rule" "jenkins-sg_ingress_80" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["${var.network_ip}"]
  security_group_id = "${aws_security_group.jenkins-sg.id}"
}

resource "aws_iam_role" "jenkins-role" {
  name = "${var.app}-${var.env}-jenkins-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "jenkins-policy" {
  name        = "${var.app}-${var.env}-jenkins-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:*",
        "iam:*",
        "ec2:*",
        "s3:*",
        "logs:*",
        "ecr:*",
        "autoscaling:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = "${aws_iam_role.jenkins-role.name}"
  policy_arn = "${aws_iam_policy.jenkins-policy.arn}"
}

resource "aws_iam_instance_profile" "jenkins-instance-profile" {
  name = "${var.app}-${var.env}-jenkins-profile"
  role = "${aws_iam_role.jenkins-role.name}"
}

resource "aws_instance" "jenkins-instance" {
  ami           = "${var.bastion_ami}"
  instance_type = "${var.bastion_size}"
  key_name      = "${var.KeyPair}"
  vpc_security_group_ids = ["${aws_security_group.jenkins-sg.id}"]
  subnet_id     = "${module.vpc.private-subnet-1}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins-instance-profile.name}"
#  associate_public_ip_address = true
  tags = {
    Name = "${var.app}-${var.env}-jenkins-master"
    Environment = "${var.env}"
  }
}

resource "aws_s3_bucket" "jenkins-alblogs-bucket" {
bucket = "${var.app}-${var.env}-jenkins-alblogs"
force_destroy = true
policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::127311923021:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.app}-${var.env}-jenkins-alblogs/*"
    }
  ]
}
EOF
}

resource "aws_lb" "jenkins-alb" {
  name               = "${var.app}-${var.env}-jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.jenkins-alb-sg.id}"]
  subnets            = ["${module.vpc.private-subnet-1}", "${module.vpc.private-subnet-2}", "${module.vpc.private-subnet-3}"]

  access_logs {
    bucket  = "${aws_s3_bucket.jenkins-alblogs-bucket.bucket}"
    enabled = true
  }

  tags = {
    Name = "${var.app}-${var.env}-jenkins-alb"
    Environment = "${var.env}"
  }
}

resource "aws_lb_target_group" "jenkins-alb-tg" {
  name     = "${var.app}-${var.env}-jenkins-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_lb_target_group_attachment" "jenkins-alb-attachment" {
  target_group_arn = "${aws_lb_target_group.jenkins-alb-tg.arn}"
  target_id        = "${aws_instance.jenkins-instance.id}"
  port             = 80
}

resource "aws_security_group" "jenkins-alb-sg" {
  name        = "${var.app}-${var.env}-jenkins-alb-sg"
  description = "Jenkins ALB security group"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "${var.app}-${var.env}-jenkins-alb-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group_rule" "jenkins-alb-sg_ingress" {
  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.jenkins-alb-sg.id}"
}

output "jenkins-sg-id" {
value = "${aws_security_group.jenkins-sg.id}"
}

output "bastion-ip" {
value = "${module.vpc.bastion-ip}"
}


