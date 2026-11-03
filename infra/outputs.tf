# All the outputs

output "vote_url" {
  description = "The vote page"
  value       = "http://${aws_lb.main.dns_name}"
}

output "result_url" {
  description = "The result page"
  value       = "http://${aws_lb.main.dns_name}:8080"
}

output "redis_endpoint" {
  description = "ElastiCache address"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "db_endpoint" {
  description = "RDS address"
  value       = aws_db_instance.main.address
}