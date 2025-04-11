aws_region = "us-west-2"
environment = "prod"
app_name    = "app"

vpc_cidr            = "10.2.0.0/16"
availability_zones  = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
private_subnet_cidrs = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]

instance_type = "t3.large"
key_name      = "prod-key"

db_instance_class = "db.t3.large"
db_name           = "appdb"
db_username       = "admin"
db_password       = "Password123!" # Use AWS Secrets Manager in production

default_tags = {
  Terraform   = "true"
  Environment = "prod"
  Project     = "app"
}
