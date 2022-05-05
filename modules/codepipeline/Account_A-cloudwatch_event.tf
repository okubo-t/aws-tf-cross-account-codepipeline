resource "aws_cloudwatch_event_rule" "Account_A" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_A["env"]}-repo-state-change"
  event_pattern = jsonencode({
    detail-type : [
      "CodeCommit Repository State Change"
    ],
    resources : [
      aws_codecommit_repository.this.arn
    ],
    source : [
      "aws.codecommit"
    ],
    detail : {
      event : [
        "referenceCreated",
        "referenceUpdated"
      ],
      referenceName : [
        "${var.Account_A["branch_name"]}"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "Account_A" {
  provider = aws.Account_A
  rule     = aws_cloudwatch_event_rule.Account_A.id
  arn      = aws_codepipeline.Account_A.arn
  role_arn = aws_iam_role.Account_A_cloudwatch_events.arn
}

#
# Account A Cloudwatch Event -> Account B EventBus
#
resource "aws_cloudwatch_event_rule" "Account_A_to_B" {
  provider = aws.Account_A
  name     = "${var.prefix}-${var.Account_B["env"]}-repo-state-change"
  event_pattern = jsonencode({
    detail-type : [
      "CodeCommit Repository State Change"
    ],
    resources : [
      aws_codecommit_repository.this.arn
    ],
    source : [
      "aws.codecommit"
    ],
    detail : {
      event : [
        "referenceCreated",
        "referenceUpdated"
      ],
      referenceName : [
        "${var.Account_B["branch_name"]}"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "Account_A_to_B" {
  provider = aws.Account_A
  rule     = aws_cloudwatch_event_rule.Account_A_to_B.id
  arn      = "arn:aws:events:${var.Account_B["region"]}:${data.aws_caller_identity.Account_B.account_id}:event-bus/default"
  role_arn = aws_iam_role.Account_A_to_B.arn
}
