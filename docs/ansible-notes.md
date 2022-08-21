# Ansible notes

We use Ansible to automate routine tasks for some of our services, particularly
those not orchestrated in Kubernetes (although Ansible does provide support for
Kubernetes).

## Installation

We can install Ansible with `pip install ansible`, but we also have some
libraries for autocompletion and the AWS SDK listed in the project
requirements.

```bash
pip install -r requirements.txt
```

## Inventory discovery

Running an Ansible Playbook causes the control node (the computer from which
you are running `ansible`) to SSH into the specified servers and perform some
action. While you can list these server endpoints statically, you can also
automatically discover them. There is an Ansible plugin for discovering EC2
instances that works for our use case.

You can discover AWS instances and display their groups with the following
commands.

```bash
# --list gives full instance metadata; useful for debugging.
ansible-inventory -i discover.aws_ec2.yaml --list
# --graph gives summarized output in tree format.
ansible-inventory -i discover.aws_ec2.yaml --graph
```

## Site configuration

`site.yaml` defines site-level configuration. Because we have done most of the
configuration with Terraform, we use the Ansible site configuration to automate
checks on VPN server health; we do not make significant changes to the server
state (we may cause the docker service to start if it was stopped). Run the
site configuration with the following command.

```bash
ansible-playbook -i discover.aws_ec2.yaml site.yaml
```

## Retrieving VPN peer configurations

Another task that we automate with Ansible is the retrieval of VPN peer
configurations. As mentioned in #39, adding peers can be easily accomplished
using `terraform apply`, so here we focus on providing a way to get VPN
configurations without using SSH manually. The following command retrieves the
default VPN client configuration.

```bash
# The peer configuration is downloaded to /tmp/.
ansible-playbook -i discover.aws_ec2.yaml get_vpn_peer_config.yaml
```

If you would like to retrieve the configuration of a different user, use the
`--extra-vars` flag to specify the peer name.

```bash
ansible-playbook -i discover.aws_ec2.yaml get_vpn_peer_config.yaml --extra-vars "peer_name=peer_leo_mac"
```
