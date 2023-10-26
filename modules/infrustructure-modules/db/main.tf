module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "dtabase1"

  engine            = "postgres"
  engine_version    = "15.3"
  family            = "postgres15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  create_db_option_group    = false
  create_db_parameter_group = false

  username = "pestgres"

  skip_final_snapshot = true
  deletion_protection = false

  # create_db_subnet_group = true

  db_subnet_group_name = var.db_subnet_group_name

  # db_subnet_group_name = "my-dev-vpc"

  vpc_security_group_ids = [var.security_group_id]

  manage_master_user_password = true


}
