import boto3
import os
import logging

ecs = boto3.client('ecs')
elbv2 = boto3.client('elbv2')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

CLUSTER_NAME = os.environ.get('CLUSTER_NAME') # Retrieved from Terraform env var

def lambda_handler(event, context):
    # 1. Get TargetGroup ARN from Alarm
    # (Note: Alarm dimension parsing logic remains the same)
    tg_arn = event['detail']['configuration']['metrics'][0]['metricStat']['metric']['dimensions']['TargetGroup']
    
    # 2. Find unhealthy targets
    health = elbv2.describe_target_health(TargetGroupArn=tg_arn)
    unhealthy_targets = [
        t for t in health['TargetHealthDescriptions']
        if t['TargetHealth']['State'] in ['unhealthy', 'draining']
    ]

    if not unhealthy_targets:
        return {"status": "No unhealthy targets found."}

    # 3. List all tasks in the cluster (Use pagination in real prod code!)
    # Optimization: Use 'containerInstance' filter if you knew the host, 
    # but for Fargate/mixed, listing tasks is safer.
    list_resp = ecs.list_tasks(cluster=CLUSTER_NAME, desiredStatus='RUNNING')
    task_arns = list_resp['taskArns']
    
    if not task_arns:
        return {"status": "No running tasks found."}

    # 4. Describe tasks to get their network details (IPs)
    # AWS allows describing up to 100 tasks at once.
    tasks_resp = ecs.describe_tasks(cluster=CLUSTER_NAME, tasks=task_arns)
    
    # 5. Match Target IP to Task
    tasks_to_kill = []
    
    for u_target in unhealthy_targets:
        bad_ip = u_target['Target']['Id']
        bad_port = u_target['Target']['Port']
        
        for task in tasks_resp['tasks']:
            # Look inside containers for network bindings
            for container in task['containers']:
                # For 'awsvpc' mode (Fargate), IP is in networkInterfaces
                # For 'bridge' mode (EC2), we look at mapped ports
                # Let's assume standard logic:
                for net_int in task['attachments']:
                    if net_int['type'] == 'ElasticNetworkInterface':
                        for detail in net_int['details']:
                            if detail['name'] == 'privateIPv4Address' and detail['value'] == bad_ip:
                                tasks_to_kill.append(task['taskArn'])
    
    # 6. Execute the Fix (Stop the Task)
    # Removing duplicates
    tasks_to_kill = list(set(tasks_to_kill))
    
    for task_arn in tasks_to_kill:
        logger.info(f"Stopping stale task: {task_arn}")
        ecs.stop_task(
            cluster=CLUSTER_NAME,
            task=task_arn,
            reason='Auto-Healer: Task failed ALB health checks'
        )

    return {"killed_tasks": tasks_to_kill}
