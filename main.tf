# accout id
data "aws_caller_identity" "current" {}

module "iam_role" {
  source      = "./modules/iam/iam_role"
  env         = local.env
  name_prefix = local.name_prefix
}

module "vpc" {
  source      = "./modules/network/vpc"
  env         = local.env
  name_prefix = local.name_prefix
  vpc_cidr    = local.vpc_cidr
}

module "igw" {
  source      = "./modules/network/igw"
  env         = local.env
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
}

module "subnet" {
  source                         = "./modules/network/subnet"
  env                            = local.env
  name_prefix                    = local.name_prefix
  alb_subnet_cidr_block_1a       = local.alb_subnet_cidr_block_1a
  alb_subnet_cidr_block_1b       = local.alb_subnet_cidr_block_1b
  container_subnet_cidr_block_1a = local.container_subnet_cidr_block_1a
  container_subnet_cidr_block_1b = local.container_subnet_cidr_block_1b
  rds_subnet_cidr_block_1a       = local.rds_subnet_cidr_block_1a
  rds_subnet_cidr_block_1b       = local.rds_subnet_cidr_block_1b
  subnet_az_1a                   = local.az_1a
  subnet_az_1b                   = local.az_1b
  vpc_id                         = module.vpc.vpc_id
}

module "sg" {
  source         = "./modules/network/sg"
  env            = local.env
  name_prefix    = local.name_prefix
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = local.vpc_cidr

}



module "route_table" {
  source                         = "./modules/network/route_table"
  env                            = local.env
  name_prefix                    = local.name_prefix
  vpc_id                         = module.vpc.vpc_id
  private_container_subnet_1a_id = module.subnet.subnet_container_1a_id
  private_container_subnet_1b_id = module.subnet.subnet_container_1b_id
  private_rds_subnet_1a_id       = module.subnet.subnet_rds_1a_id
  private_rds_subnet_1b_id       = module.subnet.subnet_rds_1b_id
  public_alb_subnet_1a_id        = module.subnet.subnet_alb_1a_id
  public_alb_subnet_1b_id        = module.subnet.subnet_alb_1b_id
  igw_id                         = module.igw.igw_id
  nat_gw_id                      = module.natgw.nat_gw_id
}


module "ec2" {
  source                = "./modules/ec2"
  env                   = local.env
  name_prefix           = local.name_prefix
  vpc_id                = module.vpc.vpc_id
  public_subnet_1a_id   = module.subnet.subnet_alb_1a_id
  public_subnet_1b_id   = module.subnet.subnet_alb_1b_id
  maintenance_ec2_sg_id = module.sg.maintenance_ec2_sg_id
}


module "natgw" {
  source                  = "./modules/network/natgw"
  env                     = local.env
  name_prefix             = local.name_prefix
  vpc_id                  = module.vpc.vpc_id
  public_alb_subnet_1a_id = module.subnet.subnet_alb_1a_id
  public_alb_subnet_1b_id = module.subnet.subnet_alb_1b_id
}


module "alb" {
  source       = "./modules/alb"
  env          = local.env
  name_prefix  = local.name_prefix
  sg_alb_id    = module.sg.sg_alb_id
  subnet_1a_id = module.subnet.subnet_alb_1a_id
  subnet_1b_id = module.subnet.subnet_alb_1b_id
  vpc_id       = module.vpc.vpc_id
}

module "ecr" {
  source        = "./modules/ecr"
  env           = local.env
  name_prefix   = local.name_prefix
  holding_count = 3
}

module "ecs" {
  source                      = "./modules/ecs"
  env                         = local.env
  name_prefix                 = local.name_prefix
  account_id                  = data.aws_caller_identity.current.account_id
  mars_g_c_ecr_repository_url = module.ecr.ecr_repository_url
  ecs_task_iam_role_arn       = module.iam_role.ecs_task_iam_role_arn
  ecs_task_iam_role_exec_arn  = module.iam_role.ecs_task_iam_role_exec_arn
  alb_tg_mars_g_c_arn         = module.alb.alb_tg_mars_g_c_arn
  sg_container_id             = module.sg.sg_container_id
  subnet_container_1a_id      = module.subnet.subnet_container_1a_id
  subnet_container_1b_id      = module.subnet.subnet_container_1b_id
  backend_desired_count       = 1
}

module "firehose" {
  source            = "./modules/firehose"
  env               = local.env
  name_prefix       = local.name_prefix
  firehose_role_arn = module.iam_role.firehose_role_arn
}