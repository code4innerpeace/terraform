data "template_file" "iot_lambda_policy_template_file" {
  template = file("modules/iotbutton/policies/IoTLambdaRole.json.tpl")
}

resource "aws_iam_policy" "role_iot_lambda_policy" {
  description = "${var.project_name} IOT Lambda Role Policy"
  name_prefix = "${var.project_name}_iot_lambda_role"
  policy      = data.template_file.iot_lambda_policy_template_file.rendered
}

resource "aws_iam_role" "role_iot_lambda" {
  name_prefix        = "${var.project_name}_iot_lambda_role"
  assume_role_policy = <<EOF
{
          "Version": "2012-10-17",
          "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Principal": {
                      "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
          ]
    }
  EOF
  description        = "IOT Lambda Role assumed by ${var.project_name}."
}

resource "aws_iam_role_policy_attachment" "iot_lambda_role_policy_attachment" {
  role       = aws_iam_role.role_iot_lambda.name
  policy_arn = aws_iam_policy.role_iot_lambda_policy.arn
}

resource "aws_lambda_function" "iot_lambda_call_sfn" {
  filename         = "modules/iotbutton/python_code.zip"
  function_name    = "${var.project_name}_iot_lambda_call_sfn"
  role             = aws_iam_role.role_iot_lambda.arn
  handler          = "iot_lambda_call_sfn.lambda_handler"
  source_code_hash = filebase64("modules/iotbutton/python_code.zip")
  runtime          = "python3.6"
  timeout          = 20

  environment {
    variables = {
      sfn_arn   = "${var.sfn_arn}"
      topic_arn = "${var.topic_arn}"
    }
  }
}
