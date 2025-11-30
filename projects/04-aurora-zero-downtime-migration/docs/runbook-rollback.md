# Rollback Runbook: Aurora MySQL → RDS MySQL

**Objective**: Revert traffic back to the original RDS MySQL instance in case of critical failure on Aurora.
**Condition**: This is only possible if the RDS Source was **not** written to after cutover, OR if you accept data loss (writes made to Aurora will be lost unless reverse replication was set up).

## Triggers for Rollback
- [ ] Application cannot connect to Aurora.
- [ ] High latency or performance degradation > 50%.
- [ ] Data corruption or missing data detected immediately post-cutover.

## Step 1: Assess State
1.  **Check Writes**: Have users written new data to Aurora?
    *   **No**: Safe to rollback immediately.
    *   **Yes**: **STOP**. Rolling back will cause data loss. Decision required by Engineering Lead.

## Step 2: Execute Rollback (DNS Revert)
1.  **Update Route 53**:
    *   Go to Route 53 Console > Hosted Zone `eduphoria.ex`.
    *   Edit Record `db.eduphoria.ex`.
    *   **Change Value**: From `aurora-cluster-endpoint` to `rds-source-endpoint`.
    *   Save Record.

## Step 3: Re-Enable Writes on Source
1.  **Turn off Read-Only** (if enabled):
    ```sql
    SET GLOBAL read_only = OFF;
    UNLOCK TABLES;
    ```

## Step 4: Validation
1.  **Flush DNS**: `ipconfig /flushdns`.
2.  **Verify Connection**: Ensure `db.eduphoria.ex` resolves to RDS IP.
3.  **App Health**: Verify application is functional and stable on the old database.

## Step 5: Post-Mortem
1.  Capture logs from Aurora (CloudWatch) for analysis.
2.  Document the root cause of the failure.
3.  Plan a new migration window.