# Helm Chart for GitLab

## 介绍

[GitLab社区版](https://about.gitlab.com/)是一个用于编码, 测试和部署的应用程序. 它为Git存储库管理提供了细粒度的访问控制, 代码审查, 问题跟踪, 活动源, 维基和持续集成.

此 chart 定义了 GitLab Community Edition 组件. 这包括:

- A [GitLab Omnibus](https://docs.gitlab.com/omnibus/) Pod
- Redis
- Postgresql

## 环境要求

- Kubernetes 1.10 及以上版本、Beta APIs
- Kubernetes Ingress Controller
- Helm 2.8.0 及以上版本

## 安装 Chart

要安装版本名为 "my-release" 的 chart, 请运行:

```
$ helm install --name my-release \
   --set gitlabHost=150.109.66.42 .
```

> **Tip**: 使用 `helm list` 列出所有版本

## 卸载 Chart

卸载/删除 `my-release`:

```
$ helm delete my-release
```

该命令将删除与 `chart` 关联的所有 `Kubernetes` 资源并删除该版本. 

## 配置

可以到 [values.yaml](values.yaml) 中查看所有配置的默认值, 使用 `helm install` 的 `--set key = value [, key = value]` 参数设置每个参数.

或者, 可以在安装 `chart` 时提供指定参数值的 `YAML` 文件. 例如:

```
$ helm install --name my-release -f values.yaml .
```

> **Tip**: 你可以使用默认配置文件 [values.yaml](values.yaml)

### 镜像地址

在一个私有的网络环境，连接到外网会受限制，所以需要使用本地的镜像仓库。当指定镜像仓库地址时，如果指定一个 IP 地址为 `10.0.0.2`，并可以访问的镜像仓库地址，运行命令：

```
--set global.registry.address=10.0.0.2
```

## 数据存储

在安装 chart 前，请先确认将用哪种方式来存储数据:
 
1. Persistent Volume Claim (建议)
2. Host path

### Persistent Volume Claim (PVC)

如果 k8s 集群已经有可用的 StorageClass 和 provisioner，在安装 chart 过程中会自动创建 pvc 来存储数据。
想了解更多关于 StorageClass 和 PVC 的内容，可以参考 [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/)

**在部署过程中创建 PVC**

```
--set portal.persistence.enabled=true \
--set portal.persistence.storageClass=default \
--set database.persistence.enabled=true \
--set database.persistence.storageClass=default \
--set redis.persistence.enabled=true \
--set redis.persistence.storageClass=default \
```

*storageClass 可以不用传，默认为 default*

**使用一个已存在的 PVC**

```
--set portal.persistence.enabled=true \
--set portal.persistence.existingClaim=<pvc name> \
--set database.persistence.enabled=true \
--set database.persistence.existingClaim=<pvc name> \
--set redis.persistence.enabled=true \
--set redis.persistence.existingClaim=<pvc name> \
```

### 主机路径

如果集群中没有 provision, 可以用如下方式替代:

**存储数据到指定的 node 中**

```
--set portal.persistence.enabled=false \
--set portal.persistence.host.nodeName=<node name> \
--set portal.persistence.host.path=<path on host to store data>
--set portal.persistence.host.nodeName=<node name>
--set database.persistence.enabled=false \
--set database.persistence.host.nodeName=<node name> \
--set database.persistence.host.path=<path on host to store data>
--set database.persistence.host.nodeName=<node name>
--set redis.persistence.enabled=false \
--set redis.persistence.host.nodeName=<node name> \
--set redis.persistence.host.path=<path on host to store data>
--set redis.persistence.host.nodeName=<node name>
```

## 访问方式

### 通过 ip 访问

部署 gitlab 时候，需要确定 gitlab 的访问方式, 如果没有可用的域名，也可以通过 `<nodeIP>:<nodePort>` 的方式来访问，示例如下：

```
helm install . --name gitlab-ce --namespace default \
--set gitlabHost=119.28.187.185 \
--set gitlabRootPassword=Gitlab12345 \
--set service.ports.http.nodePort=31001 \
--set service.ports.ssh.nodePort=31002 \
```

nodePort 的值应该在 `30000` 到 `32767` 中间取值，不要与集群其它服务端口冲突。

### 通过域名访问

```
helm install . --name gitlab-ce --namespace default \
--set ingress.enabled=true \
--set ingress.hosts.portal=gitlab.sparrow.li \
--set gitlabRootPassword=Gitlab12345 \
```