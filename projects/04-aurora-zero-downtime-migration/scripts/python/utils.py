"""
Shared utilities for migration scripts.

This module provides common functionality used across multiple migration scripts,
including AWS client creation, error handling, and logging utilities.
"""

import sys
import logging
from typing import Optional
import boto3
from botocore.exceptions import ClientError, BotoCoreError


def setup_logging(level: int = logging.INFO) -> logging.Logger:
    """
    Set up logging configuration.
    
    Args:
        level: Logging level (default: INFO)
        
    Returns:
        Configured logger instance
    """
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    return logging.getLogger(__name__)


def create_rds_client(region: str = "us-east-1") -> boto3.client:
    """
    Create and return an RDS client.
    
    Args:
        region: AWS region (default: us-east-1)
        
    Returns:
        boto3 RDS client
        
    Raises:
        BotoCoreError: If client creation fails
    """
    try:
        return boto3.client('rds', region_name=region)
    except BotoCoreError as e:
        raise RuntimeError(f"Failed to create RDS client: {e}") from e


def create_route53_client(region: str = "us-east-1") -> boto3.client:
    """
    Create and return a Route 53 client.
    
    Args:
        region: AWS region (default: us-east-1)
        
    Returns:
        boto3 Route 53 client
        
    Raises:
        BotoCoreError: If client creation fails
    """
    try:
        return boto3.client('route53', region_name=region)
    except BotoCoreError as e:
        raise RuntimeError(f"Failed to create Route 53 client: {e}") from e


def handle_aws_error(error: Exception, operation: str, resource: Optional[str] = None) -> None:
    """
    Handle AWS API errors with consistent formatting.
    
    Args:
        error: The exception that occurred
        operation: Description of the operation that failed
        resource: Optional resource identifier
    """
    resource_str = f" ({resource})" if resource else ""
    
    if isinstance(error, ClientError):
        error_code = error.response.get('Error', {}).get('Code', 'Unknown')
        error_message = error.response.get('Error', {}).get('Message', str(error))
        print(
            f"❌ AWS Error during {operation}{resource_str}: {error_code} - {error_message}",
            file=sys.stderr
        )
    else:
        print(
            f"❌ Error during {operation}{resource_str}: {error}",
            file=sys.stderr
        )


def validate_aws_credentials() -> bool:
    """
    Validate that AWS credentials are configured.
    
    Returns:
        True if credentials are available, False otherwise
    """
    try:
        sts = boto3.client('sts')
        sts.get_caller_identity()
        return True
    except (ClientError, BotoCoreError):
        print(
            "❌ AWS credentials not configured. Please configure AWS CLI or set environment variables.",
            file=sys.stderr
        )
        return False

