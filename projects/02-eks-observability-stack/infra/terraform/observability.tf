// IAM role for the observability stack (e.g., AWS Distro for OpenTelemetry collector).
// The role is bound to a Kubernetes service account via IRSA so the collector can
// publish metrics, logs, and traces to AWS managed services without node credentials.

locals {
  observability_namespace = "observability"
  collector_serviceaccount = "adot-collector"
}

data "aws_iam_policy_document" "observability_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values = [
        "system:serviceaccount/${local.observability_namespace}/${local.collector_serviceaccount}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
  }
}

resource "aws_iam_role" "observability_irsa" {
  name               = "${var.cluster_name}-observability-irsa"
  assume_role_policy = data.aws_iam_policy_document.observability_assume_role.json
  description        = "IRSA role used by the OpenTelemetry collector for metrics/logs/traces"

  tags = local.common_tags
}

resource "aws_iam_policy" "observability_permissions" {
  name        = "${var.cluster_name}-observability"
  description = "Permissions for the OTel collector to push telemetry to AWS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "cloudwatch:PutMetricData",
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "aps:RemoteWrite"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "observability_attach" {
  role       = aws_iam_role.observability_irsa.name
  policy_arn = aws_iam_policy.observability_permissions.arn
}
