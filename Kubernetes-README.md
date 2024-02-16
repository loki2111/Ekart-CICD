# Kubernetes Installation Guide

## Building a Kubernetes 1.26.5v Cluster with kubeadm
**Step 1: Pre-configure Nodes**
**Run on Master and Worker Nodes**
Kubernetes does require to disable swap memory, because the Kubernetes scheduler determines the best available node on which to deploy newly created pods. If memory swapping is allowed to occur on a host system, this can lead to performance and stability issues within Kubernetes. For this reason, Kubernetes requires that you disable swap in the host system.
```bash
sudo swapoff -a
```

To disable swap after server restart, in other terms, to persist the swap disable in the node, execute bellow command as well
```bash
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```
**Step 2: Setup and Install Packages**

ssh into each node and create containerd configuration file by executing the below command. This command will instruct the node to load overlay and br_netfilter kernal modules**
```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

We have to restart nodes to load them. Instead of restarting, run the below commands to load modules immediately
```bash
sudo modprobe overlay 
sudo modprobe br_netfilter
```

Then set these system configurations for Kubernetes networking
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

Apply those settings by executing the below command
```bash
sudo sysctl --system
```
**Step 3: Install Docker or Containered and configure**

Now install containerd
```bash
sudo apt-get update && sudo apt-get install -y docker.io
```

Inside the /etc folder, create a configuration file for containerd and generate the default configuration file
```bash
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
```

Now restart containerd to ensure new configuration file usage
```bash
sudo systemctl restart containerd
```
**Step 4: Kubernetes component Installation**

let’s install dependency packages
```bash
sudo apt-get install -y apt-transport-https ca-certificates curl
```

Then download and add the GPG key
```bash
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
```

Add Kubernetes to the repository list
```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Update package listings
```bash
sudo apt-get update
```

Install Kubernetes packages (Note: If you get a dpkg lock message, just wait few minutes before trying the command again)
```bash
sudo apt install -y kubelet=1.26.5-00 kubeadm=1.26.5-00 kubectl=1.26.5-00
```

Turn off automatic updates
```bash
sudo apt-mark hold kubelet kubeadm kubectl
```

**Run on Master node only**
**Step 5: Initialize the Cluster**
This only needs to perform on the control plane node only. (If you have multiple control plane nodes, do the same)
```bash
sudo kubeadm init --pod-network-cidr 192.168.0.0/16
```


Set kubectl access
```bash
mkdir -p $HOME/.kube
sudo cp -I /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Test access to cluster
```bash
kubectl version
```


**Step 6: Install Calico Network Add-On Tigera**
Calico provides a simple, high-performance, secure networking. Calico is trusted by the major cloud providers, with EKS, AKS, GKE, and IKS all having integrated Calico as part of their offerings.
On the control plane node, install Calico networking
```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
```

Check the status of calico components
```bash
kubectl get pods -n kube-system
```

**Step 7: Join the worker nodes to the Cluster**

In the control plane node, create the token and copy the kubeadm join command (The join command can also be found in the output from kubeadm init command)
```bash
kubeadm token create --print-join-command
```

In worker nodes, paste the kubeadm join command to join the cluster
```bash
sudo kubeadm join <join command from previous command>
```

Now you can view the cluster status in the control plane node
```bash
kubectl get nodes
```

Ingress Congtroller (baremetal)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.0/deploy/static/provider/baremetal/deploy.yaml
```


# Kubernetes 1.20V


## Building a Kubernetes 1.20v Cluster with kubeadm
**Step 1: Pre-configure Nodes**
**Run on Master and Worker Nodes**
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```
**Step 2: Setup and Install Packages**

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

```bash
sudo modprobe overlay 
sudo modprobe br_netfilter
```

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

```bash
sudo sysctl --system
```
**Step 3: Install Docker or Containered and configure**

```bash
sudo apt-get update && sudo apt-get install -y docker.io
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
```
**Step 4: Kubernetes component Installation**

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
```

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```

```bash
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

```bash
sudo apt-get update
```

```bash
sudo apt-get install -y kubelet=1.20.1-00 kubeadm=1.20.1-00 kubectl=1.20.1-00
```

```bash
sudo apt-mark hold kubelet kubeadm kubectl
```

**Run on Master node only**
**Step 5: Initialize the Cluster**
This only needs to perform on the control plane node only. (If you have multiple control plane nodes, do the same)
```bash
sudo kubeadm init --pod-network-cidr 192.168.0.0/16
```

Set kubectl access
```bash
mkdir -p $HOME/.kube
sudo cp -I /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```bash
kubectl version
```


**Step 6: Install Calico Network Add-On**

**On the control plane node, install Calico networking**
```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

```bash
kubectl get pods -n kube-system
```

**Step 7: Join the worker nodes to the Cluster**

In the control plane node, create the token and copy the kubeadm join command (The join command can also be found in the output from kubeadm init command)
```bash
kubeadm token create --print-join-command
```

In worker nodes, paste the kubeadm join command to join the cluster
```bash
sudo kubeadm join <join command from previous command>
```

Now you can view the cluster status in the control plane node
```bash
kubectl get nodes
```

Ingress Congtroller (baremetal)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.0/deploy/static/provider/baremetal/deploy.yaml
```

### Commands

Here are some essential Kubernetes commands for managing your deployments:
``` bash
   kubectl get nodes
   kubectl get all
   kubectl get ns
   kubectl get deploy
   kubectl get svc
   kubectl get pods -l <label=selector>
   kubectl describe <pod-name>
   kubectl describe deploy <deployment-name>
   kubectl logs <pod-name>
   kubectl edit deploy <deployment-name>
   kubectl scale --replicas==4 rs <replicaset-name>
   kubectl set image deployment/<deployment-name> <container-name/image-name>=<new-image-name-or updated version>
   kubectl apply <manifests file name>
   kubectl apply -f .
   helm install <name-for-deployment> .
   helm uninstall <name-of-deployment>
   helm list
```