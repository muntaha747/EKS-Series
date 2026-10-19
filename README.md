# EKS-Series: Private EKS Cluster on AWS with Terraform, VPN and RBAC

This project builds a **private Amazon EKS cluster** on AWS using **Terraform**, and runs everything through **GitHub Actions** (no AWS access keys, it signs in with OIDC).

The cluster has no public endpoint. You reach it only through an **AWS Client VPN** that uses certificate login. A separate IAM user (`Hassan`) gets limited access inside the cluster using **Kubernetes RBAC**.

---

## What gets built

| Part | What it is |
|------|------------|
| Network | VPC (`10.0.0.0/16`), public and private subnets, internet gateway, NAT gateways, route tables |
| EKS | Cluster `Dev-YT-Performance-Cluster` in `us-east-1`, private API endpoint only, access entries (API auth mode) |
| Nodes | Managed node group, `t3.medium`, ON_DEMAND, 1 to 10 nodes |
| VPN | AWS Client VPN with certificate login, split tunnel, client range `10.100.0.0/22` |
| Certificates | CA, server and client certificates created by Terraform and stored in ACM |
| Security | VPN security group allowed on port 443 of the cluster security group |
| IAM | Cluster role, node role, user `Hassan`, and role `Hassan-eks-iam-role` |
| RBAC | `ClusterRole` and `ClusterRoleBinding` for the group `hassan-devops` |
| State | Terraform state in an S3 backend with state locking |

> `us-east-1e` is left out of the zone list because the EKS control plane does not support it.

---

## Project layout

```
EKS-Series/
├── .github/workflows/
│   ├── Infra-Automation.yaml      # plan, apply, connect to VPN, apply RBAC
│   └── Terraform-Destroy.yaml     # tear the infrastructure down
├── Kubernetes-Manifest-File/
│   └── rbac.yaml                  # ClusterRole + ClusterRoleBinding
└── Terraform/
    ├── Calling-Modules/           # root module (run Terraform from here)
    │   ├── main.tf
    │   ├── Remote-Backend.tf
    │   ├── Terraform.tf
    │   ├── Variables.tf
    │   └── test.tfvars
    └── Modules/                   # the reusable module
        ├── VPC.tf
        ├── EKS.tf
        ├── IAM.tf
        ├── ACM.tf
        ├── ca_key&ca_crt.tf
        ├── Client-VPN.tf
        └── Variables.tf
```

---

## How access works

```
Your laptop --(VPN, certificate)--> VPC --(port 443)--> EKS API

IAM user "Hassan"
   --assumes--> role "Hassan-eks-iam-role"
   --EKS access entry--> Kubernetes group "hassan-devops"
   --RBAC (rbac.yaml)--> what that group may do in the cluster
```

- **Authentication** (who you are) comes from IAM. The `Hassan` user can only switch into the Hassan role.
- **Authorization** (what you may do) comes from RBAC. The role is placed in the group `hassan-devops`, and `rbac.yaml` decides what that group can do.
- The AWS account root user has cluster admin through its own access entry. The pipeline role is admin because it created the cluster.

### What the `hassan-devops` group can do

| Resource | Allowed |
|----------|---------|
| Nodes, namespaces | view |
| Pods, pod logs, services, configmaps | view, create, update, delete |
| Deployments, replicasets, statefulsets, daemonsets | view, create, update, delete |

Everything else is denied. Edit `Kubernetes-Manifest-File/rbac.yaml` to change this.

---

## CI/CD pipeline (`Infra-Automation.yaml`)

| Event | What runs |
|-------|-----------|
| Pull request to `main` | `terraform fmt -check` and `terraform plan` |
| Push to `main` | `terraform apply` (needs approval on the **Prod** environment), then VPN connect, then `kubectl apply` of the RBAC file |

The workflow signs in to AWS with **OIDC**, so no access keys are stored in GitHub.

### GitHub secrets you need

| Secret | What it holds |
|--------|---------------|
| `AWS_ROLE_ARN` | The IAM role the workflow assumes through OIDC |
| `VPN_CONFIG_B64` | Your VPN `.ovpn` file (with client cert and key added), base64 encoded |

If you set the same secret name on the **Prod** environment, that one wins over the repository secret.

### Create or refresh `VPN_CONFIG_B64`

1. In the AWS console, go to **VPC, then Client VPN endpoints**, select the endpoint, and click **Download client configuration**.
2. Open the `.ovpn` file and add the client certificate and key at the bottom:

   ```
   <cert>
   (contents of the client certificate)
   </cert>

   <key>
   (contents of the client private key)
   </key>
   ```

3. Encode it and copy it (Mac):

   ```bash
   base64 -i downloaded-client-config.ovpn | tr -d '\n' | pbcopy
   ```

4. Paste it into the secret in GitHub (Settings, Secrets and variables, Actions).

> **Important:** Terraform creates new certificates every time the infrastructure is rebuilt from scratch. After any rebuild, repeat these steps, or the VPN step in the pipeline will fail.

---

## Connect to the cluster from your computer

1. Connect to the **VPN** with the AWS VPN Client, using the `.ovpn` file above.
2. Set up the `Hassan` AWS profile with the access key created for that user:

   ```bash
   aws configure --profile Hassan
   ```

3. Create a profile that switches into the Hassan role:

   ```bash
   aws configure set role_arn arn:aws:iam::<ACCOUNT_ID>:role/<HASSAN_ROLE_NAME> --profile hassan-role
   aws configure set source_profile Hassan --profile hassan-role
   aws configure set region us-east-1 --profile hassan-role
   ```

   Find the role name in the IAM console. It starts with `Hassan-eks-iam-role-` and ends in a random number.

4. Connect `kubectl` to the cluster:

   ```bash
   aws eks update-kubeconfig --name Dev-YT-Performance-Cluster --region us-east-1 --profile hassan-role
   ```

5. Check that it works:

   ```bash
   kubectl get nodes
   kubectl auth can-i create deployments    # yes
   kubectl auth can-i delete nodes          # no
   ```

---

## Running Terraform by hand

Normally the pipeline does this. To run it yourself:

```bash
cd Terraform/Calling-Modules
terraform init
terraform plan  -var-file="test.tfvars"
terraform apply -var-file="test.tfvars"
```

Settings such as the region, CIDR ranges, node sizes and VPN range live in `test.tfvars`.

---

## Tear it down

Run the **Terraform-Destroy** workflow, or run this locally:

```bash
cd Terraform/Calling-Modules
terraform destroy -var-file="test.tfvars"
```

Before you destroy, delete any access keys that were created by hand in the IAM console. AWS refuses to delete a user while a key is still attached, and Terraform only knows about the keys it created.

> This setup costs money while it runs (EKS control plane, NAT gateways, nodes, VPN endpoint). Destroy it when you are not using it.

---

## Security notes

- Never commit `client.key`, `ca.key`, `server.key` or the `certs/` folder. Add them to `.gitignore`.
- Never print private keys in workflow logs. Base64 is encoding, not encryption.
- The VPN is protected by its client certificate and key. Anyone who has both can connect, so keep them private.
- A security group on the VPN controls what connected users can reach. It does not control who can connect.

---

## Common problems

| Problem | Cause and fix |
|---------|---------------|
| `base64: invalid input` in the pipeline | `VPN_CONFIG_B64` is empty or not valid base64. Create it again as shown above. |
| `kubectl` cannot find or reach the cluster | The VPN is not connected, or the VPN endpoint has no DNS server set (`dns_servers` on the endpoint). |
| `AccessDenied` on `eks:DescribeCluster` | You used the `Hassan` profile directly. Use the `hassan-role` profile, which switches into the role. |
| `nodes is forbidden` | The role has no permission for nodes. Check `rbac.yaml` and that the access entry has `kubernetes_groups = ["hassan-devops"]`. |
| Security group cannot be deleted for 15 minutes | EKS fixes a cluster's extra security group at creation. Changing it means the cluster must be replaced. |
| `InvalidPermission.Duplicate` on an egress rule | AWS already adds an allow-all outbound rule to every new group. Remove the duplicate rule from Terraform. |
| `kubectl apply` cannot find `rbac.yaml` | In the workflow the path is `../../Kubernetes-Manifest-File/rbac.yaml`, relative to `Terraform/Calling-Modules`. |

---

## Tools and versions

- Terraform `1.16.6`
- AWS provider `~> 6.69.1`
- GitHub Actions with AWS OIDC
- OpenVPN client on the runner (connects to AWS Client VPN)
- `kubectl` and AWS CLI