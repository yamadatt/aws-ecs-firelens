output "ecs_cluster_backend_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_mars_g_c_name" {
  value = aws_ecs_service.this.name
}

