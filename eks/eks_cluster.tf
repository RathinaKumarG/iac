resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.app}-${var.env}-eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-cluster-role.name}"
}

resource "aws_eks_cluster" "eks-cluster" {
  name            = "${var.app}-${var.env}-eks"
  role_arn        = "${aws_iam_role.eks-cluster-role.arn}"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_config {
    security_group_ids = ["${aws_security_group.eksmaster-sg.id}"]
    subnet_ids         = ["${data.aws_subnet.private-subnet-1.id}", "${data.aws_subnet.private-subnet-2.id}", "${data.aws_subnet.private-subnet-3.id}", "${data.aws_subnet.public-subnet-1.id}", "${data.aws_subnet.public-subnet-2.id}", "${data.aws_subnet.public-subnet-3.id}"]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
  ]
}
