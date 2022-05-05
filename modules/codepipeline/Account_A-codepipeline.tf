resource "aws_codepipeline" "Account_A" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-pipeline"
  role_arn = aws_iam_role.Account_A_codepipeline.arn

  artifact_store {
    encryption_key {
      id   = aws_kms_key.Account_A.arn
      type = "KMS"
    }
    location = aws_s3_bucket.Account_A.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      provider = "CodeCommit"
      category = "Source"
      configuration = {
        BranchName           = var.Account_A["branch_name"]
        PollForSourceChanges = "false"
        RepositoryName       = aws_codecommit_repository.this.id
      }
      name             = aws_codecommit_repository.this.id
      owner            = "AWS"
      version          = "1"
      output_artifacts = ["source_output"]
      role_arn         = aws_iam_role.Account_A_codepipeline_codecommit.arn
    }
  }

  stage {
    name = "Build"
    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.Account_A.name
      }
      input_artifacts  = ["source_output"]
      name             = aws_codebuild_project.Account_A.name
      provider         = "CodeBuild"
      owner            = "AWS"
      version          = "1"
      role_arn         = aws_iam_role.Account_A_codepipeline_codebuild.arn
      output_artifacts = ["build_output"]
    }
  }
}
