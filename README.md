# EEO Case Management Demo

# Purpose
Demonstrates Salesforce's capability to manage Federal Equal Employment Opportunity (EEO) complaint processes using out-of-box functionality.
Presented to EEOC on December 2, 2024 by Phesheya Nxumalo, Lois Collins, and Paul Brown.

# Solution Overview
- Standard Case object configuration for pre-complaints through Administrative Judge (AJ) hearings
- Role-based security model aligned with agency requirements
- Document management with federal records compliance
- Process automation using standard workflow tools

# Development Setup

## Prerequisites
1. Install Python 3.8 or later
2. Install Salesforce CLI
3. Enable DevHub in your production org
4. Install CumulusCI:
    pip install cumulusci

\
## DevHub Setup
1. Authenticate to your DevHub:
    sf org login web --set-default-dev-hub

2. Connect CumulusCI to your DevHub:
    cci service connect devhub --project

## Creating Development Environments

### Create a Scratch Org Definition
    cci org scratch dev MyOrgName

### Deploy Metadata and Load Sample Data
    cci flow run dev_org --org MyOrgName

### Open Org in Browser
    cci org browser MyOrgName

# Additional Resources
- [CumulusCI Documentation](https://cumulusci.readthedocs.io/en/latest/config.html)