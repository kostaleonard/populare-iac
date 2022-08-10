module "wireguard" {
  source  = "vainkop/wireguard/aws"
  version = "1.3.0"

  region = "us-east-2"
  ssh_key_id = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTQwGhjFRWQccBre/mDCMo7rWmFlyVJ+i+1iFjUpF4t kostaleonard@gmail.com"
  subnet_ids = data.terraform_remote_state.populare_workspace_state.outputs.vpc_public_subnets
  vpc_id = data.terraform_remote_state.populare_workspace_state.outputs.vpc_id
  use_ssm = false
  wg_server_private_key = var.wg_server_private_key
  wg_server_net = "10.8.0.1/24"
  wg_clients = [
    {
      friendly_name = "leo_mac"
      public_key = "HCfcAdzG++jOLvHh14/ofBKKJJMvTt9Logz2tyNapEM="
      client_ip = "10.8.0.2/32"
    }
  ]
}