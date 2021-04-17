resource "aws_s3_bucket" "image-bucket" {
    bucket = "devops-cloud-image-101"
    acl = "public-read"
}

resource "aws_s3_bucket_object" "image-upload" {
  bucket = aws_s3_bucket.image-bucket.bucket
  key = "img.png"
  source = "img/image.png"
  acl = "public-read"
}