locals {
    s3_origin_id = "S3-${module.s3.bucket_name}"
    domain_name = module.s3.domain_name
}
resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = local.domain_name
        origin_id = local.s3_origin_id
    }
    enabled = true
    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods  = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "allow-all"
    }

    restrictions {
        geo_restriction {
        restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    connection {
        type    = "ssh"
        user    = "ubuntu"
        host    = module.ec2.public_ip
        port    = 22
        private_key = tls_private_key.ec2_key.private_key_pem
    }

    # provisioner "remote-exec" {
    #     inline  = [
    #         "sudo su << EOF",
    #         "sed s#img/undraw_banner2.png#${self.domain_name}/${aws_s3_bucket_object.image-upload.key}#g /var/www/html/index.html",
    #         "EOF"
    #     ]
    # }
}