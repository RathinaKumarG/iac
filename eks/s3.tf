resource "aws_s3_bucket" "helm-bucket" {
  bucket = "${var.app}-${var.env}-helm"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = "${aws_s3_bucket.helm-bucket.id}"
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
