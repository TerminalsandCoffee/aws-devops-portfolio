# Rollback Runbook – Aurora → RDS

1. Identify reason for rollback (performance, errors, app failures).
2. Flip Route 53 CNAME back to the RDS endpoint.
3. Validate app connectivity.
4. Plan follow-up actions to re-attempt migration.