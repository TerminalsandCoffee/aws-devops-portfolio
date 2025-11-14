# Cutover Runbook – RDS MySQL → Aurora

1. Confirm replication is healthy.
2. Place RDS into read-only mode.
3. Wait for replication to reach zero lag.
4. Update Route 53 CNAME to point to Aurora.
5. Validate app connectivity and basic queries.