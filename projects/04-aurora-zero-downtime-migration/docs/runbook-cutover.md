# Cutover Runbook: RDS MySQL → Aurora MySQL

**Objective**: Switch application traffic from RDS MySQL (Source) to Aurora MySQL (Target) with near-zero downtime.
**Estimated Downtime**: < 30 seconds (DNS propagation).

## Prerequisites
- [ ] **Replication Health**: DMS task status is "Load complete, replication ongoing".
- [ ] **Lag Check**: `SecondsBehindMaster` is 0 (or < 1s).
- [ ] **Access**: Verify you have access to AWS Console (Route 53, RDS) and MySQL client.

## Step 1: Prepare for Cutover
1.  **Notify Stakeholders**: Send notification that cutover is starting.
2.  **Stop Writes (Optional but Recommended)**:
    *   If possible, put the application in maintenance mode.
    *   Alternatively, set RDS Source to Read-Only:
        ```sql
        FLUSH TABLES WITH READ LOCK;
        SET GLOBAL read_only = ON;
        ```

## Step 2: Verify Data Sync
1.  **Check DMS Task**: Ensure no pending changes.
2.  **Row Count Validation**:
    *   Run `scripts/validate_migration.py` (if available) or manually check key tables:
        ```sql
        SELECT COUNT(*) FROM users; -- Run on Source
        SELECT COUNT(*) FROM users; -- Run on Target
        ```

## Step 3: Execute Cutover (DNS Flip)
1.  **Update Route 53**:
    *   Go to Route 53 Console > Hosted Zone `eduphoria.ex`.
    *   Edit Record `db.eduphoria.ex`.
    *   **Change Value**: From `rds-source-endpoint` to `aurora-cluster-endpoint`.
    *   **TTL**: Ensure it is set to 60s or lower.
    *   Save Record.

## Step 4: Post-Cutover Validation
1.  **Flush DNS**: `ipconfig /flushdns` (Windows) or `sudo killall -HUP mDNSResponder` (macOS).
2.  **Verify Connection**:
    ```bash
    nslookup db.eduphoria.ex
    # Should return the Aurora IP/Endpoint
    ```
3.  **Application Check**:
    *   Login to the application.
    *   Perform a write operation (e.g., create a dummy user).
    *   Verify the data appears in Aurora.

## Step 5: Cleanup (After 24h)
1.  Stop DMS Replication Task.
2.  Snapshot RDS Source (Final Backup).
3.  Terminate RDS Source (if no rollback needed).