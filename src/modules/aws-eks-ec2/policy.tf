resource "aws_iam_policy" "alb" {
  name   = "alb"
  policy = data.http.alb_policy.response_body
}
