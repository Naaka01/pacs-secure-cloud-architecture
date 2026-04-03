# Route Tables Configuration

## Public Route Table (Public-RT)

Associated with: **Public-Subnet**

| Destination | Target | Purpose |
|---|---|---|
| 10.0.0.0/16 | local | Internal VPC traffic |
| 0.0.0.0/0 | Internet Gateway (Secure-IGW) | Internet access |

**Steps:**
1. Go to **VPC > Route Tables > Create Route Table**
2. Name: `Public-RT`, VPC: `Secure-Project-VPC`
3. After creation, click **Edit Routes**
4. Add route: Destination `0.0.0.0/0` → Target: your Internet Gateway
5. Go to **Subnet Associations** → associate with `Public-Subnet`

---

## Private Route Table (Private-RT)

Associated with: **Private-Subnet**

| Destination | Target | Purpose |
|---|---|---|
| 10.0.0.0/16 | local | Internal VPC traffic |
| 0.0.0.0/0 | NAT Gateway (NAT-Gtw) | Outbound internet (no inbound) |

**Steps:**
1. Create route table: `Private-RT`, VPC: `Secure-Project-VPC`
2. Click **Edit Routes**
3. Add route: Destination `0.0.0.0/0` → Target: your NAT Gateway
4. Go to **Subnet Associations** → associate with `Private-Subnet`

---

## Key Concept

The critical difference between the two route tables:

- **Public-RT** routes `0.0.0.0/0` to the **Internet Gateway** → two-way internet traffic
- **Private-RT** routes `0.0.0.0/0` to the **NAT Gateway** → outbound only, instances are not reachable from the internet
