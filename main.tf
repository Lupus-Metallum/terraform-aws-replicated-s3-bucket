provider "aws" {
  alias = "us_east_1"
}

provider "aws" {
  alias = "us_east_2"
}


data "aws_caller_identity" "current" {}

resource "aws_iam_role" "replication" {
  name = "s3-bucket-replication-${var.bucket_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "s3-bucket-replication-${var.bucket_name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.bucket_name}"
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.bucket_name}-replica/*"
    },
    {
        "Action": ["kms:Decrypt"],
        "Effect": "Allow",
        "Condition": {
            "StringLike": {
                "kms:ViaService": "s3.${var.origin_region}.amazonaws.com",
                "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::${var.bucket_name}/*"
            }
        },
        "Resource": "${var.kms_key}"
    },
    {
        "Action": ["kms:Encrypt"],
        "Effect": "Allow",
        "Condition": {
            "StringLike": {
                "kms:ViaService": "s3.${var.replica_region}.amazonaws.com",
                "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::${var.bucket_name}-replica/*"
            }
        },
        "Resource": "${var.replica_kms_key}"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "s3-bucket-replication-${var.bucket_name}"
  roles      = [aws_iam_role.replication.name]
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket" "this_replica" {
  provider = aws.us_east_2

  bucket = "${var.bucket_name}-replica"
  acl    = var.bucket_acl

  versioning {
    enabled    = var.enable_versioning
    mfa_delete = false
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.encrypt_with_kms ? [1] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = var.replica_kms_key
        }
      }
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.encrypt_with_kms ? [] : [1]
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name       = "${var.bucket_name}-replica",
      Replicated = true,
      Origin     = false
    },
  )
}

resource "aws_s3_bucket_policy" "this_replica" {
  provider = aws.us_east_2

  bucket = aws_s3_bucket.this_replica.id
  policy = jsonencode({
    "Id" : "AllowSSLRequestsOnly",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowSSLRequestsOnly",
        "Action" : "s3:*",
        "Effect" : "Deny",
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}-replica",
          "arn:aws:s3:::${var.bucket_name}-replica/*"
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

  depends_on = [
    aws_s3_bucket.this_replica
  ]
}

resource "aws_s3_bucket_public_access_block" "this_replica" {
  provider = aws.us_east_2

  bucket = aws_s3_bucket.this_replica.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  depends_on = [
    aws_s3_bucket.this_replica,
    aws_s3_bucket_policy.this_replica
  ]
}

resource "aws_s3_bucket" "this" {
  provider = aws.us_east_1
  bucket   = var.bucket_name
  acl      = var.bucket_acl

  versioning {
    enabled    = var.enable_versioning
    mfa_delete = false
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.encrypt_with_kms ? [1] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = var.kms_key
        }
      }
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.encrypt_with_kms ? [] : [1]
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  dynamic "logging" {
    for_each = var.logging_enabled ? [1] : []
    content {
      target_bucket = var.logging_bucket
      target_prefix = var.logging_prefix
    }
  }

  tags = merge(
    var.tags,
    {
      Name       = var.bucket_name,
      Replicated = true,
      Origin     = true
    },
  )

  replication_configuration {
    role = aws_iam_role.replication.arn

    rules {
      status   = "Enabled"
      id       = "main"
      priority = 2

      prefix = ""

      destination {
        bucket             = "arn:aws:s3:::${var.bucket_name}-replica"
        storage_class      = "STANDARD"
        replica_kms_key_id = var.replica_kms_key
      }

      filter {}

      source_selection_criteria {
        sse_kms_encrypted_objects {
          enabled = true
        }
      }
    }
  }

  depends_on = [
    aws_s3_bucket.this_replica,
    aws_s3_bucket_policy.this_replica,
    aws_s3_bucket_public_access_block.this_replica,
    aws_iam_role.replication,
    aws_iam_policy.replication,
    aws_iam_policy_attachment.replication
  ]
}

resource "aws_s3_bucket_policy" "this" {
  provider = aws.us_east_1
  bucket   = aws_s3_bucket.this.id

  policy = var.bucket_policy_json

  depends_on = [
    aws_s3_bucket.this
  ]
}

resource "aws_s3_bucket_public_access_block" "this" {
  provider = aws.us_east_1
  bucket   = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_policy.this
  ]
}