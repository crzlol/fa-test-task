# FA test task

## Prerequisites
You should setup AWS configuration for your account, which will used by terraform.
Your account must have administrative permissions.
You should install `aws-cli`, `kubectl` and `wrk` utilities.

## How to create infrastructure for test task:

```bash
terraform init
terraform apply --auto-approve
```

## How to check HPA and cluster autoscaling:
##### Get EKS config and run highload
```bash
aws eks update-kubeconfig --region eu-north-1 --name fa-test-task
wrk -c 10 -d 5m -t 5 $(terraform output -raw alb_url) > /dev/null &
```

##### Now we can check HPA:
```bash
kubectl get hpa
```
We will see increased number of replicas (>1).

##### Right after HPA works we can check cluster autoscaler:
```bash
kubectl get nodes
```
We will see increased number of nodes (>1).

# Known bugs
Coredns EKS addon status is degraded for some reason right after cluster deployment. It works actually, but degraded status brakes terraform running. If you face this problem, just ignore it.
