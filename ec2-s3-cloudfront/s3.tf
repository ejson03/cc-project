resource "aws_s3_bucket_object" "image-upload" {
  bucket = module.s3.bucket_name
  key = "img.png"
  source = "img/image.png"
  acl = "public-read"
}