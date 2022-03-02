data "archive_file" "lambda_origin_request_response" {
  type        = "zip"
  output_path = "${path.root}/.terraform/artifacts/${var.deployment_name}originRequestResponse.zip"

  source {
    content  = file("${path.module}/files/originRequestResponse.js")
    filename = "originRequestResponse.js"
  }

  source {
    content = jsonencode({
      cspData = {
        default = concat(["'self'"], var.csp_allow_default),
        script = concat(["'self'"], var.csp_allow_script),
        style = concat(["'self'"], var.csp_allow_style),
        img = concat(["'self'"], var.csp_allow_img),
        font = concat(["'self'"], var.csp_allow_font),
        frame = concat(["'self'"], var.csp_allow_frame),
      }
    })
    filename = "environment.json"
  }
}

resource "aws_lambda_function" "lambda_add_security_headers" {
  description      = "Lambda@Edge function to add security headers to all cloudfront requests"
  filename         = data.archive_file.lambda_origin_request_response.output_path
  function_name    = "${var.deployment_name}-lambda-add-security-headers"
  role             = aws_iam_role.iam_for_lambda_edge.arn
  handler          = "originRequestResponse.addHeaders"
  runtime          = "nodejs14.x"
  source_code_hash = data.archive_file.lambda_origin_request_response.output_base64sha256
  timeout          = 2
  memory_size      = 128
  publish          = true
  provider         = aws.us-east-1
}

data "archive_file" "lambda_origin_request" {
  for_each = var.redirects == null ? toset([]) : toset(["0"])

  type        = "zip"
  output_path = "${path.root}/.terraform/artifacts/${var.deployment_name}originRequest.zip"

  source {
    content  = file("${path.module}/files/originRequest.js")
    filename = "originRequest.js"
  }

  source {
    content  = jsonencode({
      redirects = var.redirects
    })
    filename = "environment.json"
  }
}

resource "aws_lambda_function" "lambda_redirects" {
  for_each = data.archive_file.lambda_origin_request

  description      = "Lambda@Edge function to handle redirects on cloudfront requests"
  filename         = each.value.output_path
  function_name    = "${var.deployment_name}-lambda-handle-redirects"
  role             = aws_iam_role.iam_for_lambda_edge.arn
  handler          = "originRequest.redirect"
  runtime          = "nodejs14.x"
  source_code_hash = each.value.output_base64sha256
  timeout          = 2
  memory_size      = 128
  publish          = true
  provider         = aws.us-east-1
}

resource "aws_iam_role" "iam_for_lambda_edge" {
  name               = "${var.deployment_name}-iam_for_lambda_edge"
  provider           = aws.us-east-1
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


/* Policy attached to lambda execution role to allow logging */
resource "aws_iam_role_policy" "lambda_log_policy" {
  name = "${var.deployment_name}-lambda_log_policy"
  role = aws_iam_role.iam_for_lambda_edge.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
