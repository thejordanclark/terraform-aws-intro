locals {
  application_buckets = {
    uploads = {
      acl        = "private"
      versioning = true
    },
    media = {
      acl        = "private"
      versioning = false
    },
    feeds = {
      acl        = "private"
      versioning = true
    }
  }
}

resource "aws_s3_bucket" "lab_bucket" {
  for_each = local.application_buckets

  bucket_prefix = "terraform-labs-${each.key}-"
}

resource "aws_s3_bucket_ownership_controls" "lab_bucket" {
  for_each = local.application_buckets

  bucket = aws_s3_bucket.lab_bucket[each.key].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lab_bucket" {
  for_each = local.application_buckets

  bucket = aws_s3_bucket.lab_bucket[each.key].id
  acl    = each.value.acl
  depends_on = [ aws_s3_bucket_ownership_controls.lab_bucket ]
}

resource "aws_s3_bucket_versioning" "lab_bucket" {
  for_each = local.application_buckets

  bucket = aws_s3_bucket.lab_bucket[each.key].id

  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket" "archive" {
  count = local.archiving_enabled ? 1 : 0

  bucket_prefix = "terraform-labs-archives-"
}

resource "aws_s3_bucket_ownership_controls" "archive" {
  count = local.archiving_enabled ? 1 : 0

  bucket = aws_s3_bucket.archive[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "archive" {
  count = local.archiving_enabled ? 1 : 0

  bucket = element(aws_s3_bucket.archive.*.id, 0)
  acl    = "private"
  depends_on = [ aws_s3_bucket_ownership_controls.archive ]
}
