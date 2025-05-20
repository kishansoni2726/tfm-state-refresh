resource "aws_sns_topic" "lifecycle_topic" {
  name = "asg-lifecycle-events"
}