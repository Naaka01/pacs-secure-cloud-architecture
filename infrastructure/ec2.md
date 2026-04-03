# EC2 Instance Configuration

## Bastion Host

| Parameter | Value |
|---|---|
| Name | Bastion Host |
| AMI | Ubuntu 24.04 LTS |
| Instance type | t3.micro |
| Subnet | Public-Subnet |
| Auto-assign public IP | Enabled |
| Key pair | Required (store `.pem` securely, never commit) |

### Security Group — Bastion

| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | Your admin IP only (`x.x.x.x/32`) |

> **Important:** Never use `0.0.0.0/0` as the SSH source. Always restrict to your specific IP address.

### IAM Role
Attach role: `RoleIAM_BastionServerPrive`
Policy: `CloudWatchAgentServerPolicy`

---

## App Server (Private Instance)

| Parameter | Value |
|---|---|
| Name | Private-Server |
| AMI | Ubuntu 24.04 LTS |
| Instance type | t3.micro |
| Subnet | Private-Subnet |
| Auto-assign public IP | Disabled |
| Key pair | Same key pair as Bastion |

### Security Group — Private Server

| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | Bastion private IP (`10.0.2.248/24`) |
| HTTP | TCP | 80 | Bastion private IP (`10.0.2.248/24`) |

### IAM Role
Attach role: `RoleIAM_BastionServerPrive`
Policy: `CloudWatchAgentServerPolicy`

---

## Connecting via PuTTY (SSH Tunnel)

### Step 1 — Connect to Bastion
1. Open PuTTY
2. Host: Bastion public IP, Port: `22`
3. Go to **SSH > Auth > Credentials** → load your `.ppk` key file
4. Login as: `ubuntu`

### Step 2 — Set up SSH Tunnel to Private Instance
1. In PuTTY, go to **SSH > Tunnels**
2. Source port: `2222`
3. Destination: `10.0.1.235:22` (private instance IP)
4. Click **Add**, then **Open**

### Step 3 — Connect to Private Instance
Open a second PuTTY session:
- Host: `localhost`, Port: `2222`
- Same `.ppk` key
- Login as: `ubuntu`

---

## EBS Encryption

Volumes are encrypted using a snapshot-based approach:
1. Create a snapshot of the existing unencrypted volume
2. Copy the snapshot with encryption enabled (KMS key: `aws/ebs`)
3. Create a new volume from the encrypted snapshot
4. Attach the encrypted volume to the instance (device: `/dev/sda1`)

> New instances should have encryption enabled at launch to avoid this extra step.
