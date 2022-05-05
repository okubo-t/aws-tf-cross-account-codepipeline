resource "aws_cloudwatch_event_rule" "Account_B" {
  provider = aws.Account_B
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

resource "aws_cloudwatch_event_target" "Account_B" {
  provider = aws.Account_B
  rule     = aws_cloudwatch_event_rule.Account_B.id
  arn      = aws_codepipeline.Account_B.arn
  role_arn = aws_iam_role.Account_B_cloudwatch_events.arn
}

resource "aws_cloudwatch_event_permission" "Account_A_to_B" {
  provider       = aws.Account_B
  principal      = data.aws_caller_identity.Account_A.account_id
  statement_id   = "CrossAccountAccess"
  action         = "events:PutEvents"
  event_bus_name = "default"
}
