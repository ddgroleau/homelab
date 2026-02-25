# Kubernetes Homelab Build Documentation

## Build Process

1. Identified available hardware: 3 laptops, 1 desktop, 1 Chromebook, and components for 2 additional desktops
2. Installed server rack (repurposed metal shelving)
3. Assembled first desktop node (azrock) without issues
4. Assembled second desktop node (gigabyte) - required ad-hoc repairs to power switch assembly
5. Selected Debian 13 as standardized OS for cluster consistency and maintainability
6. Prepared bootable USB installation media (15MB drive with Debian 13 ISO)
7. Installed Debian 13 on all nodes via USB boot
8. Abandoned Chromebook (only ARM-based system, would need separate ISO, limited capability), proceeded with six nodes
9. Configured SSH access on each node for remote management
10. Verified cluster connectivity via bootstrap script in bootstrap-nodes directory
11. Resolved node suspension/sleep issues through power management configuration
12. Implemented static IP addressing across all nodes using netplan
13. Installed container runtime (containerd) via automated script
14. Verified network interface configuration and connectivity
15. Opened required ports for Kubernetes control plane and worker nodes via firewall scripts
16. Disabled swap across all cluster nodes via automation script
17. Installed kubeadm, kubelet, and kubectl on all nodes via deployment script
18. Verified unique MAC addresses and product UUIDs across all nodes using dedupe_nodes.sh script
19. Referenced Kubernetes official documentation for installation procedures
