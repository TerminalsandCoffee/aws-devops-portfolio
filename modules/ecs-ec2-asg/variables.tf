variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "instance_type" { default = "t3.micro" }
variable "alb_security_group_id" {
  description = "ALB security group allowed to reach dynamic host ports on the instances"
  type        = string
}