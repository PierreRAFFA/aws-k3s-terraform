#cloud-config
write_files:
-   content: |
      ---
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: cloud-controller-manager
        namespace: kube-system
      ---
      apiVersion: rbac.authorization.k8s.io/v1beta1
      kind: ClusterRole
      metadata:
        name: system:cloud-controller-manager
        labels:
          kubernetes.io/cluster-service: "true"
      rules:
      - apiGroups:
        - ""
        resources:
        - nodes
        verbs:
        - '*'
      - apiGroups:
        - ""
        resources:
        - nodes/status
        verbs:
        - patch
      - apiGroups:
        - ""
        resources:
        - services
        verbs:
        - list
        - watch
        - patch
      - apiGroups:
        - ""
        resources:
        - services/status
        verbs:
        - update
        - patch
      - apiGroups:
        - ""
        resources:
        - events
        verbs:
        - create
        - patch
        - update
      # For leader election
      - apiGroups:
        - ""
        resources:
        - endpoints
        verbs:
        - create
      - apiGroups:
        - ""
        resources:
        - endpoints
        resourceNames:
        - "cloud-controller-manager"
        verbs:
        - get
        - list
        - watch
        - update
      - apiGroups:
        - ""
        resources:
        - configmaps
        verbs:
        - create
      - apiGroups:
        - ""
        resources:
        - configmaps
        resourceNames:
        - "cloud-controller-manager"
        verbs:
        - get
        - update
      - apiGroups:
        - ""
        resources:
        - serviceaccounts
        verbs:
        - create
      - apiGroups:
        - ""
        resources:
        - secrets
        verbs:
        - get
        - list
      - apiGroups:
        - "coordination.k8s.io"
        resources:
        - leases
        verbs:
        - get
        - create
        - update
        - list
      # For the PVL
      - apiGroups:
        - ""
        resources:
        - persistentvolumes
        verbs:
        - list
        - watch
        - patch
      ---
      kind: ClusterRoleBinding
      apiVersion: rbac.authorization.k8s.io/v1beta1
      metadata:
        name: aws-cloud-controller-manager
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: system:cloud-controller-manager
      subjects:
      - kind: ServiceAccount
        name: cloud-controller-manager
        namespace: kube-system
      ---
      kind: RoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: aws-cloud-controller-manager-ext
        namespace: kube-system
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: Role
        name: extension-apiserver-authentication-reader
      subjects:
      - kind: ServiceAccount
        name: cloud-controller-manager
        namespace: kube-system
      ---
      apiVersion: apps/v1
      kind: DaemonSet
      metadata:
        name: aws-cloud-controller-manager
        namespace: kube-system
        labels:
          k8s-app: aws-cloud-controller-manager
      spec:
        selector:
          matchLabels:
            component: aws-cloud-controller-manager
            tier: control-plane
        updateStrategy:
          type: RollingUpdate
        template:
          metadata:
            labels:
              component: aws-cloud-controller-manager
              tier: control-plane
          spec:
            serviceAccountName: cloud-controller-manager
            hostNetwork: true
            nodeSelector:
              node-role.kubernetes.io/master: "true"
            tolerations:
            - key: node.cloudprovider.kubernetes.io/uninitialized
              value: "true"
              effect: NoSchedule
            - key: node-role.kubernetes.io/master
              operator: Exists
              effect: NoSchedule
            containers:
              - name: aws-cloud-controller-manager
                image: kmcgrath/cloud-provider-aws:latest
    path: /k8s_yaml/cloud_provider_aws.yaml
runcmd:
 - [ sh, -c, "echo \"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYI4tfQ9YpTPSxh8bgLnPiSi2qU99LST0l9zeUnRsD8YqDUdxDoem4x/lVRxaUHr1c4VJTzF0iZ1gUGxXcsmPKnCJRpLS4/Q+hqmiRh+Gj+j+F6Z6ZPuafHKz3VTtG9BUHuYp4KOl4LvOxE1OxaJJVm16T1EFxsKIeL8FLDtS8XpbzukmDvv9KKfix04u6NDGeBRsDvpLLkEmhG9bukWDWCkDgh0DBAqkXxNvIbv4PkUjFHrb3ZevPtl/4toD8IC3vISe2xfy2R8nrnhBV/3lY+ynP3hdBaM8HM3iWbdQX1BhThUHtY4SrEwdMe2h7G3Qag1i4IgQkyR5aaa5HEeQE+nfx+jkj8aYIpj7UBE4LBPO77YALiEJYxwcfF/3w6wATJylioLeDi6wqNCatitgqDpMYvddZdkkBd1eEDQV7U2IOfv6B8qTbnOaf7g11IVtd1ptwwNTHIxgh/NP/35M2ufHsEjNQ5/zTkMxdNAUyUx3yeAP4vlUJZ9EioWaIbjRzQfhVoZUH6XHAW/orkEFnZACwtI/NNvOzDADnMD1MfH/nqjyrqTcV0UtHXNGDgY0IdERb4fC0chc1z6rtJTC+NAmiNVoa6Km3kKZa1YP014H61ISG4IxOmxatyzvQn0JI5jORoDM4baE0M+zsOY2J69lGMeu6boeRPni7T8tC4w== praffa@mediamath.com\" > /home/ec2-user/.ssh/authorized_keys" ]
 - |
    yum update -y
    yum install docker -y
    service docker start
    usermod -a -G docker ec2-user
 - |
    curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_NAME=${cluster_id} sh -s server --docker --disable-cloud-controller \
      --disable servicelb \
      --disable local-storage \
      --disable traefik \
      --kubelet-arg="cloud-provider=external" \
      --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
 - [kubectl, apply, -f, /k8s_yaml/cloud_provider_aws.yaml]
 - curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
 -
   - helm
   - --kubeconfig
   - /etc/rancher/k3s/k3s.yaml
   - install
   - aws-ebs-csi-driver
   - --set
   - enableVolumeScheduling=true
   - --set
   - enableVolumeResizing=true
   - --set
   - enableVolumeSnapshot=true
   - --set
   - cloud-provider=external
   - https://github.com/kubernetes-sigs/aws-ebs-csi-driver/releases/download/v0.5.0/helm-chart.tgz
 - [sleep, 90]
 - kubectl patch node $(hostname) -p '{"spec":{"unschedulable":true}}}']
 - |
    token=$(cat /var/lib/rancher/k3s/server/node-token) && \
    master_private_ip=$(ifconfig | grep eth0 -A 1 | grep inet | awk '{print $2}') && \
    aws secretsmanager put-secret-value --secret-id ${secretsmanager_secret_id} --secret-string "$master_private_ip $token" --region ${region}
