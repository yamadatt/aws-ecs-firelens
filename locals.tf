locals {
  name_prefix                    = "yamada"
  env                            = "stag"
  vpc_cidr                       = "10.0.0.0/16"
  alb_subnet_cidr_block_1a       = "10.0.1.0/24"
  alb_subnet_cidr_block_1b       = "10.0.2.0/24"
  container_subnet_cidr_block_1a = "10.0.3.0/24"
  container_subnet_cidr_block_1b = "10.0.4.0/24"
  rds_subnet_cidr_block_1a       = "10.0.5.0/24"
  rds_subnet_cidr_block_1b       = "10.0.6.0/24"
  az_1a                          = "ap-northeast-1a"
  az_1b                          = "ap-northeast-1c"
}


