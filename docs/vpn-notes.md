# VPN notes

We use Wireguard to provide VPN access.

## Docker

To ensure that Wireguard would fit our use case, we tested locally with docker.
There is a convenient docker container for Wireguard at [linuxserver/wireguard](https://hub.docker.com/r/linuxserver/wireguard).
While the documentation is not extensive, there are only a few parameters that
require tuning, and after some trial and error we successfully set up a VPN
through the container. A good resource for configuring this docker image is
available [on YouTube](https://www.youtube.com/watch?v=GZRTnP4lyuo).

We will keep ephemeral configuration at `/tmp/wireguard-config`. Create the
directory with the following.

```bash
mkdir /tmp/wireguard-config
```

Below is the docker command we used to launch the VPN server with 1 peer.

```bash
docker run -d \
  --rm \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e PEERS=leo_mac \
  -e SERVERURL=0.0.0.0 \
  -e SERVERPORT=51820 \
  -e INTERNAL_SUBNET=10.13.13.0 \
  -e PEERDNS=auto \
  -p 51821:51820/udp \
  -v /tmp/wireguard-config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  linuxserver/wireguard
```

Documentation for the additional capabilities can be found on [the docker run page](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).
You can also find more detailed notes on Linux capabilities in [the man pages](https://man7.org/linux/man-pages/man7/capabilities.7.html).
`NET_ADMIN` allows a process to configure network settings, and `SYS_MODULE`
allows a process to load kernel modules. We also set the UID and GID--these are
arbitrary; the purpose is to ensure that they have access to the volume mount
for the Wireguard configurations. The timezone is arbitrary. `PEERS` is either
a number or a list of strings representing the clients. I have simply created
one peer configuration for myself in this case. `SERVERURL` is either a domain
name or IP address at which the server will listen. It can also be set to
`auto`, in which case it will default to the host's public IP address. In a LAN
setting, that address would be the gateway, which is not suitable without
configuring the gateway router. Using `0.0.0.0` causes the container to listen
on the host's network interfaces. You can also set the address to your PC's
private address, like `192.168.1.241`, but this address cannot be used by
clients in other LANs. `SERVERPORT` determines the port on which the server
will listen in the container, default `51820` for Wireguard. `INTERNAL_SUBNET`
specifies the subnet for communication between VPN peers, and `10.13.13.0/24`
is the reasonable default to avoid collisions. `PEERDNS` allows you to
configure a DNS server that is not the gateway. We forward to the container
port `51821` to `51820` since our client will run on our host at `51820`. We
then add two volume mounts, the first for the location of client configurations--for
testing, we have this set to `/tmp/wireguard-config` on the host, but we would
want to write the configurations to somewhere persistent in case the container
fails (in Kubernetes, we would use a persistent volume). The second volume
mount provides the container access to kernel modules on the host. Finally, we
set `net.ipv4.conf.all.src_valid_mark=1`. The container documentation does not
specify the reason for this action, but it clearly has something to do with
IPv4 networking.

Before continuing, verify that you cannot reach the VPN server by running the
following. All packets should be dropped.

```bash
ping 10.13.13.1
```

Now, check `/tmp/wireguard-config`. The container should have written server
and client configuration files to the directory. Our client configuration is
at `/tmp/wireguard-config/peer_leo_mac/peer_leo_mac.conf` (there is also a QR
code version at `/tmp/wireguard-config/peer_leo_mac/peer_leo_mac.png`). We have
to make one small change to this configuration, and only because our machine is
both server and client. Under `[Peer]`, change the endpoint to use the port we
are forwarding to the docker container: `Endpoint = 0.0.0.0:51821`.

```bash
# Change the server port.
vim /tmp/wireguard-config/peer_leo_mac/peer_leo_mac.conf
```

Lastly, turn on Wireguard with the following.

```bash
# This command may differ slightly by OS.
sudo wg-quick up /tmp/wireguard-config/peer_leo_mac/peer_leo_mac.conf
```

Confirm that the client can reach the server.

```bash
ping 10.13.13.1
```

You can also see that the transfer was successful by running `wg`:

```bash
sudo wg
```

Now, tear down the Wireguard VPN.

```bash
# This command may differ slightly by OS.
sudo wg-quick down /tmp/wireguard-config/peer_leo_mac/peer_leo_mac.conf
```

## Kubernetes

We successfully added the container and a service to back it in our Kubernetes
deployment. There were a few configuration changes of note.

### Minikube

In minikube, to give the container the correct permissions, you need to run
`minikube start --extra-config="kubelet.allowed-unsafe-sysctls=net.ipv4.ip_forward"`.
After some testing, we also found that `minikube service wireguard --url` would
set up a port on the host listening on TCP, not UDP. This appears to be an open
issue (technically closed because it was marked stale) in minikube, available
[here](https://github.com/kubernetes/minikube/issues/12362). While it did
appear possible to use another driver and some addons to get the connection
from outside the cluster to the VPN working, we did not attempt that
workaround. We did, however, add a client in the cluster that we configured in
much the same way as described above, using for the endpoint in the client
configuration the cluster IP of the service. The connection from inside the
cluster was successful, although using the DNS name of the service as the
endpoint did not work. This success led us to believe that the issues with
routing to the cluster were a product of minikube, and so we moved on to AWS
and Terraform.

## Terraform

We tried to deploy the VPN on EKS, but the effort required to allow a pod to make
VPN configurations was beyond the scope of this project. In particular, to
allow the `net.ipv4.ip_forward` unsafe sysctl, you need to launch the kubelet
on each EKS node (that you would like to be able to serve this kind of pod,
which could be restricted with taints or labels) with an extra argument.
Terraform allows you to supply extra arguments in a launch template that calls
the kubelet bootstrap directly--a workflow that already seems brittle. However,
to change the launch template, you need to provide a custom AMI in a registry
that is accessible from your VPC. S3 is one way to store those AMIs. [This stack overflow post](https://stackoverflow.com/questions/68092279/fixing-datadog-agent-congestion-issues-in-amazon-eks-cluster)
shows a possible Terraform workflow to achieve the desired kubelet configuration. I was not
certain how difficult it would be to create a new AMI, nor how much it would
cost, so I chose to create a standalone EC2 instance in the VPC for Wireguard,
recognizing that VPN resiliency would be degraded slightly.

The EC2 instance, named "bulwark", runs the Wireguard Docker container. It uses
the AWS instance metadata endpoint (`http://169.254.169.254/latest/meta-data/`)
to get its public IP address. My Macbook's SSH key is built in for instance
SSH, but `aws_key_pair.bulwark_ssh_key.public_key` in `vpn.tf` could be
modified to use any other key pair that is more convenient. After applying the
EKS Terraform plan, SSH into bulwark to get the client configuration.

```bash
ssh ubuntu@<bulwark-public-ip>
cat /etc/wireguard/peer_leo_mac/peer_leo_mac.conf
```

While you are SSH'd into bulwark, you can view the logs for the bootstrap with
the following command.

```bash
less /var/log/cloud-init-output.log
```

You can also check that the Wireguard server is running using the following.

```bash
sudo docker ps
```

Copy the configuration file to the client machine, say at
`/tmp/wireguard-ec2/peer_leo_mac.conf`. Then turn on the VPN.

```bash
sudo wg-quick up /tmp/wireguard-ec2/peer_leo_mac.conf
```

Now try pinging either the peer IP or the private IP address of the EC2
instance.

```bash
ping 10.13.13.1
ping <server-private-ip>
```

If you've also applied the Kubernetes Terraform configuration, you can reach
internal services directly through the VPN since you are in the same VPC.
First, get an internal pod IP address--we will use the web server. Then, ping
that pod's internal IP.

```bash
kubectl get pods
# Find the address in 10.0.0.0/16 in the kubectl describe output.
kubectl describe pod <populare-xxxxx-xxxxx>
ping <internal-ip>
```

Tear down the VPN with the following.

```bash
sudo wg-quick down /tmp/wireguard-ec2/peer_leo_mac.conf
```
