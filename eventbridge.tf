resource "aws_cloudwatch_event_rule" "asg_launch_event" {
  name = "asg-ebs-hook-event"
  event_pattern = <<EOF
{
  "source": ["aws.autoscaling"],
  "detail-type": ["EC2 Instance-launch Lifecycle Action"],
  "detail": {
    "AutoScalingGroupName": ["${aws_autoscaling_group.asg.name}"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "asg_launch_lambda" {
  rule      = aws_cloudwatch_event_rule.asg_launch_event.name
  target_id = "AttachEBSLambda"
  arn       = aws_lambda_function.attach_ebs_lambda.arn
}
