# Employee Attendance Application – Azure DevOps + ACR + AKS

This project contains a Flask attendance application, automated tests, a Dockerfile, Kubernetes manifests, modular Terraform infrastructure, and an Azure DevOps pipeline. The image is built remotely by Azure Container Registry Tasks (`az acr build`); Docker Desktop is not required on the developer laptop.

## Repository structure

```text
Employee-Attendance-AKS-Complete/
├── app.py
├── requirements.txt
├── requirements-dev.txt
├── Dockerfile
├── .dockerignore
├── .gitignore
├── templates/
│   ├── index.html
│   └── records.html
├── tests/
│   └── test_app.py
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── azure-pipelines.yml
└── terraform/
    ├── provider.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    ├── main.tf
    ├── outputs.tf
    └── modules/
        ├── resource-group/
        ├── vnet/
        ├── acr/
        └── aks/
```

## Application details

- Flask entry point: `app.py`; listens on port `5000`.
- Health endpoint: `/health`.
- Attendance records page: `/records`.
- Database: SQLite file `attendance.db`.
- Container startup: `python app.py` (no Gunicorn).

## 1. Local Python setup (Docker not required)

Run these commands from the repository root in PowerShell. If script activation is blocked by the machine's execution policy, use the direct `.venv\Scripts\python.exe` commands shown below instead of changing a permanent policy.

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m pip install -r requirements-dev.txt
python -m pytest -v
python app.py
```

If PowerShell blocks activation, for the current terminal session only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\.venv\Scripts\Activate.ps1
```

Or skip activation:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -m pytest -v
.\.venv\Scripts\python.exe app.py
```

Open `http://localhost:5000`, then check `/health` and `/records`.

## 2. Provision Azure infrastructure with Terraform

See `terraform/README.md`. The Terraform root calls modules to create:

- Resource Group
- Virtual Network and AKS subnet
- Azure Container Registry (ACR) Basic
- AKS cluster with a system node pool and a separate user node pool
- `AcrPull` role assignment for the AKS kubelet managed identity

Before applying, configure Azure CLI authentication, copy `terraform.tfvars.example` to `terraform.tfvars`, enter your subscription ID and a globally unique ACR name, and review `terraform plan`. Node VMs, disks, networking and ACR incur charges. Check regional VM quota and SKU availability. Do not commit `terraform.tfvars` or Terraform state.

## 3. Azure DevOps pipeline setup

1. Push this project to your GitHub repository.
2. Create an Azure DevOps pipeline from that repository and select `azure-pipelines.yml`.
3. Create one Azure Resource Manager service connection to the subscription.
4. Grant the service connection identity the required permissions: permission to run ACR Tasks/build and push images to the registry, and permission to deploy to the AKS cluster. The exact Azure roles depend on your subscription's RBAC model; use least privilege.
5. Update the pipeline variables at the top of `azure-pipelines.yml`:
   - `REPLACE_WITH_AZURE_RM_SERVICE_CONNECTION`
   - `REPLACE_WITH_GLOBALLY_UNIQUE_ACR_NAME`
   - `REPLACE_WITH_GLOBALLY_UNIQUE_ACR_NAME.azurecr.io`
6. Confirm the resource group and AKS cluster names match the Terraform values.
7. Run the pipeline from `main`.

### Pipeline workflow

- Installs Python dependencies on the Microsoft-hosted Ubuntu agent.
- Runs `pytest`.
- On `main` only, invokes `az acr build` through `AzureCLI@2`. ACR Tasks builds the Docker image in Azure and stores it in ACR; no Docker Desktop or local Docker daemon is used.
- On `main` only, deploys the image to AKS using `KubernetesManifest@1`.

Pull-request runs execute tests but do not build/push the image or deploy to AKS.

## 4. Access the application

The Kubernetes Service is initially `ClusterIP`. For a temporary test after deployment, obtain cluster credentials and use port forwarding:

```powershell
az aks get-credentials --resource-group rg-employee-attendance --name aks-employee-attendance
kubectl port-forward -n attendance-app service/attendance-app-service 8080:80
```

Open `http://localhost:8080`. This port-forward requires `kubectl` on your machine, but does not require Docker Desktop. For public access, configure an ingress controller or an appropriate LoadBalancer service; `k8s/ingress.yaml` alone does not install an ingress controller.

## Important SQLite limitation

SQLite data is stored in the container filesystem. It is not shared between pods and may be lost when a pod is replaced. The Deployment intentionally starts with one replica for learning. Before scaling or production use, move the database to durable storage or a managed database such as Azure SQL, and configure backups and secrets.

## Cost and cleanup

AKS worker nodes, disks, load balancer/networking resources, and ACR can incur charges even when AKS Free management tier is selected. Use the Azure Pricing Calculator and review actual deployed SKUs. When finished, review the correct Terraform workspace/state and `terraform plan -destroy` before destroying resources. Check the Resource Group afterwards for any separately created resources.
