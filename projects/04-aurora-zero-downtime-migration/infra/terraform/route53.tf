# Route 53 record to act as a blue/green CNAME between RDS and Aurora

# Data source for Route 53 hosted zone (if provided)
data "aws_route53_zone" "main" {
  count = var.route53_zone_name != "" ? 1 : 0
  name  = var.route53_zone_name
}

# Route 53 record pointing to RDS (initial state - blue)
resource "aws_route53_record" "database" {
  count   = var.route53_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.route53_record_name
  type    = "CNAME"
  ttl     = 60

  # Initially points to RDS endpoint
  records = [aws_db_instance.source.address]
}

# Note: To perform cutover, manually update this record to point to:
# aws_rds_cluster.aurora.endpoint
# Or use the cutover scripts in scripts/ directory