# k8s-lab-automation-
K8s automation
after running of **TF code login to master node** run below comands

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

Login to **worker Node-0**
chnage host name
#sudo hostnamectl set-hostname worker0
Copy the common.sh script into worker and run it
token is saved on in /tmp find it if not use the below commands to create or saw existing tokens

kubeadm token list
kubeadm token create
kubeadm token create --print-join-command

# sudo kubeadm join <masternode>:6443 --token g3gx0f.pt2q7qygwmmsex5n --discovery-token-unsafe-skip-ca-verification

**Scenario 1: Remove a worker node from the cluster (recommended)**
**Step 1: On the Control Plane**

See the nodes:

#kubectl get nodes

**Drain the node (safely move workloads away):**

#kubectl drain <worker-node-name> --ignore-daemonsets --delete-emptydir-data

Example:

#kubectl drain worker1 --ignore-daemonsets --delete-emptydir-data

**Delete the node from the cluster:**

# kubectl delete node <worker-node-name>

Example:

# kubectl delete node worker1
**Step 2: On the Worker Node**

Reset the Kubernetes configuration:

$ sudo kubeadm reset -f

Clean CNI configuration:

$sudo rm -rf /etc/cni/net.d

(Optional) Remove kubeconfig:
rm -rf $HOME/.kube

**Scenario 2: The node never joined successfully**

If the worker never joined because kubeadm join failed, then you do not need to delete it from the control plane.

Just run:

$ sudo kubeadm reset -f

Then fix the issue and run kubeadm join again.
Check if the node exists
On the control plane:

# kubectl get nodes

If you see:
NAME      STATUS
master    Ready
worker1   NotReady

**Then delete it**:

# kubectl delete node worker1

If you don't see worker1, then it never joined successfully, so you only need to reset it on the worker.
I have one question for you
When you run:

# kubectl get nodes

