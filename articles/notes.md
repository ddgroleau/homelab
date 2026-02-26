# Kubernetes Homelab Build Documentation

## Build Process

1. (MANUAL) Identified available hardware: 3 laptops, 1 desktop, 1 Chromebook, and components for 2 additional desktops
2. (MANUAL) Installed server rack (repurposed metal shelving)
3. (MANUAL) Assembled first desktop node (azrock) without issues
4. (MANUAL) Assembled second desktop node (gigabyte) - required ad-hoc repairs to power switch assembly
5. (MANUAL) Selected Debian 13 as standardized OS for cluster consistency and maintainability
6. (MANUAL) Prepared bootable USB installation media (15MB drive with Debian 13 ISO)
7. (MANUAL) Installed Debian 13 on all nodes via USB boot
8. (MANUAL) Abandoned Chromebook (only ARM-based system, would need separate ISO, limited capability), proceeded with six nodes
9. (MANUAL) Configured SSH access on each node for remote management
10. (MANUAL) Implemented static IP addressing across all nodes using netplan
11. (MANUAL) Resolved node suspension/sleep issues through power management configuration
12. (MANUAL) Built ansible inventory and python script to apply playbooks locally
13. (AUTOMATED) Verified cluster connectivity using ansible playbook
14. (AUTOMATED) Upgraded all nodes using ansible playbook
15. (AUTOMATED) Installed UFW and configured required kubernetes ports on control plane and worker nodes using ansible playbook
16. (AUTOMATED) Installed container runtime (containerd) using ansible playbook
17. (AUTOMATED) Verified network interface configuration and connectivity using bash script
18. (AUTOMATED) Disabled swap across all cluster nodes using ansible playbook
19. (AUTOMATED) Installed kubeadm, kubelet, and kubectl on all nodes using ansible playbook
20. (AUTOMATED) Verified unique MAC addresses and product UUIDs across all nodes using bash script
