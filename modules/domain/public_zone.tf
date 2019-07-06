data "aws_route53_zone" "public" {
  name = "${var.hosted_zone}."
}
