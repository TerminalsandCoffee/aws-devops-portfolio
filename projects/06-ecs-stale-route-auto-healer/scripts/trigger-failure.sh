#!/usr/bin/env bash
# Instantly breaks one running nginx task to force ALB 5xx → auto-healer runs

set -euo pipefail

CLUSTER="demo-stale-route"           # ← change if your cluster name differs
SERVICE="demo-nginx-service"         # ← change if your service name differs
REGION="${AWS_REGION:-$(aws configure get region)}"

echo "Triggering stale-route failure scenario..."

# 1. Find one running task ARN
TASK_ARN=$(aws ecs list-tasks \
  --cluster "$CLUSTER" \
  --service-name "$SERVICE" \
  --desired-status RUNNING \
  --region "$REGION" \
  --query 'taskArns[0]' \
  --output text)

if [[ "$TASK_ARN" == "" || "$TASK_ARN" == "None" ]]; then
  echo "No running tasks found. Is the service up?"
  exit 1
fi

echo "   Found task: $TASK_ARN"

# 2. Get the container instance (EC2) + container name
CONTAINER_INSTANCE=$(aws ecs describe-tasks \
  --cluster "$CLUSTER" \
  --tasks "$TASK_ARN" \
  --region "$REGION" \
  --query 'tasks[0].containerInstanceArn' --output text)

CONTAINER_NAME=$(aws ecs describe-tasks \
  --cluster "$CLUSTER" \
  --tasks "$TASK_ARN" \
  --region "$REGION" \
  --query 'tasks[0].containers[0].name' --output text)

# 3. SSH-less exec into the task and kill nginx → instant 5xx
echo "   Killing nginx inside container '$CONTAINER_NAME' → ALB will return 502/504 → 5xx alarm"
aws ecs execute-command \
  --cluster "$CLUSTER" \
  --task "$TASK_ARN" \
  --container "$CONTAINER_NAME" \
  --interactive false \
  --region "$REGION" \
  --command "pkill -9 nginx || true"

echo ""
echo "   Failure injected! Watch this in real time:"
echo "   • CloudWatch alarm → ALARM in ~60s"
echo "   • EventBridge → Lambda log group"
echo "   • Systems Manager → Run Command history"
echo "   • /var/log/auto-healer.log on the host (via Session Manager)"
echo ""
echo "Run this to watch the Lambda live:"
echo "   aws logs tail /aws/lambda/AutoHealer-RestartRegistrator --follow"

# Optional: auto-restore (uncomment if you want it to self-heal completely)
# echo "   Restarting nginx in 45 seconds so the task goes healthy again..."
# sleep 45
# aws ecs execute-command --cluster "$CLUSTER" --task "$TASK_ARN" --container "$CONTAINER_NAME" \
#   --interactive false --command "nginx" >/dev/null 2>&1
# echo "   nginx restarted – task healthy again"

exit 0