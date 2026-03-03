# Spare Parts - A Kubernetes Homelab | Part 1: Bootstrapping the Cluster

_This is Part 1 of the "Spare Parts" series, where I detail my journey in creating a [Kubernetes](https://kubernetes.io/) homelab. You can find the GitHub repository for this project [here](https://github.com/ddgroleau/homelab)._

_This article was published programmatically using [Python](https://www.python.org/) and the [Forem API](https://developers.forem.com/api/v1)._

<hr/>
<br>

**Nodes are ready, pods are running!**

I embarked on my journey a few weeks ago, hoping to achieve a respectable nerd milestone: get a Kubernetes homelab on bare metal running in my house.

This series will read less like a technical manual and more like a story; my intention is to simply detail the planning and execution of standing up my own Kubernetes homelab. If you'd like to build your own homelab, there are free resources available across the web; the [r/homelab](https://www.reddit.com/r/homelab/) subreddit is a great place to get started.

**What is a Homelab?** To me, a homelab is an isolated environment that can be used to test, learn, and experiment with hardware, physical and/or virtual machines, storage, software, and networking.

**What is a Kubernetes cluster?** A Kubernetes cluster is a set of physical or virtual machines that are grouped together to provide an environment to run containerized applications.

I am a full-time software engineer, whose main craft has been web-application development. However, I've found that my programming passions are more DevOps-related; in my free-time, I've always sought out infrastructure related projects: building desktops and laptops from scratch, running containers in the cloud, building complex CI/CD pipelines, and writing automations & command line utilities.

I felt like this project was the next logical step: I've torn down and rebuilt the old computers in my house numerous times; I'm running a production Kubernetes cluster in the cloud on the [Linode Kubernetes Engine](https://techdocs.akamai.com/cloud-computing/docs/linode-kubernetes-engine); I've installed most of the popular Linux distributions on desktops and laptops, including Arch from scratch (I use Arch btw 😉). A Kubernetes homelab to me seemed to tie this experience together in something challenging and tangible.

I am far from a DevOps, SysAdmin, or Infrastructure expert, I discovered many tools along the way and have learned a lot so far. If you identify something in my process that I could have done better, or have recommendations for me, feel free to react out to me via [email](mailto:ddgroleau.developer@gmail.com).

<br>

## The Cluster Initialization Process

### Step 1: Find Some Hardware

A few desktop cases; a plastic bin with motherboards, graphics cards, RAM sticks, HDDs; a few old laptops and an old chromebook. This was my initial collection of "spare parts" I found to start my homelab journey.

I started by building two desktops with the spare parts I had, and found a third in working order. The laptops and chromebook were all in working shape; I had one HP machine that I had suped-up with a new motherboard and upgraded RAM last summer. After pulling apart these machines so many times throughout the years, I had to do a bit of ad-hoc electrical work to get some of them running.

At this point, I had seven machines; three desktops, three laptops and a chromebook.

### Step 2: Select an Operating System

After doing some preliminary research (and reflecting on my own preferences), I selected the [Debian](https://www.debian.org/) Linux distribution as the operating system for all the nodes in my homelab. At the time of writing this, all nodes are currently running Debian 13.

I selected Debian because it is relatively lighweight, stable, battle-tested, and the flavor of Linux I am most fond-of and most accustomed to.

I played around with the idea of installing a different distribution on each node, but quickly abandoned the thought when I realized what challenges that might introduce when it came time to automated configuration tasks.

### Step 3: Manually Configure Each Machine

The goal of this step was to get each machine in a state where I could SSH into them and continue bootstrapping processes in an automated way. I downloaded the Debian ISO and loaded it onto a 15MB USB drive, and one by one, I installed the OS and configured SSH access from my development laptop.

I did decide at this point to abandon the chromebook; its ARM chip architecture was not compabily with my AMD64 (x86-64) installation medium. After scouring forumns, it seemed like this chromebook model would also be incompatible with a different Debian 13 ISO out of the box (but I did try wholeheartedly to install Arch Linux on it instead, using an ARM ISO).

One thing I learned along the way is the importance of static IPs: some of my machines initially had their IPs dynamically re-addressed, which caused me to have to log back into them manually, find the network interface card (NIC) IP address, and update the `/etc/hosts` config on my development laptop (I run Pop!\_OS as my daily driver). I ended up setting static IPs on all machines using [netplan](https://netplan.io/).

At this point I had six machines, ready to go. Specs below:

<br>

| Node          | Manufacturer/Model      | Year | Operating System      | Type                   | CPU                           | Cores | Memory | Disk |
| ------------- | ----------------------- | ---- | --------------------- | ---------------------- | ----------------------------- | ----- | ------ | ---- |
| Control Plane | Dell Inc. Inspiron 5567 | 2016 | GNU/Linux (Debian 13) | Laptop                 | Intel Core i5-7200U @ 2.50GHz | 4     | 8Gi    | 1T   |
| Worker 01     | Gigabyte 970A-UD3       | 2011 | GNU/Linux (Debian 13) | Desktop (Custom Build) | AMD FX-4130 Quad-Core         | 4     | 8Gi    | 1T   |
| Worker 02     | Acer Aspire TC-605      | 2014 | GNU/Linux (Debian 13) | Desktop                | Intel Core i5-4440 @ 3.10GHz  | 4     | 8Gi    | 1T   |
| Worker 03     | ASRock Z97M OC Formula  | 2014 | GNU/Linux (Debian 13) | Desktop (Custom Build) | Intel Core i5-4690K @ 3.50GHz | 4     | 24Gi   | 2T   |
| Worker 04     | Apple MacBookAir4,2     | 2011 | GNU/Linux (Debian 13) | Laptop                 | Intel Core i5-2557M @ 1.70GHz | 4     | 4Gi    | 128G |
| Worker 05     | HP Laptop 15-bw0xx      | 2017 | GNU/Linux (Debian 13) | Laptop (Custom Build)  | AMD A12-9720P RADEON R7       | 4     | 16Gi   | 500G |

<br>

### Step 4: Bootstrap the Cluster

I started with what I knew: write a series of bash scripts to verify connectivity, run updates, and install the [prerequisite tools](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) like `kubectl`, `kubeadm` and `kubelet`.

After the scripts were written I did some reflection and decided to check out some popular [configuration management](https://www.redhat.com/en/topics/automation/what-is-configuration-management) tools to improve my process. I decided to rewrite much of what I had already done in bash using [Ansible](https://docs.ansible.com), which proved to be an efficient (and fun!) way to bootstrap the configuration.

I chose [containerd](https://containerd.io/) as the container runtime for my cluster, and began writing Ansible scripts to get my cluster nodes ready for duty. I nominated one node to be my control plane node; this was for ease of cluster initialization (in the future, for high availability, I plan to add additional nodes to the control plane).

The Ansible scripts required some trial and error - I needed to automate firewall setup (I used [UFW](https://www.linux.com/training-tutorials/introduction-uncomplicated-firewall-ufw/)), disable [swap](https://www.kernel.org/doc/gorman/html/understand/understand014.html), install containerd, kubelet, kubeadm, and kubectl. By the end I had knocked out all of the [prerequisites](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for initializing the cluster.

I used a python CLI tool I built to run each Ansible playbook in a slightly more convenient manner than using `ansible-playbook` on the command line (python is new to me as well, I decided to pick it up while learning Ansible).

### Step 5: Initialize the Cluster

So far in part 1, this has been the biggest battle. Not because the initialization process is incredibly complex itself, but I found making it idempotent to be the biggest challenge.

For example, I have an ansible task to run `kubeadm init`, but if something failed downstream, now there are stale config files for Kubernetes and the Container Network Interface (CNI) in many places across my nodes (thankfully, much of this is cleaned up by `kubeadmin reset`).

I also needed to select a networking solution, choosing between [Flannel](https://github.com/flannel-io/flannel), [Calico](https://docs.tigera.io/calico/latest/about), and [Cilium](https://cilium.io/), ultimately selecting Calico. My final Ansible script initialized the cluster, installed Calico and its dependencies (including Custom Resource Definitions), and joined the worker nodes, all in an idempotent manner (allowing me to tear down and reinitialize the cluster with the same script ran multiple times).

Once I ran the final version of my ansible script, I began running a series of `kubectl` commands to check the status of the nodes and their pods. No huge issues; I did have to drain my least powerful node (the 2011 Mac Air, lol) to reassign some important pods to other, more powerful nodes. After that, I got the green light:

**Nodes are ready, pods are running!**

<br>

## Now What?

The cluster is running in my home office on my server rack (some repurposed metal shelving 😉), and my wife reminds me about the electricity bill whenever she walks by.

I am working now to configure networking and security within the cluster, with a goal for all future Infrastructure as Code (IaC) for my homelab to be written in [Terraform](https://developer.hashicorp.com/terraform).

_You can find the GitHub repository for this project [here](https://github.com/ddgroleau/homelab)._

🚀 Stay tuned for Part 2: Cluster Resource Provisioning!

**And thanks for reading 😊**
