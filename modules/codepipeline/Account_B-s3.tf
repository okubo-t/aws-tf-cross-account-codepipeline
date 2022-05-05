resource "aws_s3_bucket" "Account_B" {
  provider      = aws.Account_B
  bucket        = "${var.prefix}-${var.Account_B["env"]}-codepipeline-${var.Account_B["region"]}-${data.aws_caller_identity.Account_B.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "Account_B" {
  provider = aws.Account_B
  bucket   = aws_s3_bucket.Account_B.id
  acl      = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "Account_B" {
  provider = aws.Account_B
  bucket   = aws_s3_bucket.Account_B.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.Account_B.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "Account_B" {
  provider = aws.Account_B
  bucket   = aws_s3_bucket.Account_B.id
  policy = jsonencode({
    Version : "2012-10-17",
    Id : "SSEAndSSLPolicy",
    Statement : [
      {
        Sid : "DenyUnEncryptedObjectUploads",
        Effect : "Deny",
        Principal : "*",
        Action : "s3:PutObject",
        Resource : "${aws_s3_bucket.Account_B.arn}/*",
        Condition : {
          StringNotEquals : {
            "s3:x-amz-server-side-encryption" : "aws:kms"
          }
        }
      },
      {
        Sid : "DenyInsecureConnections",
        Effect : "Deny",
        Principal : "*",
        Action : "s3:*",
        Resource : "${aws_s3_bucket.Account_B.arn}/*",
        Condition : {
          Bool : {
            "aws:SecureTransport" : "false"
          }
        }
      },
      {
        Sid : "CodePipelineBucketPolicy",
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.Account_B_codepipeline_codecommit.arn,
            aws_iam_role.Account_B_codebuild.arn,
        ] },
        Action : [
          "s3:Get*",
          "s3:Put*"
        ],
        Resource : "${aws_s3_bucket.Account_B.arn}/*",
      },
      {
        Sid : "CodePipelineBucketListPolicy",
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.Account_B_codepipeline_codecommit.arn,
            aws_iam_role.Account_B_codebuild.arn,
        ] },
        Action : "s3:ListBucket",
        Resource : aws_s3_bucket.Account_B.arn,
      }
    ]
  })
}
