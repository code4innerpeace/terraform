output "cloudwatch_guardduty_event_rule" {
  value = "${aws_cloudwatch_event_rule.splunk_guardduty_event_rule.id}"
}

output "guardduty_lambda" {
  value = "${aws_lambda_function.splunk_guardduty_app.id}"
}
