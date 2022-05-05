resource "aws_kms_key" "Account_A" {
  provider = aws.Account_A
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.Account_A.account_id}:root"
        },
        Action : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:GenerateDataKey",
          "kms:TagResource",
          "kms:UntagResource"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.Account_A_codepipeline_codecommit.arn,
            aws_iam_role.Account_A_codebuild.arn,
        ] },
        Action : [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        Resource : "*"
      },
    ]
  })
}
