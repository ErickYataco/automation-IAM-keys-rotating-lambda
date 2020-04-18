resource "aws_iam_role" "LambdaRotateIAMKeysRole" {
  name = "LambdaRotateIAMKeysRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "LambdaRotateIAMKeysPolicy" {
  name        = "LambdaRotateIAMKeysPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ],
    "Resource": "arn:aws:logs:*:*:*",
    "Effect": "Allow"
  },
  {
    "Action": [
      "iam:ListAccessKeys",
      "iam:ListUsers",
      "iam:UpdateAccessKey",
      "ses:SendMail"
    ],
    "Resource": "*",
    "Effect": "Allow"
  }]
}
EOF
}



resource "aws_iam_role_policy_attachment" "LambdaRotateIAMKeyAttachment" {
  role   = "${aws_iam_role.LambdaRotateIAMKeysRole.id}"
  policy_arn = "${aws_iam_policy.LambdaRotateIAMKeysPolicy.arn}"
}

data "null_data_source" "LambdaRotateIAMKeysFile" {
  inputs = {
    filename = "/lambda/LambdaRotateIAMKeys.js"
  }
}

data "null_data_source" "LambdaRotateIAMKeysArchive" {
  inputs = {
    filename = "${path.module}/lambda/LambdaRotateIAMKeys.zip"
  }
} 

data "archive_file" "LambdaRotateIAMKeys" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  source_file = "${data.null_data_source.LambdaRotateIAMKeysFile.outputs.filename}"
  output_path = "${data.null_data_source.LambdaRotateIAMKeysArchive.outputs.filename}"
}

resource "aws_cloudwatch_log_group" "LambdaRotateIAMKeyLoggingGroup" {
  name = "/aws/lambda/LambdaRotateIAMKeys"
}

resource "aws_lambda_function" "LambdaRotateIAMKeys" {
  filename         = "${data.archive_file.LambdaRotateIAMKeys.output_path}"
  function_name    = "LambdaRotateIAMKeys"
  role             = "${aws_iam_role.LambdaRotateIAMKeysRole.arn}"
  handler          = "LambdaRotateIAMKeys.handler"
  source_code_hash = "${data.archive_file.LambdaRotateIAMKeys.output_base64sha256}"
  runtime          = "nodejs10.x"
  timeout          = 60

}

resource "aws_lambda_permission" "allowRotateIAMKeysRule" {
    statement_id = "AllowExecutionFromCloudWatchRotateIAMKeysRule"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambdaRotateIAMKeys.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.RotateIAMKeysRule.arn}"
}




