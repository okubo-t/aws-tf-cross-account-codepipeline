#
# CloudWatch Events
#
resource "aws_iam_role" "Account_B_cloudwatch_events" {
  provider = aws.Account_B
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

resource "aws_iam_role_policy" "Account_B_cloudwatch_events_codepipeline" {
  provider = aws.Account_B
  name     = "${var.prefix}-${var.Account_B["env"]}-event-pipeline"
  role     = aws_iam_role.Account_B_cloudwatch_events.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codepipeline:StartPipelineExecution"
        ],
        Resource : [
          aws_codepipeline.Account_B.arn
        ],
        Effect : "Allow"
      }
    ]
  })
}

#
# CodePipeline
#
resource "aws_iam_role" "Account_B_codepipeline" {
  provider = aws.Account_B
  name     = "${var.prefix}-${var.Account_B["env"]}-pipeline"
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

resource "aws_iam_role_policy" "Account_B_codepipeline" {
  provider = aws.Account_B
  name     = "${var.prefix}-${var.Account_B["env"]}-pipeline"
  role     = aws_iam_role.Account_B_codepipeline.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Resource : aws_iam_role.Account_B_codepipeline_codecommit.arn,
        Effect : "Allow"
      },
      {
        Action : "sts:AssumeRole",
        Resource : aws_iam_role.Account_B_codepipeline_codebuild.arn,
        Effect : "Allow"
      }
    ]
  })
}

#
# CodePipeline -> CodeBuild
#
resource "aws_iam_role" "Account_B_codepipeline_codebuild" {
  provider = aws.Account_B
  name     = "${var.prefix}-${var.Account_B["env"]}-pipeline-build"
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

resource "aws_iam_role_policy" "Account_B_codebuild" {
  provider = aws.Account_B
  name     = "${var.prefix}-${var.Account_B["env"]}-build"
  role     = aws_iam_role.Account_B_codepipeline_codebuild.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild"
        ],
        Resource : aws_codebuild_project.Account_B.arn,
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
resource "aws_iam_role" "Account_B_codebuild" {
  provider = aws.Account_B
  name     = "${var.prefix}-${var.Account_B["env"]}-codebuild"
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

resource "aws_iam_role_policy" "Account_B_build" {
  provider = aws.Account_B
  name     = "${var.prefix}-${var.Account_B["env"]}-codebuild"
  role     = aws_iam_role.Account_B_codebuild.id
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
