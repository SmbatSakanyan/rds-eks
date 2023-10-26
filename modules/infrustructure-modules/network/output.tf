output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

# output "default_security_group_id" {
#   description = "default"
#   value       = aws_default_security_group.vpc_security_group.id
# }

output "db_subnet_group_name" {
  value = module.vpc.database_subnet_group
}

output "security_group_id" {
  value = module.security_group.security_group_id
}
