terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}
module "vpc" {
  source ="git@github.com:satishkumarkrishnan/terraform-aws-vpc.git?ref=main"
  }

module "asg" {
  source="git@github.com:satishkumarkrishnan/terraform-aws-asg.git?ref=main"  
  depends_on = [module.vpc]
}
  
# TF code for R53 zone ID creation
resource "aws_route53_zone" "tokyo_zone"  {
  name = "myfirstr53.com"
  depends_on = [module.asg]

}
#TF code for R53 creation 
resource "aws_route53_record" "tokyo_r53" {
  zone_id = aws_route53_zone.tokyo_zone.zone_id
  name    = "myfirstr53.com"
  type    = "A"
  alias {    
    name                   = module.asg.asg_alb_dns_name
    zone_id                = module.asg.asg_alb_hosted_zone_id
    evaluate_target_health = true
  }
  depends_on = [module.asg]
}