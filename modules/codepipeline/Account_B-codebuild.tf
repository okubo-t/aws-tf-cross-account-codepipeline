resource "aws_codebuild_project" "Account_B" {
  provider      = aws.Account_B
  name          = "${var.prefix}-${var.Account_B["env"]}-project"
  build_timeout = "60"
  service_role  = aws_iam_role.Account_B_codebuild.arn

  artifacts {
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.Account_B.account_id
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.Account_B["env"]
    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
    buildspec       = file("./modules/codepipeline/buildspec.yml")
  }
}
