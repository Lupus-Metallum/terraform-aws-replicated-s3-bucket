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
<!-- BEGIN_TF_DOCS -->

<img src="https://raw.githubusercontent.com/Lupus-Metallum/brand/master/images/logo.jpg" width="400"/>



## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | n/a |
| <a name="provider_aws.us_east_2"></a> [aws.us\_east\_2](#provider\_aws.us\_east\_2) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.this_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.this_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.this_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_acl"></a> [bucket\_acl](#input\_bucket\_acl) | KMS key to use for bucket encryption | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_bucket_policy_json"></a> [bucket\_policy\_json](#input\_bucket\_policy\_json) | KMS key to use for bucket encryption | `string` | n/a | yes |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Should versioning be enabled on the bucket | `string` | n/a | yes |
| <a name="input_encrypt_with_kms"></a> [encrypt\_with\_kms](#input\_encrypt\_with\_kms) | Should we use a KMS CMK? If false we will use SSE AES256 | `string` | n/a | yes |
| <a name="input_origin_region"></a> [origin\_region](#input\_origin\_region) | The Name of the Origin region | `string` | n/a | yes |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | The Name of the Origin region | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map to pass in tags to the resources | `map(string)` | n/a | yes |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | KMS key to use for bucket encryption | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | KMS key to use for bucket encryption | `bool` | `true` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | KMS key to use for bucket encryption | `bool` | `true` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS key to use for bucket encryption | `string` | `""` | no |
| <a name="input_logging_bucket"></a> [logging\_bucket](#input\_logging\_bucket) | What bucket should we target for logging? | `string` | `""` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Should we enable logging dynamic block? | `bool` | `false` | no |
| <a name="input_logging_prefix"></a> [logging\_prefix](#input\_logging\_prefix) | What prefix key should we use for logging? | `string` | `""` | no |
| <a name="input_replica_kms_key"></a> [replica\_kms\_key](#input\_replica\_kms\_key) | KMS key to use for bucket encryption at destiniation | `string` | `""` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | KMS key to use for bucket encryption | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_replica_arn"></a> [replica\_arn](#output\_replica\_arn) | n/a |
| <a name="output_replica_domain_name"></a> [replica\_domain\_name](#output\_replica\_domain\_name) | n/a |
| <a name="output_replica_id"></a> [replica\_id](#output\_replica\_id) | n/a |
<!-- END_TF_DOCS -->