variable "project" {
    type        = string
    description = "Project Title (yesmust use lowercase letters)"
    default     = "tfm-state-refresh"
}


variable "region" {
    type        = string
    description = "Default Region for Project"
    default     = "us-east-1"
}
variable "vpc_cidr" {
    type        = string
    description = "Project Title"
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "AMI" {
    type        = string
    description = "Project Title"
    default     = "ami-084568db4383264d4"
}

# variable "lg_user_data" {
#     type        = string
#     description = "Project Title"
#     default     = "  #!/bin/bash sudo apt update && sudo apt upgrade -y && && sudo apt install nginx -y && sudo systemctl enable nginx"
# }

variable "asg_instance_type" {
    type        = string
    description = "Instance Type"
    default     = "t2.micro"
}

variable "key_name" {
    type        = string
    description = "Key Name"
    default     = "terraform-demo"
}
##########################################################################

variable "desired_capacity" {
    type        = number
    description = "Desired number of Instances ASG can Create."
    default     = 2
}

variable "min_size" {
    type        = number
    description = "Minimum Number of Instances ASG can Create."
    default     = 2
}

variable "max_size" {
    type        = number
    description = "Maximum Number of Instances ASG can Create."
    default     = 5
}

variable "health_check_grace_period" {
    type        = number
    description = "Instance Type"
    default     = 300
}


