# Kubernetes Homelab Build Documentation

## Cluster Initialization

1.  (MANUAL) Identified available hardware: 3 laptops, 1 desktop, 1 Chromebook, and components for 2 additional desktops
2.  (MANUAL) Installed server rack (repurposed metal shelving)
3.  (MANUAL) Assembled first desktop node (azrock) without issues
4.  (MANUAL) Assembled second desktop node (gigabyte) - required ad-hoc repairs to power switch assembly
5.  (MANUAL) Selected Debian 13 as standardized OS for cluster consistency and maintainability
6.  (MANUAL) Prepared bootable USB installation media (15MB drive with Debian 13 ISO)
7.  (MANUAL) Installed Debian 13 on all nodes via USB boot
8.  (MANUAL) Abandoned Chromebook (only ARM-based system, would need separate ISO, limited capability), proceeded with six nodes
9.  (MANUAL) Configured SSH access on each node for remote management
10. (MANUAL) Implemented static IP addressing across all nodes using netplan
11. (MANUAL) Resolved node suspension/sleep issues through power management configuration
12. (MANUAL) Built ansible inventory and python script to apply playbooks locally
13. (ANSIBLE) Verified cluster connectivity using ansible playbook
14. (ANSIBLE) Upgraded all nodes using ansible playbook
15. (ANSIBLE) Installed UFW and configured required kubernetes ports on control plane and worker nodes using ansible playbook
16. (ANSIBLE) Installed container runtime (containerd) using ansible playbook
17. (BASH) Verified network interface configuration and connectivity using bash script
18. (ANSIBLE) Disabled swap across all cluster nodes using ansible playbook
19. (ANSIBLE) Installed kubeadm, kubelet, and kubectl on all nodes using ansible playbook
20. (BASH) Verified unique MAC addresses and product UUIDs across all nodes using bash script
21. (ANSIBLE) Initialized control plane, installed Calico CNI and Custom Resource Definitions, and joined worker nodes using ansible playbook

## Cluster Configuration

1. (TERRAFORM) Installed argocd using Terraform.
2. (BASH) Created self-signed TLS cert for cluster using bash.
3. (TERRAFORM) Created Kubernetes TLS secret with self-signed cert using Terraform.
4. (ANSIBLE) Updated kube-proxy ConfigMap to comply with MetalLB prerequisites.
5. (TERRAFORM) Created namespace for MetalLB.
6. (ANSIBLE) Created ArgoCD application for MetalLB, applied manifests for IPAdressPools and L2Advertisements, configuring single static IP for load balancing.
7. (TERRAFORM) Created K8s secrets for Traefik dashboard authentication and local TLS.
8. (ANSIBLE) Created ArgoCD application for Traefik, applied manifests for HTTPRoute and ReferenceGrant to expose ArgoCD dashboard.
9. (ANSIBLE) Created ArgoCD application for Kube-Prometheus Stack (Prometheus, Grafana & AlertManager) to enable telemetry, monitoring, and observability.
10. (ANSIBLE) Updated UFW Firewall playbook to ensure ports for HTTP Traffic, Calico processes, and Prometheus Node Exporter are open.
