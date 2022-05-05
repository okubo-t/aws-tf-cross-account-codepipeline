#
# CloudWatch Events
#
resource "aws_iam_role" "Account_A_cloudwatch_events" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-event"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "events.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_A_cloudwatch_events_codepipeline" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-event-pipeline"
  role     = aws_iam_role.Account_A_cloudwatch_events.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codepipeline:StartPipelineExecution"
        ],
        Resource : [
          aws_codepipeline.Account_A.arn
        ],
        Effect : "Allow"
      }
    ]
  })
}

#
# CodePipeline
#
resource "aws_iam_role" "Account_A_codepipeline" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-pipeline"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "codepipeline.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_A_codepipeline" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-pipeline"
  role     = aws_iam_role.Account_A_codepipeline.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Resource : aws_iam_role.Account_A_codepipeline_codecommit.arn,
        Effect : "Allow"
      },
      {
        Action : "sts:AssumeRole",
        Resource : aws_iam_role.Account_A_codepipeline_codebuild.arn,
        Effect : "Allow"
      }
    ]
  })
}

#
# CodePipeline -> CodeCommit
#
resource "aws_iam_role" "Account_A_codepipeline_codecommit" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-pipeline-commit"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.Account_A_codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_A_repository" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-repository"
  role     = aws_iam_role.Account_A_codepipeline_codecommit.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive"
        ],
        Resource : aws_codecommit_repository.this.arn,
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_A_artifact_store" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-artifact-store"
  role     = aws_iam_role.Account_A_codepipeline_codecommit.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "s3:Get*",
          "s3:Put*",
        ],
        Resource : "${aws_s3_bucket.Account_A.arn}/*",
        Effect : "Allow"
      },
      {
        Action : [
          "s3:ListBucket",
        ],
        Resource : aws_s3_bucket.Account_A.arn,
        Effect : "Allow"
      },
      {
        Action : [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        Resource : aws_kms_key.Account_A.arn,
        Effect : "Allow"
      }
    ]
  })
}

#
# CodePipeline -> CodeBuild
#
resource "aws_iam_role" "Account_A_codepipeline_codebuild" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-pipeline-build"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.Account_A_codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_A_codebuild" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-build"
  role     = aws_iam_role.Account_A_codepipeline_codebuild.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild"
        ],
        Resource : aws_codebuild_project.Account_A.arn,
        Effect : "Allow"
      },
      {
        Action : [
          "logs:CreateLogGroup"
        ],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}

#
# CodeBuild
#
resource "aws_iam_role" "Account_A_codebuild" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-codebuild"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "codebuild.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_A_build" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-codebuild"
  role     = aws_iam_role.Account_A_codebuild.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}

#
# Account A Cloudwatch Event -> Account B EventBus
#
resource "aws_iam_role" "Account_A_to_B" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_B["env"]}-event"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "events.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_A_to_B" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_B["env"]}-eventbus"
  role     = aws_iam_role.Account_A_to_B.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "events:PutEvents"
        ],
        Resource : [
          "arn:aws:events:${var.Account_B["region"]}:${data.aws_caller_identity.Account_B.account_id}:event-bus/default"
        ]
      }
    ]
  })
}

#
# Account B CodePipeline -> Account A CodeCommit
#
resource "aws_iam_role" "Account_B_codepipeline_codecommit" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_B["env"]}-pipeline-commit"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.Account_B_codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_B_repository" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_B["env"]}-codecommit-repository"
  role     = aws_iam_role.Account_B_codepipeline_codecommit.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive"
        ],
        Resource : aws_codecommit_repository.this.arn,
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "Account_B_artifact_store" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_B["env"]}-artifact-store"
  role     = aws_iam_role.Account_B_codepipeline_codecommit.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "s3:Get*",
          "s3:Put*",
        ],
        Resource : "${aws_s3_bucket.Account_B.arn}/*",
        Effect : "Allow"
      },
      {
        Action : [
          "s3:ListBucket",
        ],
        Resource : aws_s3_bucket.Account_B.arn,
        Effect : "Allow"
      },
      {
        Action : [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        Resource : aws_kms_key.Account_B.arn,
        Effect : "Allow"
      }
    ]
  })
}
