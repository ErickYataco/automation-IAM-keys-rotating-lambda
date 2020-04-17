resource "aws_cloudwatch_event_rule" "RotateIAMKeysRule" {
  name        = "RotateIAMKeysRule"
  description = "improve security rotating IAM keys"
  schedule_expression = "cron(45 12 ? * SUN *)"
 
}

resource "aws_cloudwatch_event_target" "RotateIAMKeysEventTarget" {
  rule      = "${aws_cloudwatch_event_rule.RotateIAMKeysRule.name}"
  target_id = "RotateIAMKeys"
  arn       = "${aws_lambda_function.LambdaRotateIAMKeys.arn}"

  depends_on = [
      aws_lambda_function.LambdaRotateIAMKeys,
  ]

}


