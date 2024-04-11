resource "aws_db_instance" "datastore1" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "datastore1"
  username             = "admin"
  password             = "Password123"
}

resource "aws_dynamodb_table" "datastore2" {
  name           = "datastore2"
  hash_key       = "Id"
  attribute {
    name = "Id"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}

resource "aws_s3_bucket" "datastore3" {
  bucket = "datastore3-bucket"
  acl    = "private"
}

resource "aws_elasticache_cluster" "datastore4" {
  cluster_id           = "datastore4"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
}

resource "aws_redshift_cluster" "datastore5" {
  cluster_identifier      = "datastore5"
  node_type               = "dc2.large"
  cluster_type            = "single-node"
  master_username         = "admin"
  master_password         = "Password123"
  skip_final_snapshot     = true
}