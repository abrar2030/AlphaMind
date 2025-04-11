aws_region = "us-west-2"
environment = "dev"
app_name    = "app"

vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

instance_type = "t3.micro"
key_name      = "dev-key"

db_instance_class = "db.t3.micro"
db_name           = "appdb"
db_username       = "admin"
db_password       = "Password123!" # Use AWS Secrets Manager in production

default_tags = {
  Terraform   = "true"
  Environment = "dev"
  Project     = "app"
}
