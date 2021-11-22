#!/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/11/03
# @License   :   Mulan PSL v2
# @Desc      :   common function library for service restart of the base images
# #############################################

source "../common/common_lib.sh"

function conf_common() {
  pkg_path=/opt/cfssl.tar.gz
  cfssl_path=/opt/cfssl
  current_path=$(
    cd "$(dirname "$0")" || exit 1
    pwd
  )
  cert_path=/etc/kubernetes/pki
  mkdir -p ${cfssl_path} ${cert_path}
  host_name=$(hostname)
  name_host=k8snode1
  hostname | grep -i ${name_host} || hostnamectl set-hostname ${name_host}
}

function kubernetes_install() {
  DNF_INSTALL "docker conntrack-tools socat kubernetes*" 1
}

function certificate_prepare() {
  wget --no-check-certificate https://github.com/cloudflare/cfssl/archive/v1.5.0.tar.gz -O ${pkg_path}
  test -f ${pkg_path} || {
    LOG_INFO "Download failed!"
    exit 1
  }
  which tar || DNF_INSTALL tar 1
  tar -zxvf ${pkg_path} -C ${cfssl_path} --strip-components=1
  which golang || DNF_INSTALL golang 1
  cd ${cfssl_path} || exit
  make -j6
  cp bin/cfssl* /usr/local/bin/
  cd ${cert_path} || exit
  echo '{
    "signing": {
      "default": {
        "expiry": "8760h"
      },
      "profiles": {
        "kubernetes": {
          "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
          ],
          "expiry": "8760h"
        }
      }
    }
  }' >ca-config.json
  echo '{
    "CN": "Kubernetes",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "HangZhou",
        "O": "openEuler",
        "OU": "WWW",
        "ST": "BinJiang"
      }
    ]
  }' >ca-csr.json
  cfssl gencert -initca ca-csr.json | cfssljson -bare ca
  echo '{
    "CN": "admin",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "HangZhou",
        "O": "system:masters",
        "OU": "Containerum",
        "ST": "BinJiang"
      }
    ]
  }' >admin-csr.json
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
  echo '{
    "CN": "service-accounts",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "HangZhou",
        "O": "Kubernetes",
        "OU": "openEuler k8s install",
        "ST": "BinJiang"
      }
    ]
  }' >service-account-csr.json
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes service-account-csr.json |
    cfssljson -bare service-account
  echo '{
    "CN": "system:kube-controller-manager",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "HangZhou",
        "O": "system:kube-controller-manager",
        "OU": "openEuler k8s kcm",
        "ST": "BinJiang"
      }
    ]
  }' >kube-controller-manager-csr.json
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-controller-manager-csr.json |
    cfssljson -bare kube-controller-manager
  echo '{
    "CN": "system:kube-proxy",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "HangZhou",
        "O": "system:node-proxier",
        "OU": "openEuler k8s kube proxy",
        "ST": "BinJiang"
      }
    ]
  }' >kube-proxy-csr.json
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json |
    cfssljson -bare kube-proxy
  echo '{
    "CN": "system:kube-scheduler",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "HangZhou",
        "O": "system:kube-scheduler",
        "OU": "openEuler k8s kube scheduler",
        "ST": "BinJiang"
      }
    ]
  }' >kube-scheduler-csr.json
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-scheduler-csr.json |
    cfssljson -bare kube-scheduler

  echo '{
    "CN": "system:node:k8snode1",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "HangZhou",
        "O": "system:nodes",
        "OU": "openEuler k8s kubelet",
        "ST": "BinJiang"
      }
    ]
  }' >k8snode1-csr.json
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=k8snode1,127.0.0.1 -profile=kubernetes k8snode1-csr.json |
    cfssljson -bare k8snode1
  echo '{
    "CN": "kubernetes",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "HangZhou",
        "O": "Kubernetes",
        "OU": "openEuler k8s kube api server",
        "ST": "BinJiang"
      }
    ]
  }' >kubernetes-csr.json
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=10.32.0.1,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local -profile=kubernetes kubernetes-csr.json |
    cfssljson -bare kubernetes
  cd "${current_path}" || exit
}

function etcd_install() {
  DNF_INSTALL etcd
  systemctl start etcd
}

function kubeconfig_prepare() {
  cd ${cert_path} || exit
  kubectl config set-cluster openeuler-k8s --certificate-authority=/etc/kubernetes/pki/ca.pem --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=kube-proxy.kubeconfig
  kubectl config set-credentials system:kube-proxy --client-certificate=/etc/kubernetes/pki/kube-proxy.pem --client-key=/etc/kubernetes/pki/kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig
  kubectl config set-context default --cluster=openeuler-k8s --user=system:kube-proxy --kubeconfig=kube-proxy.kubeconfig
  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
  kubectl config set-cluster openeuler-k8s --certificate-authority=/etc/kubernetes/pki/ca.pem --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=kube-controller-manager.kubeconfig
  kubectl config set-credentials system:kube-controller-manager --client-certificate=/etc/kubernetes/pki/kube-controller-manager.pem --client-key=/etc/kubernetes/pki/kube-controller-manager-key.pem --embed-certs=true --kubeconfig=kube-controller-manager.kubeconfig
  kubectl config set-context default --cluster=openeuler-k8s --user=system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig
  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
  kubectl config set-cluster openeuler-k8s --certificate-authority=/etc/kubernetes/pki/ca.pem --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=kube-scheduler.kubeconfig
  kubectl config set-credentials system:kube-scheduler --client-certificate=/etc/kubernetes/pki/kube-scheduler.pem --client-key=/etc/kubernetes/pki/kube-scheduler-key.pem --embed-certs=true --kubeconfig=kube-scheduler.kubeconfig
  kubectl config set-context default --cluster=openeuler-k8s --user=system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig
  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
  kubectl config set-cluster openeuler-k8s --certificate-authority=/etc/kubernetes/pki/ca.pem --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=admin.kubeconfig
  kubectl config set-credentials admin --client-certificate=/etc/kubernetes/pki/admin.pem --client-key=/etc/kubernetes/pki/admin-key.pem --embed-certs=true --kubeconfig=admin.kubeconfig
  kubectl config set-context default --cluster=openeuler-k8s --user=admin --kubeconfig=admin.kubeconfig
  kubectl config use-context default --kubeconfig=admin.kubeconfig
  cd "${current_path}" || exit
}

function apiserver_prepare() {
  echo "kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: $(head -c 32 /dev/urandom | base64)
      - identity: {}" >${cert_path}/encryption-config.yaml
  cat >/etc/kubernetes/apiserver <<EOF
KUBE_ADVERTIS_ADDRESS="--advertise-address=${NODE1_IPV4}"
KUBE_ALLOW_PRIVILEGED="--allow-privileged=true"
KUBE_AUTHORIZATION_MODE="--authorization-mode=Node,RBAC"
KUBE_ENABLE_ADMISSION_PLUGINS="--enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota"
KUBE_SECURE_PORT="--secure-port=6443"
KUBE_ENABLE_BOOTSTRAP_TOKEN_AUTH="--enable-bootstrap-token-auth=true"
KUBE_ETCD_CAFILE="--etcd-cafile=/etc/kubernetes/pki/ca.pem"
KUBE_ETCD_CERTFILE="--etcd-certfile=/etc/kubernetes/pki/kubernetes.pem"
KUBE_ETCD_KEYFILE="--etcd-keyfile=/etc/kubernetes/pki/kubernetes-key.pem"
KUBE_ETCD_SERVERS="--etcd-servers=http://127.0.0.1:2379"
KUBE_CLIENT_CA_FILE="--client-ca-file=/etc/kubernetes/pki/ca.pem"
KUBE_KUBELET_CERT_AUTH="--kubelet-certificate-authority=/etc/kubernetes/pki/ca.pem"
KUBE_KUBELET_CLIENT_CERT="--kubelet-client-certificate=/etc/kubernetes/pki/kubernetes.pem"
KUBE_KUBELET_CLIENT_KEY="--kubelet-client-key=/etc/kubernetes/pki/kubernetes-key.pem"
KUBE_KUBELET_HTTPS="--kubelet-https=true"
KUBE_PROXY_CLIENT_CERT_FILE="--proxy-client-cert-file=/etc/kubernetes/pki/kube-proxy.pem"
KUBE_PROXY_CLIENT_KEY_FILE="--proxy-client-key-file=/etc/kubernetes/pki/kube-proxy-key.pem"
KUBE_TLS_CERT_FILE="--tls-cert-file=/etc/kubernetes/pki/kubernetes.pem"
KUBE_TLS_PRIVATE_KEY_FILE="--tls-private-key-file=/etc/kubernetes/pki/kubernetes-key.pem"
KUBE_SERVICE_CLUSTER_IP_RANGE="--service-cluster-ip-range=10.32.0.0/16"
KUBE_SERVICE_ACCOUNT_ISSUER="--service-account-issuer=https://kubernetes.default.svc.cluster.local"
KUBE_SERVICE_ACCOUNT_KEY_FILE="--service-account-key-file=/etc/kubernetes/pki/service-account.pem"
KUBE_SERVICE_ACCOUNT_SIGN_KEY_FILE="--service-account-signing-key-file=/etc/kubernetes/pki/service-account-key.pem"
KUBE_SERVICE_NODE_PORT_RANGE="--service-node-port-range=30000-32767"
KUB_ENCRYPTION_PROVIDER_CONF="--encryption-provider-config=/etc/kubernetes/pki/encryption-config.yaml"
KUBE_REQUEST_HEADER_ALLOWED_NAME="--requestheader-allowed-names=front-proxy-client"
KUBE_REQUEST_HEADER_EXTRA_HEADER_PREF="--requestheader-extra-headers-prefix=X-Remote-Extra-"
KUBE_REQUEST_HEADER_GROUP_HEADER="--requestheader-group-headers=X-Remote-Group"
KUBE_REQUEST_HEADER_USERNAME_HEADER="--requestheader-username-headers=X-Remote-User"
KUBE_API_ARGS=""
EOF
  echo "[Unit]
Description=Kubernetes API Server
Documentation=https://kubernetes.io/docs/reference/generated/kube-apiserver/
After=network.target
After=etcd.service
[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver
ExecStart=/usr/bin/kube-apiserver \
	    \$KUBE_ADVERTIS_ADDRESS \
	    \$KUBE_ALLOW_PRIVILEGED \
	    \$KUBE_AUTHORIZATION_MODE \
	    \$KUBE_ENABLE_ADMISSION_PLUGINS \
 	    \$KUBE_SECURE_PORT \
	    \$KUBE_ENABLE_BOOTSTRAP_TOKEN_AUTH \
	    \$KUBE_ETCD_CAFILE \
	    \$KUBE_ETCD_CERTFILE \
	    \$KUBE_ETCD_KEYFILE \
	    \$KUBE_ETCD_SERVERS \
	    \$KUBE_CLIENT_CA_FILE \
	    \$KUBE_KUBELET_CERT_AUTH \
	    \$KUBE_KUBELET_CLIENT_CERT \
	    \$KUBE_KUBELET_CLIENT_KEY \
	    \$KUBE_PROXY_CLIENT_CERT_FILE \
	    \$KUBE_PROXY_CLIENT_KEY_FILE \
	    \$KUBE_TLS_CERT_FILE \
	    \$KUBE_TLS_PRIVATE_KEY_FILE \
	    \$KUBE_SERVICE_CLUSTER_IP_RANGE \
	    \$KUBE_SERVICE_ACCOUNT_ISSUER \
	    \$KUBE_SERVICE_ACCOUNT_KEY_FILE \
	    \$KUBE_SERVICE_ACCOUNT_SIGN_KEY_FILE \
	    \$KUBE_SERVICE_NODE_PORT_RANGE \
	    \$KUBE_LOGTOSTDERR \
	    \$KUBE_LOG_LEVEL \
	    \$KUBE_API_PORT \
	    \$KUBELET_PORT \
	    \$KUBE_ALLOW_PRIV \
	    \$KUBE_SERVICE_ADDRESSES \
	    \$KUBE_ADMISSION_CONTROL \
	    \$KUB_ENCRYPTION_PROVIDER_CONF \
	    \$KUBE_REQUEST_HEADER_ALLOWED_NAME \
	    \$KUBE_REQUEST_HEADER_EXTRA_HEADER_PREF \
	    \$KUBE_REQUEST_HEADER_GROUP_HEADER \
	    \$KUBE_REQUEST_HEADER_USERNAME_HEADER \
	    \$KUBE_API_ARGS
Restart=on-failure
Type=notify
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target" >/usr/lib/systemd/system/kube-apiserver.service
  sed -i 's\http://127.0.0.1:8080\https://127.0.0.1:6443\g' /etc/kubernetes/config
  systemctl daemon-reload
  systemctl start kube-apiserver
  echo 'apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"' >${cert_path}/admin_cluster_role.yaml
  kubectl apply --kubeconfig ${cert_path}/admin.kubeconfig -f ${cert_path}/admin_cluster_role.yaml
  echo 'apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes' >${cert_path}/admin_cluster_rolebind.yaml
  kubectl apply --kubeconfig ${cert_path}/admin.kubeconfig -f ${cert_path}/admin_cluster_rolebind.yaml
}

function scheduler_prepare() {
  echo 'KUBE_CONFIG="--kubeconfig=/etc/kubernetes/pki/kube-scheduler.kubeconfig"
KUBE_BIND_ADDR="--bind-address=127.0.0.1"
KUBE_LEADER_ELECT="--leader-elect=true"
KUBE_SCHEDULER_ARGS=""' >/etc/kubernetes/scheduler
  echo "[Unit]
Description=Kubernetes Scheduler Plugin
Documentation=https://kubernetes.io/docs/reference/generated/kube-scheduler/
[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/scheduler
ExecStart=/usr/bin/kube-scheduler \
	    \$KUBE_LOGTOSTDERR \
	    \$KUBE_LOG_LEVEL \
	    \$KUBE_CONFIG \
	    \$KUBE_AUTHENTICATION_KUBE_CONF \
	    \$KUBE_AUTHORIZATION_KUBE_CONF \
	    \$KUBE_BIND_ADDR \
	    \$KUBE_LEADER_ELECT \
	    \$KUBE_SCHEDULER_ARGS
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target" >/usr/lib/systemd/system/kube-scheduler.service
  systemctl daemon-reload
}

function controller-manager_prepare() {
  echo 'KUBE_BIND_ADDRESS="--bind-address=127.0.0.1"
KUBE_CLUSTER_CIDR="--cluster-cidr=10.200.0.0/16"
KUBE_CLUSTER_NAME="--cluster-name=kubernetes"
KUBE_CLUSTER_SIGNING_CERT_FILE="--cluster-signing-cert-file=/etc/kubernetes/pki/ca.pem"
KUBE_CLUSTER_SIGNING_KEY_FILE="--cluster-signing-key-file=/etc/kubernetes/pki/ca-key.pem"
KUBE_KUBECONFIG="--kubeconfig=/etc/kubernetes/pki/kube-controller-manager.kubeconfig"
KUBE_LEADER_ELECT="--leader-elect=true"
KUBE_ROOT_CA_FILE="--root-ca-file=/etc/kubernetes/pki/ca.pem"
KUBE_SERVICE_ACCOUNT_PRIVATE_KEY_FILE="--service-account-private-key-file=/etc/kubernetes/pki/service-account-key.pem"
KUBE_SERVICE_CLUSTER_IP_RANGE="--service-cluster-ip-range=10.32.0.0/24"
KUBE_USE_SERVICE_ACCOUNT_CRED="--use-service-account-credentials=true"
KUBE_CONTROLLER_MANAGER_ARGS="--v=2"' >/etc/kubernetes/controller-manager
  echo "[Unit]
Description=Kubernetes Controller Manager
Documentation=https://kubernetes.io/docs/reference/generated/kube-controller-manager/
[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/controller-manager
ExecStart=/usr/bin/kube-controller-manager \
	    \$KUBE_BIND_ADDRESS \
	    \$KUBE_LOGTOSTDERR \
	    \$KUBE_LOG_LEVEL \
	    \$KUBE_CLUSTER_CIDR \
	    \$KUBE_CLUSTER_NAME \
	    \$KUBE_CLUSTER_SIGNING_CERT_FILE \
	    \$KUBE_CLUSTER_SIGNING_KEY_FILE \
	    \$KUBE_KUBECONFIG \
	    \$KUBE_LEADER_ELECT \
	    \$KUBE_ROOT_CA_FILE \
	    \$KUBE_SERVICE_ACCOUNT_PRIVATE_KEY_FILE \
	    \$KUBE_SERVICE_CLUSTER_IP_RANGE \
	    \$KUBE_USE_SERVICE_ACCOUNT_CRED \
	    \$KUBE_CONTROLLER_MANAGER_ARGS
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target" >/usr/lib/systemd/system/kube-controller-manager.service
  systemctl daemon-reload
}

function proxy_prepare() {
  echo 'KUBE_PROXY_ARGS="--kubeconfig=/etc/kubernetes/pki/kube-proxy.kubeconfig --bind-address=127.0.0.1"' >/etc/kubernetes/proxy
  systemctl daemon-reload
}

function kubernetes_remove() {
  DNF_REMOVE
  rm -rf /etc/kubernetes ${pkg_path} ${cfssl_path} /usr/local/bin/cfssl*
  hostnamectl set-hostname "${host_name}"
}
