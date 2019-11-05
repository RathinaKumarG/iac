resource "aws_security_group" "bastion-sg" {
  name        = "${var.app}-${var.env}-bastion-sg"
  description = "EKS bastion security group"
  vpc_id      = "${aws_vpc.eks-vpc.id}"
  tags = {
    Name = "${var.app}-${var.env}-bastion-sg"
    Environment = "${var.env}"
  }
}




resource "aws_instance" "bastion-instance" {
  ami           = "${var.bastion_ami}"
  instance_type = "${var.bastion_size}"
  key_name      = "${var.KeyPair}"
  vpc_security_group_ids = ["${aws_security_group.bastion-sg.id}"]
  subnet_id     = "${aws_subnet.public-subnet-1.id}"
  associate_public_ip_address = true
  tags = {
    Name = "${var.app}-${var.env}-bastion"
    Environment = "${var.env}"
  }
}
output "bastion-sg" {
value = "${aws_security_group.bastion-sg.id}"
}

output "bastion-ip" {
value = "${aws_instance.bastion-instance.public_ip}"
}
