variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "assignment-c7"
}

variable "app_environment" {      ### The value of the respective environment
  type        = string
  description = "Application Tag"
  default     = "916"
}

variable "vpc_cidr" {         ### vpc cidr to be created
  description = "VPC cidr that needs tio created"
  default     = "10.150.0.0/16"
}

variable "eip-1" {             ## Note:- Ip has to be in Selected VPC.
  description = "Private IP for 2 NGW"
  default     = "10.150.0.30"

}

variable "eip-2" {
  description = "Private IP for 2 NGW"
  default     = "10.150.0.40"

}

variable "tg_port" {
  default = "8080"
}
