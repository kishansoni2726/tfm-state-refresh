import boto3
import json

ec2 = boto3.client('ec2')
autoscaling = boto3.client('autoscaling')

def lambda_handler(event, context):
    detail = event['detail']
    instance_id = detail['EC2InstanceId']
    lifecycle_hook_name = detail['LifecycleHookName']
    asg_name = detail['AutoScalingGroupName']
    
    # Step 1: Find an unattached EBS volume with tag "AttachTo" = instance_id (or custom logic)
    volumes = ec2.describe_volumes(
        Filters=[
            {'Name': 'status', 'Values': ['available']},
            {'Name': 'tag:AttachTo', 'Values': [instance_id]}
        ]
    )
    
    if not volumes['Volumes']:
        print("No available volume found.")
    else:
        volume_id = volumes['Volumes'][0]['VolumeId']
        
        # Step 2: Attach to the instance
        ec2.attach_volume(
            VolumeId=volume_id,
            InstanceId=instance_id,
            Device='/dev/sdf'
        )
    
    # Step 3: Complete the lifecycle action
    autoscaling.complete_lifecycle_action(
        LifecycleHookName=lifecycle_hook_name,
        AutoScalingGroupName=asg_name,
        LifecycleActionResult='CONTINUE',
        InstanceId=instance_id
    )
    
    return {"status": "done"}
