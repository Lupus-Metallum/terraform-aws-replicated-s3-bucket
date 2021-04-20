output "id" {
  value = aws_s3_bucket.this.id
}

output "replica_id" {
  value = aws_s3_bucket.this_replica.id
}

output "domain_name" {
  value = aws_s3_bucket.this.bucket_domain_name
}

output "replica_domain_name" {
  value = aws_s3_bucket.this_replica.bucket_domain_name
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "replica_arn" {
  value = aws_s3_bucket.this_replica.arn
}