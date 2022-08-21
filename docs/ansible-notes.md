# Ansible notes

TODO some tasks we might want:
1. Update VPN server
2. Add peer
3. Get peer configuration

TODO install ansible:

```bash
pip install -r requirements.txt
```

TODO discover and group AWS instances:

```bash
# --list gives full instance metadata; useful for debugging.
ansible-inventory -i discover.aws_ec2.yaml --list
# --graph gives summarized output in tree format.
ansible-inventory -i discover.aws_ec2.yaml --graph
```

TODO run site configuration:

```bash
ansible-playbook -i discover.aws_ec2.yaml site.yaml
```
