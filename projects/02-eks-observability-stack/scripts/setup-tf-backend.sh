# scripts/setup-tf-backend.sh
#!/bin/bash
set -e

BUCKET="yourname-devops-portfolio-tfstate"
TABLE="terraform-locks"
REGION="us-west-2"

echo "Creating S3 bucket: $BUCKET"
aws s3api create-bucket --bucket $BUCKET --region $REGION --create-bucket-configuration LocationConstraint=$REGION

echo "Enabling versioning..."
aws s3api put-bucket-versioning --bucket $BUCKET --versioning-configuration Status=Enabled

echo "Enabling encryption..."
aws s3api put-bucket-encryption \
  --bucket $BUCKET \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "Creating DynamoDB lock table: $TABLE"
aws dynamodb create-table \
  --table-name $TABLE \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

echo "Backend ready! Add to backend.tf and commit."