variable "bucket_name" {
  description = "The Name of the S3 bucket"
  type        = string
}

variable "origin_region" {
  description = "The Name of the Origin region"
  type        = string
}

variable "replica_region" {
  description = "The Name of the Origin region"
  type        = string
}

variable "enable_versioning" {
  description = "Should versioning be enabled on the bucket"
  type        = string
}

variable "encrypt_with_kms" {
  description = "Should we use a KMS CMK? If false we will use SSE AES256"
  type        = string
}

variable "kms_key" {
  description = "KMS key to use for bucket encryption"
  type        = string
  default     = ""
}

variable "replica_kms_key" {
  description = "KMS key to use for bucket encryption at destiniation"
  type        = string
  default     = ""

}

variable "bucket_acl" {
  description = "KMS key to use for bucket encryption"
  type        = string
}

variable "block_public_acls" {
  description = "KMS key to use for bucket encryption"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "KMS key to use for bucket encryption"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "KMS key to use for bucket encryption"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "KMS key to use for bucket encryption"
  type        = bool
  default     = true
}

variable "bucket_policy_json" {
  description = "KMS key to use for bucket encryption"
  type        = string
}

variable "logging_enabled" {
  description = "Should we enable logging dynamic block?"
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "What bucket should we target for logging?"
  type        = string
  default     = ""
}

variable "logging_prefix" {
  description = "What prefix key should we use for logging?"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map to pass in tags to the resources"
  type        = map(string)
}
