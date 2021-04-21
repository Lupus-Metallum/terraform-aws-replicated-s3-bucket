# terraform-aws-replicated-s3-bucket

## Example usage

``` Terraform
module "s3_replicated_bucket" {
  source = "./modules/core_s3"
  providers = {
    aws.us_east_1 = aws.us_east_1
    aws.us_east_2 = aws.us_east_2
  }


  bucket_name             = "example"
  enable_versioning       = true
  encrypt_with_kms        = true
  kms_key                 = var.default_s3_kms_key
  replica_kms_key         = aws_kms_key.s3_replica_key.arn
  bucket_acl              = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  origin_region           = "us-east-1"
  replica_region          = "us-east-2"
  bucket_policy_json = jsonencode({
    "Id" : "ExamplePolicy",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowSSLRequestsOnly",
        "Action" : "s3:*",
        "Effect" : "Deny",
        "Resource" : [
          "arn:aws:s3:::example",
          "arn:aws:s3:::example/*"
        ],
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        },
        "Principal" : "*"
      }
    ]
  })
  tags = var.default_tags
}
```