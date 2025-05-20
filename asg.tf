resource "aws_launch_template" "asg_template" {
    name                              = "${var.project}-Launch-config"
  instance_type = "t3.micro"
image_id = var.AMI
  block_device_mappings {
    device_name = "/dev/xvda" # Root volume
    ebs {
      volume_size = 8
      volume_type = "gp3"
    }
  }

    block_device_mappings {
    device_name = "/dev/xvdb" # Additional EBS volume
    ebs {
      volume_size = 20               # Size in GB
      volume_type = "gp3"
      delete_on_termination = false
      encrypted = true
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.asg_sg.id]
  }
    key_name                          = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              mkfs -t ext4 /dev/xvdb
              mkdir /data
              mount /dev/xvdb /data
              echo "/dev/xvdb /data ext4 defaults,nofail 0 2" >> /etc/fstab
              apt update 
              apt upgrade -y
              apt install nginx -y
              systemctl enable nginx
          EOF
  )
}

resource "aws_autoscaling_lifecycle_hook" "attach_ebs_hook" {
  name                   = "attach-ebs-volume"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
  notification_target_arn = aws_sns_topic.lifecycle_topic.arn
  role_arn               = aws_iam_role.asg_lifecycle_role.arn
}


resource "aws_autoscaling_group" "asg" {
    name                              = "${var.project}-ASG"
    vpc_zone_identifier               = [ for subnet in aws_subnet.public_subnets[*] : subnet.id ]
  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }
    desired_capacity                  = var.desired_capacity
    min_size                          = var.min_size
    max_size                          = var.max_size
    health_check_grace_period         = var.health_check_grace_period
    health_check_type                 = "EC2"
}

resource "aws_lb" "alb" {
    name                              = "${var.project}-Public-ALB"
    internal                          = false
    load_balancer_type                = "application"
    security_groups                   = [aws_security_group.asg_sg.id]
    subnets                           = [for subnet in aws_subnet.public_subnets : subnet.id]
    tags = {
        Createdwith                   = "Terraform"
    }
}

resource "aws_lb_target_group" "lb_target_group" {
    name                              = "${var.project}-Target-Group"
    port                              = 80
    protocol                          = "HTTP"
    vpc_id                            = aws_vpc.main.id
    target_type                       = "instance"
    tags = {
        Createdwith                   = "Terraform"
    } 
}

resource "aws_autoscaling_attachment" "asg_to_target_group" {
    autoscaling_group_name            = aws_autoscaling_group.asg.name
    lb_target_group_arn               = aws_lb_target_group.lb_target_group.arn
}

resource "aws_lb_listener" "alb_listener" {
    load_balancer_arn                 = aws_lb.alb.arn
    port                              = "80"
    protocol                          = "HTTP"
    default_action {
        type                          = "forward"
        target_group_arn              = aws_lb_target_group.lb_target_group.arn
    }
}

#scale up policy
resource "aws_autoscaling_policy" "scale_up" {
    name                              = "${var.project}-asg-scale-up"
    autoscaling_group_name            = aws_autoscaling_group.asg.name
    adjustment_type                   = "ChangeInCapacity"
    scaling_adjustment                = "1" #increasing instance by 1 
    cooldown                          = "300"
    policy_type                       = "SimpleScaling"
}

# scale up alarm
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
    alarm_name                        = "${var.project}-asg-scale-up-alarm"
    alarm_description                 = "asg-scale-up-cpu-alarm"
    comparison_operator               = "GreaterThanOrEqualToThreshold"
    evaluation_periods                = "5"
    metric_name                       = "CPUUtilization"
    namespace                         = "AWS/EC2"
    period                            = "60"
    statistic                         = "Average"
    threshold                         = "60" 
    dimensions = {
      "AutoScalingGroupName" = aws_autoscaling_group.asg.name
    }
    actions_enabled                   = true
    alarm_actions                     = [aws_autoscaling_policy.scale_up.arn]
}

# Alarm for average CPU Utilization og greater than 60% for constant 20 minutes
resource "aws_cloudwatch_metric_alarm" "constant_cpu_60_percent_up_alarm" {
    alarm_name                        = "${var.project}-constant_cpu_60_percent_up_alarm"
    alarm_description                 = "asg-scale-up-cpu-alarm"
    comparison_operator               = "GreaterThanOrEqualToThreshold"
    evaluation_periods                = "20"
    metric_name                       = "CPUUtilization"
    namespace                         = "AWS/EC2"
    period                            = "60"
    statistic                         = "Average"
    threshold                         = "60" 
    dimensions = {
      "AutoScalingGroupName"          = aws_autoscaling_group.asg.name
    }
    actions_enabled                   = true
    alarm_actions                     = [aws_autoscaling_policy.scale_up.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
    name                              = "${var.project}-asg-scale-down"
    autoscaling_group_name            = aws_autoscaling_group.asg.name
    adjustment_type                   = "ChangeInCapacity"
    scaling_adjustment                = "-1" # decreasing instance by 1 
    cooldown                          = "300"
    policy_type                       = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
    alarm_name                        = "${var.project}-asg-scale-down-alarm"
    alarm_description                 = "asg-scale-down-cpu-alarm"
    comparison_operator               = "LessThanOrEqualToThreshold"
    evaluation_periods                = "20"
    metric_name                       = "CPUUtilization"
    namespace                         = "AWS/EC2"
    period                            = "60"
    statistic                         = "Average"
    threshold                         = "40"
    dimensions = {
      "AutoScalingGroupName"          = aws_autoscaling_group.asg.name
    }
    actions_enabled                   = true
    alarm_actions                     = [aws_autoscaling_policy.scale_down.arn]
}

