# MISP database
resource "aws_db_instance" "MISP_Database" {
  allocated_storage    = var.MISP_database_size
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "${var.MISP_database_name}"
  username             = "${var.MISP_database_user}"
  password             = "${random_password.MISP_database_psswd.result}"
  parameter_group_name = "default.mysql5.7"
  multi_az             = true
  db_subnet_group_name = "${aws_db_subnet_group.EKS_database_subnet.name}"
  vpc_security_group_ids = ["${data.aws_security_group.eks_node_ext.id}"]
  final_snapshot_identifier = "MISP-Database-Backup"
}

# Generate strong random password for default database user
resource "random_password" "MISP_database_psswd" {
  length = 16
  special = false
}

# DB Subnet Group to deploy RDS
resource "aws_db_subnet_group" "EKS_database_subnet" {
  name       = "EKS_MISP_database"
  # Exception here - last subnet is public
  subnet_ids = slice(tolist(data.aws_subnet_ids.eks_subnets.ids), 0, length(data.aws_subnet_ids.eks_subnets.ids) - 1)

  tags = {
    Name = "EKS MISP Database subnet group"
  }
}