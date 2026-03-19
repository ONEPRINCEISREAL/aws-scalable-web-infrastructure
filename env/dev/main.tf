module "vpc" {
  source   = "../../module/vpc"
  vpc_cidr = "10.0.0.0/16"
}

module "ec2" {
  source             = "../../module/vpc/ec2"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "alb" {
  source = "../../module/vpc/ec2/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  asg_name          = module.ec2.asg_name
}