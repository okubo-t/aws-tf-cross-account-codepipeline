resource "aws_codecommit_repository" "this" {
  provider        = aws.Account_A
  repository_name = var.repository_name
}
