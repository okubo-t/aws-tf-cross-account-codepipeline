resource "aws_codepipeline" "Account_B" {
  provider = aws.Account_B
  name     = "${var.prefix}-${var.Account_B["env"]}-pipeline"
  role_arn = aws_iam_role.Account_B_codepipeline.arn

  artifact_store {
    encryption_key {
      id   = aws_kms_key.Account_B.arn
      type = "KMS"
    }
    location = aws_s3_bucket.Account_B.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      provider = "CodeCommit"
      category = "Source"
      configuration = {
        BranchName           = var.Account_B["branch_name"]
        PollForSourceChanges = "false"
        RepositoryName       = aws_codecommit_repository.this.id
      }
      name             = aws_codecommit_repository.this.id
      owner            = "AWS"
      version          = "1"
      output_artifacts = ["source_output"]
      role_arn         = aws_iam_role.Account_B_codepipeline_codecommit.arn
    }
  }

  stage {
    name = "Build"
    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.Account_B.name
      }
      input_artifacts  = ["source_output"]
      name             = aws_codebuild_project.Account_B.name
      provider         = "CodeBuild"
      owner            = "AWS"
      version          = "1"
      role_arn         = aws_iam_role.Account_B_codepipeline_codebuild.arn
      output_artifacts = ["build_output"]
    }
  }
}
