provider "aws" {
  alias   = "Account_A"
  profile = var.Account_A["profile"]
  region  = var.Account_A["region"]
}

data "aws_caller_identity" "Account_A" {
  provider = aws.Account_A
}

provider "aws" {
  alias   = "Account_B"
  profile = var.Account_B["profile"]
  region  = var.Account_B["region"]
}

data "aws_caller_identity" "Account_B" {
  provider = aws.Account_B
}
