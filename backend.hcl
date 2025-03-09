# backend.hcl
bucket = "terraform-up-and-running-state-20250309"
region = "ap-northeast-1"
dynamodb_table = "terraform-up-and-running-locks"
encrypt = true