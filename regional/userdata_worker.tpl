#!/bin/bash
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYI4tfQ9YpTPSxh8bgLnPiSi2qU99LST0l9zeUnRsD8YqDUdxDoem4x/lVRxaUHr1c4VJTzF0iZ1gUGxXcsmPKnCJRpLS4/Q+hqmiRh+Gj+j+F6Z6ZPuafHKz3VTtG9BUHuYp4KOl4LvOxE1OxaJJVm16T1EFxsKIeL8FLDtS8XpbzukmDvv9KKfix04u6NDGeBRsDvpLLkEmhG9bukWDWCkDgh0DBAqkXxNvIbv4PkUjFHrb3ZevPtl/4toD8IC3vISe2xfy2R8nrnhBV/3lY+ynP3hdBaM8HM3iWbdQX1BhThUHtY4SrEwdMe2h7G3Qag1i4IgQkyR5aaa5HEeQE+nfx+jkj8aYIpj7UBE4LBPO77YALiEJYxwcfF/3w6wATJylioLeDi6wqNCatitgqDpMYvddZdkkBd1eEDQV7U2IOfv6B8qTbnOaf7g11IVtd1ptwwNTHIxgh/NP/35M2ufHsEjNQ5/zTkMxdNAUyUx3yeAP4vlUJZ9EioWaIbjRzQfhVoZUH6XHAW/orkEFnZACwtI/NNvOzDADnMD1MfH/nqjyrqTcV0UtHXNGDgY0IdERb4fC0chc1z6rtJTC+NAmiNVoa6Km3kKZa1YP014H61ISG4IxOmxatyzvQn0JI5jORoDM4baE0M+zsOY2J69lGMeu6boeRPni7T8tC4w== praffa@mediamath.com" > /home/ec2-user/.ssh/authorized_keys

node_name=$(cat /etc/hostname)
k3s_master_secret=$(aws secretsmanager get-secret-value --secret-id ${secretsmanager_secret_id} --region ${region} --query 'SecretString' --output text)
master_private_ip=$(echo $k3s_master_secret | awk '{print $1}')
token=$(echo $k3s_master_secret | awk '{print $2}')
curl -sfL https://get.k3s.io | K3S_TOKEN=$token K3S_URL=https://$master_private_ip:6443 K3S_KUBECONFIG_MODE="644" K3S_NODE_NAME=$node_name sh -s