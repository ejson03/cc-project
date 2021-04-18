resource "random_id" "random" {
  byte_length = 2
}

resource "aws_s3_bucket" "test_bucket" {
    bucket = "${var.bucket_name}-${random_id.random.dec}"
    acl = "private"

    versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    transition {
      storage_class = "STANDARD_IA"
      days          = 30
    }
  }

  tags = {
    Name = "my-bucket"
  }

}
