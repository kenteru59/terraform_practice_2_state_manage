provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-20250309"

  # 謝ってのバケット削除を防止する
  lifecycle {
    prevent_destroy = true
  }

}

# S3バケットのバージョニングを有効にする
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3バケットの暗号化を有効にする（現在はデフォ機能だが、明示的に有効にする）
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 明示的にパブリックアクセスを禁止する
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#statelock用のDynamoDBテーブルを作成する
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# TerraformのstateファイルをS3に保存する
terraform {
  backend "s3" {
    key            = "global/s3/terraform.tfstate"
  }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "S3バケットのARNさ！"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DyonamoDBテーブルの名前さ！"
}