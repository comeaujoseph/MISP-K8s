# DNS Entry for MISP
module "misp_dns_record" {
  source = "./modules/aws_route_certificate"
  subdomain = "${local.config.network.cname.api}"
  route53_zone = "${var.route53_zone}"
}

# DNS Entry for MISP Dashboard
module "misp_dashboard_dns_record" {
  source = "./modules/aws_route_certificate"
  subdomain = "${local.config.network.cname.dashboard}"
  route53_zone = "${local.config.network.hosted_zone}"
}
