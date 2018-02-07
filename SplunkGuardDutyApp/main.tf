provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    region     = "us-east-1"
    bucket     = "<S3 BUCKET NAME TO STORE TERRAFORM STATE>"
    key        = "tf.tfstate"
    encrypt    = true
  }
}


resource "aws_iam_role" "guardduty_lambda_execution_role" {
    name = "guardduty_lambda_execution_role"
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


resource "aws_lambda_function" "splunk_guardduty_app" {
  filename         = "SplunkGuardDutyApp.zip"
  function_name    = "SplunkGuardDutyApp"
  role             = "${aws_iam_role.guardduty_lambda_execution_role.arn}"
  handler          = "index.handler"
  source_code_hash = "${base64sha256(file("SplunkGuardDutyApp.zip"))}"
  runtime          = "nodejs6.10"

  environment {
    variables = {
      SPLUNK_HEC_URL = "${var.SPLUNK_HEC_URL}",
      SPLUNK_HEC_TOKEN = "${var.SPLUNK_HEC_TOKEN}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "splunk_guardduty_event_rule" {
  name        = "SplunkGuardDutyApp"
  description = "GuardDuty Events"

  event_pattern = <<PATTERN
  {
    "source":[
              "aws.guardduty"
             ]
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "check-file-event-lambda-target" {
    target_id = "SplunkGuardDutyAppCloudWatchEventTarget"
    rule = "${aws_cloudwatch_event_rule.splunk_guardduty_event_rule.name}"
    arn = "${aws_lambda_function.splunk_guardduty_app.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_SplunkGuardDutyApp_lambda" {
    statement_id = "AllowCloudWatchToInvokeSplunkGuardDutyAppLambda"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.splunk_guardduty_app.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.splunk_guardduty_event_rule.arn}"
}
