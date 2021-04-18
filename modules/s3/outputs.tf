output "bucket_name" {
  value = aws_s3_bucket.test_bucket.bucket
}

output "domain_name" {
  value = aws_s3_bucket.test_bucket.bucket_regional_domain_name
}