output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.security.app_security_group_id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = module.security.db_security_group_id
}

output "app_instance_ids" {
  description = "IDs of the application instances"
  value       = module.compute.instance_ids
}

output "app_instance_public_ips" {
  description = "Public IPs of the application instances"
  value       = module.compute.instance_public_ips
}

output "db_endpoint" {
  description = "Endpoint of the database"
  value       = module.database.db_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_name
}
