# REDIS Database used by MISP-Dashboard
resource "aws_elasticache_replication_group" "MISP_Redis" {
  replication_group_id          = "tf-redis-misp-dashboard"
  replication_group_description = "Redis for MISP dashboard"
  engine                        = "redis"
  engine_version                = "5.0.5"
  node_type                     = "cache.t2.small"
  port                          = 6379
  parameter_group_name          = "default.redis5.0"
  automatic_failover_enabled    = true
  number_cache_clusters         = 2
  security_group_ids = ["${data.aws_security_group.MISP_node_ext.id}"]
  subnet_group_name = aws_elasticache_subnet_group.MISP_redis_subnet_group.name
}

# DB Subnet Group to deploy RDS
# Subnet to deploy RDS (Must be in the same VPC as K8S)
resource "aws_elasticache_subnet_group" "MISP_redis_subnet_group" {
  name       = "Redis-MISP-subnet-group"
  subnet_ids = data.aws_subnet_ids.MISP_subnets.ids
}
