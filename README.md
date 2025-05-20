## Infrastructure Components


    This Infrastructure Code will Creaet following Things:
        
        1.  VPC 
        2.  Internet Gateway
        3.  Public Subnet  (x3)
        4.  Private Subnet (x3)
        5.  NAT Gateway
        6.  Elastic IP
        7.  Launch Configuration
        8.  Auto Scaling Group
        9.  Application Load Balancer
        10. Target Group
        11. RDS Postgres Instance
        12. IAM Roles
        13.  Cloudwatch Alarms
                13.1 Cloudwatch Alarm for CPUUtilization of above 60% for 5 minutes
                13.2 Cloudwatch Alarm for CPUUtilization of below 40% for 20 minutes
                13.3 Cloudwatch Alarm for CPUUtilization of above 60% for 20 minutes

========================================================================

To Deploy this Infra please Follow below mentioned steps:
    
    1). Clone this Repo

    2). create one S3 bucket 

    3). make sure Access key you are using have access for that bucket

    4). specify your bucket name in providers.tf file in terraform -> backend block

        example:
                terraform {
                  backend "s3" {
                    bucket         = "your_bucket_name"
                    key            = "path/terraform.tfstate"
                    region         = "region of bucket"
                    encrypt        = true
                  }
                }
    
    5). Make sure you have terraform installed

    6). Run below mentioned command

            terraform init
            terraform plan
            terraform apply --auto-approve

    7). To destroy infra
            
            1). Delete images from ECR
            2). terraform destroy --auto-approve 
# tfm-state-refresh
