resource "aws_iam_role" "eks-node-role" {
  name = "${var.app}-${var.env}-eks-node-role"

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

resource "aws_iam_policy" "eks-node-autoscale-policy" {
  name        = "${var.app}-${var.env}-eks-node-autoscale-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
  
resource "aws_iam_role_policy_attachment" "policy-attachment" {
  role       = "${aws_iam_role.eks-node-role.name}"
  policy_arn = "${aws_iam_policy.eks-node-autoscale-policy.arn}"
}

resource "aws_iam_policy" "eks-node-alb-policy" {
  name        = "${var.app}-${var.env}-eks-node-alb-policy"
  policy      = "${file("policy.json")}"
}

resource "aws_iam_role_policy_attachment" "policy-attach-2" {
  role       = "${aws_iam_role.eks-node-role.name}"
  policy_arn = "${aws_iam_policy.eks-node-alb-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-node-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-node-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-node-role.name}"
}


resource "aws_iam_instance_profile" "eks-instance-profile" {
  name = "${var.app}-${var.env}-profile"
  role = "${aws_iam_role.eks-node-role.name}"
}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-cluster.certificate_authority.0.data}' '${var.app}-${var.env}-eks'
USERDATA
}

resource "aws_launch_configuration" "eks-lc" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.eks-instance-profile.name}"
  image_id                    = "${var.NodeAMI}"
  instance_type               = "${var.NodeInstanceType}"
  security_groups             = ["${aws_security_group.eksworker-sg.id}"]
  user_data_base64            = "${base64encode(local.node-userdata)}"
  key_name                    = "${var.KeyPair}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks-asg" {
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.eks-lc.id}"
  max_size             = 3
  min_size             = 1
  name                 = "${var.app}-${var.env}-eks-autoscale"
  vpc_zone_identifier  = ["${data.aws_subnet.private-subnet-1.id}", "${data.aws_subnet.private-subnet-2.id}", "${data.aws_subnet.private-subnet-3.id}"]

tag {
    key                 = "Name"
    value               = "${var.app}-${var.env}-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.app}-${var.env}-eks"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.env}"
    propagate_at_launch = true
  }
}

resource "null_resource" "private_subnet_tags" {
  provisioner "local-exec" {
    command = "aws --region ${var.region} ec2 create-tags --resources ${data.aws_subnet.private-subnet-1.id} ${data.aws_subnet.private-subnet-2.id} ${data.aws_subnet.private-subnet-3.id} --tags Key=kubernetes.io/role/internal-elb,Value=1"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region ${var.region} ec2 delete-tags --resources ${data.aws_subnet.private-subnet-1.id} ${data.aws_subnet.private-subnet-2.id} ${data.aws_subnet.private-subnet-3.id} --tags Key=kubernetes.io/role/internal-elb,Value=1"
  }
}

resource "null_resource" "public_subnet_tags" {
  provisioner "local-exec" {
    command = "aws --region ${var.region} ec2 create-tags --resources ${data.aws_subnet.public-subnet-1.id} ${data.aws_subnet.public-subnet-2.id} ${data.aws_subnet.public-subnet-3.id} --tags Key=kubernetes.io/role/elb,Value=1"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region ${var.region} ec2 delete-tags --resources ${data.aws_subnet.public-subnet-1.id} ${data.aws_subnet.public-subnet-2.id} ${data.aws_subnet.public-subnet-3.id} --tags Key=kubernetes.io/role/elb,Value=1"
  }
}
