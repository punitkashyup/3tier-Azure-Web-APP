# 3-Tier Web Application Architecture on Azure

## Overview

This document provides a detailed description of the architecture for the 3-tier web application deployed on Azure. The architecture is designed to be secure, highly available, and scalable.

## Architecture Diagram

![WEBAPP-CAPTURE](https://github.com/Armandkeza/N-tier-Azure-Web-APP/assets/4728642/1da6aa3a-c8c1-47ee-9de1-0a39bdffdd6e)

## Components

### Networking

#### Virtual Network
- **Name**: Webapp-Vnet
- **Address Space**: 10.1.0.0/16
- **Region**: Canada Central

#### Subnets
- **Frontend Subnet**: 10.1.0.0/24
  - Hosts the frontend virtual machines
  - Connected to Application Gateway

- **Backend Subnet**: 10.1.1.0/24
  - Hosts the backend virtual machines
  - Connected to internal Load Balancer

- **Application Gateway Subnet**: 10.1.2.0/24
  - Dedicated subnet for Application Gateway

- **Azure Firewall Subnet**: 10.1.3.0/24
  - Dedicated subnet for Azure Firewall (AzureFirewallSubnet)

- **Azure Bastion Subnet**: 10.1.9.0/27
  - Dedicated subnet for Azure Bastion (AzureBastionSubnet)

- **PostgreSQL Subnet**: 10.1.10.0/24
  - Dedicated subnet for PostgreSQL Flexible Server
  - Has service endpoints for Microsoft.Storage

### Frontend Tier

#### Application Gateway
- **SKU**: WAF_v2
- **Tier**: WAF_v2
- **Capacity**: 2
- **Zones**: 1, 2 (Zone redundant)
- **WAF Policy**: Configured to protect against OWASP Top 10 vulnerabilities
- **Listeners**: HTTP on port 80
- **Backend Pool**: Connected to Frontend VMSS

#### Frontend Virtual Machine Scale Set
- **VM Size**: Standard_F2
- **Instances**: 2 (minimum), auto-scaling based on CPU usage
- **Zones**: 1, 2 (Zone redundant)
- **OS**: Ubuntu 20.04 LTS
- **Identity**: User-assigned managed identity for Storage Account access

### Backend Tier

#### Internal Load Balancer
- **SKU**: Standard
- **Type**: Internal
- **Backend Pool**: Connected to Backend VMSS
- **Health Probe**: HTTP on port 80

#### Backend Virtual Machine Scale Set
- **VM Size**: Standard_F2
- **Instances**: 2 (minimum), auto-scaling based on CPU usage
- **Zones**: 1, 2 (Zone redundant)
- **OS**: Ubuntu 20.04 LTS

### Database Tier

#### PostgreSQL Flexible Server
- **Version**: 13
- **SKU**: GP_Standard_D2s_v3
- **Storage**: 32 GB
- **Backup Retention**: 7 days
- **High Availability**: Zone-redundant with synchronous replication
- **Connectivity**: Private access via VNET integration

### Storage

#### Storage Account
- **Type**: Standard StorageV2
- **Replication**: Zone-redundant storage (ZRS)
- **Access**: Private (no public access)
- **Container**: webappmedia (for application media files)
- **Connectivity**: Private Endpoint from Frontend subnet

### Security Components

#### Web Application Firewall (WAF)
- **Mode**: Prevention
- **Rule Set**: OWASP 3.2
- **Custom Rules**: IP-based blocking and request inspection

#### Azure Firewall
- **SKU**: Premium
- **Policy**: Allow outbound DNS and web traffic, block malicious categories

#### Network Security Groups
- Applied to Application Gateway subnet
- Rules to allow HTTP (80) and Gateway communication (65200-65535)

#### Private DNS Zones
- **PostgreSQL**: webapp.postgres.database.azure.com
- **Storage**: webapp.blob.core.windows.net

#### Azure Bastion
- Secure administrative access to VMs
- No public IP addresses on VMs

#### Managed Identity
- User-assigned identity for Frontend VMSS
- Permissions to read/write to Storage Container

## Communication Flow

1. **End User to Application**:
   - User connects to Application Gateway public IP
   - WAF inspects traffic for malicious patterns
   - Request is forwarded to Frontend VMSS

2. **Frontend to Backend**:
   - Frontend servers process the request
   - If backend processing is needed, request goes to Internal Load Balancer
   - Load Balancer distributes to Backend VMSS

3. **Backend to Database**:
   - Backend servers connect to PostgreSQL via private endpoint
   - Connection stays within VNET (no internet traversal)

4. **Frontend to Storage**:
   - Frontend servers access Storage Account via private endpoint
   - Managed Identity provides authentication

5. **Outbound Internet Access**:
   - All outbound traffic from Frontend and Backend goes through Azure Firewall
   - Firewall filters traffic based on policy

## High Availability and Disaster Recovery

- **Zone Redundancy**: All components deployed across 2 Availability Zones
- **Auto-scaling**: VMSS scales based on load
- **Load Balancing**: Traffic distributed across instances
- **Database Replication**: Synchronous replication between zones
- **Storage Redundancy**: Zone-redundant storage for data durability

## Security Measures

- **Network Isolation**: Separate subnets for each tier
- **Traffic Inspection**: WAF and Firewall inspect traffic
- **Private Access**: No direct internet access to backend services
- **Managed Identities**: No stored credentials for service access
- **Bastion Access**: Secure administrative access

## Scalability

- **Horizontal Scaling**: VMSS auto-scaling for Frontend and Backend
- **Vertical Scaling**: Database and VM sizes can be adjusted
- **Independent Scaling**: Each tier can scale independently

## Monitoring and Management

- **Azure Monitor**: For performance monitoring
- **Auto-scale Rules**: Based on CPU metrics
- **Diagnostic Logs**: For troubleshooting and auditing

## Cost Optimization

- **Auto-scaling**: Scale down during low usage periods
- **Reserved Instances**: For predictable workloads
- **Right-sizing**: Appropriate VM sizes for workload

## Deployment and Updates

- **Infrastructure as Code**: Terraform for deployment
- **Immutable Infrastructure**: Replace rather than modify
- **Blue-Green Deployments**: For zero-downtime updates