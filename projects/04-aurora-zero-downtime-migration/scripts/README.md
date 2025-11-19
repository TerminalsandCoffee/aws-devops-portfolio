# Scripts Directory

This directory contains automation scripts for the Aurora Zero-Downtime Migration project, organized by scripting language.

## Directory Structure

```
scripts/
├── bash/          # Bash shell scripts
├── powershell/    # PowerShell scripts
└── python/        # Python scripts
```

## Why Multiple Implementations?

This project includes implementations in **Bash**, **PowerShell**, and **Python** to:

- **Demonstrate versatility**: Show proficiency across different scripting languages
- **Cross-platform support**: Enable execution on Linux/macOS (Bash), Windows (PowerShell), and any platform (Python)
- **Team flexibility**: Accommodate different team preferences and tooling environments
- **Portfolio showcase**: Highlight multi-language capabilities in a DevOps context

## Scripts Overview

### Migration Scripts

These scripts handle the core migration operations:

| Script | Description | Available In |
|--------|-------------|--------------|
| `check-replication-status` | Verify replication state between RDS and Aurora | Bash, Python |
| `cutover-to-aurora` | Perform controlled cutover from RDS to Aurora | Bash, Python |
| `rollback-to-rds` | Rollback from Aurora back to RDS | Bash, Python |

### Utility Scripts

| Script | Description | Available In |
|--------|-------------|--------------|
| `render-diagram` | Render Mermaid diagrams to PNG | PowerShell, Python |
| `create-project04-aurora-zero-downtime-migration` | Bootstrap project structure | PowerShell |

## Usage

### Bash Scripts

```bash
# Make scripts executable
chmod +x bash/*.sh

# Run a script
./bash/check-replication-status.sh
```

### PowerShell Scripts

```powershell
# Run a script
.\powershell\render-diagram.ps1 diagrams\aurora-zero-downtime-migration.mmd
```

### Python Scripts

```bash
# Make scripts executable (Linux/macOS)
chmod +x python/*.py

# Run a script
python python/check_replication_status.py --rds-instance-id <id> --aurora-cluster-id <id>

# Or with Python module
python -m python.check_replication_status --rds-instance-id <id> --aurora-cluster-id <id>
```

## Requirements

### Python Scripts

- Python 3.7+
- Dependencies (install from `python/requirements.txt`):
  ```bash
  pip install -r python/requirements.txt
  ```

### PowerShell Scripts

- PowerShell 5.1+ or PowerShell Core 7+
- For `render-diagram.ps1`: mermaid-cli (npm)
  ```bash
  npm install -g @mermaid-js/mermaid-cli
  ```

### Bash Scripts

- Bash 4.0+
- AWS CLI configured

## Notes

- All scripts are currently **placeholder implementations** for demonstration purposes
- In production, these would include:
  - Full AWS API integration
  - Error handling and retry logic
  - Logging and monitoring
  - Validation and safety checks
  - Rollback capabilities

## Python Scripts Structure

The Python scripts share common utilities in `python/utils.py`:
- AWS client creation helpers
- Consistent error handling
- Logging configuration
- Credential validation

## Contributing

When adding new scripts:
1. Add implementations to all three language folders if applicable
2. Keep functionality consistent across implementations
3. Update this README with new script documentation
4. Include proper error handling and usage examples
5. For Python scripts, use utilities from `utils.py` to maintain consistency

