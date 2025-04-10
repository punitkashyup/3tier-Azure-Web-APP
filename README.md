# Securing a 3-Tier Webapp on Azure

## Overview

This project deploys a secure 3-tier web application on Azure, consisting of Frontend, Backend, and Database infrastructure. The architecture follows best practices for security, high availability, and scalability.

![WEBAPP-CAPTURE](https://github.com/punitkashyup/3tier-Azure-Web-APP/assets/infra.png)

## Architecture

### Frontend Tier
- Application Gateway with Web Application Firewall (WAF)
- Frontend servers in auto-scaling groups across 2 Availability Zones
- WAF policies to inspect and block malicious traffic

### Backend Tier
- Backend servers in a dedicated subnet with Network Security Group
- Azure Load Balancer for high availability
- Auto-scaling configured across 2 Availability Zones

### Database Tier
- PostgreSQL database configured across 2 Availability Zones
- Primary-standby design with synchronous replication
- VNET integration for secure connectivity

### Storage
- Azure Storage Container for multimedia files
- Private Link for secure connectivity from Frontend subnet

### Security Features
- Private DNS zones for private connectivity to PaaS services
- Managed Identity for Frontend VM to access Storage Account
- Azure Bastion for secure administrative access
- Azure Firewall for filtering outbound traffic

## Project Structure

```
3tier-Azure-Web-APP/
├── README.md                  # Project documentation
├── main.tf                    # Main Terraform configuration
├── variable.tf                # Input variables
├── output.tf                  # Output values
├── provider.tf                # Provider configuration
├── modules/                   # Modularized components
│   ├── networking/            # Network-related resources
│   ├── compute/               # VM and VMSS resources
│   ├── security/              # Security-related resources
│   ├── database/              # Database resources
│   └── storage/               # Storage resources
└── scripts/                   # Scripts for VM initialization
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or newer)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (latest version)
- Azure subscription

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/punitkashyup/3tier-Azure-Web-APP
cd 3tier-Azure-Web-APP
```

### 2. Configure Azure Authentication

```bash
az login
az account set --subscription "your-subscription-id"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Customize Variables (Optional)

Edit `variable.tf` to customize deployment parameters such as:
- Resource group name and location
- Network address spaces
- VM sizes and counts
- Security settings

### 5. Plan the Deployment

```bash
terraform plan -out=tfplan
```

### 6. Apply the Configuration

```bash
terraform apply tfplan
```

### 7. Access the Application

After deployment completes, you can access the application via the Application Gateway's public IP address, which is displayed in the Terraform outputs.

```bash
terraform output application_gateway_frontend_ip
```

### 8. Clean Up Resources

When you're done, you can destroy all resources to avoid incurring costs:

```bash
terraform destroy
```

## Security Considerations

- All sensitive data (passwords, keys) are generated dynamically and stored securely
- Network traffic is isolated between tiers using NSGs
- WAF protects against OWASP Top 10 vulnerabilities
- Private endpoints ensure PaaS services are not exposed to the internet
- Azure Firewall controls outbound traffic

## Maintenance and Updates

- Use Azure Monitor for monitoring the application
- Implement CI/CD pipelines for automated deployments
- Regularly update VM images and security patches

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
