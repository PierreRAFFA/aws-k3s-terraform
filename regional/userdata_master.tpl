#!/bin/bash

# Authorise public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYI4tfQ9YpTPSxh8bgLnPiSi2qU99LST0l9zeUnRsD8YqDUdxDoem4x/lVRxaUHr1c4VJTzF0iZ1gUGxXcsmPKnCJRpLS4/Q+hqmiRh+Gj+j+F6Z6ZPuafHKz3VTtG9BUHuYp4KOl4LvOxE1OxaJJVm16T1EFxsKIeL8FLDtS8XpbzukmDvv9KKfix04u6NDGeBRsDvpLLkEmhG9bukWDWCkDgh0DBAqkXxNvIbv4PkUjFHrb3ZevPtl/4toD8IC3vISe2xfy2R8nrnhBV/3lY+ynP3hdBaM8HM3iWbdQX1BhThUHtY4SrEwdMe2h7G3Qag1i4IgQkyR5aaa5HEeQE+nfx+jkj8aYIpj7UBE4LBPO77YALiEJYxwcfF/3w6wATJylioLeDi6wqNCatitgqDpMYvddZdkkBd1eEDQV7U2IOfv6B8qTbnOaf7g11IVtd1ptwwNTHIxgh/NP/35M2ufHsEjNQ5/zTkMxdNAUyUx3yeAP4vlUJZ9EioWaIbjRzQfhVoZUH6XHAW/orkEFnZACwtI/NNvOzDADnMD1MfH/nqjyrqTcV0UtHXNGDgY0IdERb4fC0chc1z6rtJTC+NAmiNVoa6Km3kKZa1YP014H61ISG4IxOmxatyzvQn0JI5jORoDM4baE0M+zsOY2J69lGMeu6boeRPni7T8tC4w== praffa@mediamath.com" > /home/ec2-user/.ssh/authorized_keys

# Install k3s
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s

# Store k3s token and master private ip in Secrets Manager
token=$(cat /var/lib/rancher/k3s/server/node-token)
master_private_ip=$(ifconfig | grep eth0 -A 1 | grep inet | awk '{print $2}')
aws secretsmanager put-secret-value --secret-id ${secretsmanager_secret_id} --secret-string "$master_private_ip $token" --region ${region}