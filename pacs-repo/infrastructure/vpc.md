# VPC and Subnet Configuration

## VPC

| Parameter | Value |
|---|---|
| Name | Secure-Project-VPC |
| CIDR Block | 10.0.0.0/16 |
| DNS Resolution | Enabled |
| DNS Hostnames | Enabled |

**Steps:**
1. Go to **VPC > Your VPCs > Create VPC**
2. Select **VPC only**
3. Name: `Secure-Project-VPC`
4. IPv4 CIDR: `10.0.0.0/16`
5. Click **Create VPC**

> Note: The VPC is regional by nature — subnets can be spread across multiple Availability Zones within the same region.

---

## Subnets

### Public Subnet

| Parameter | Value |
|---|---|
| Name | Public-Subnet |
| CIDR Block | 10.0.2.0/24 |
| Availability Zone | eu-north-1a (or your region's AZ) |
| Auto-assign public IP | Enabled |

**Purpose:** Hosts the Bastion Host and NAT Gateway. Has a route to the Internet Gateway.

### Private Subnet

| Parameter | Value |
|---|---|
| Name | Private-Subnet |
| CIDR Block | 10.0.1.0/24 |
| Availability Zone | eu-north-1a (same AZ as public subnet) |
| Auto-assign public IP | Disabled |

**Purpose:** Hosts the application server (EC2 + Nginx). No direct route to the internet — only outbound via NAT Gateway.

**Steps (for each subnet):**
1. Go to **VPC > Subnets > Create Subnet**
2. Select `Secure-Project-VPC`
3. Enter subnet name, AZ, and CIDR block
4. Click **Create Subnet**

---

## Internet Gateway

| Parameter | Value |
|---|---|
| Name | Secure-IGW |
| Attached to VPC | Secure-Project-VPC |

**Steps:**
1. Go to **VPC > Internet Gateways > Create Internet Gateway**
2. Name: `Secure-IGW`
3. After creation, select it > **Actions > Attach to VPC**
4. Select `Secure-Project-VPC`

---

## NAT Gateway

| Parameter | Value |
|---|---|
| Name | NAT-Gtw |
| Subnet | Public-Subnet |
| Connectivity type | Public |
| Elastic IP | Automatically allocated |

**Purpose:** Allows instances in the private subnet to initiate outbound connections to the internet (e.g. for `apt update`) without being reachable from the internet.

**Steps:**
1. Go to **VPC > NAT Gateways > Create NAT Gateway**
2. Select `Public-Subnet`
3. Connectivity: **Public**
4. Elastic IP: **Allocate**
5. Click **Create NAT Gateway**

> Wait for status to become **Available** before proceeding to route table configuration.
