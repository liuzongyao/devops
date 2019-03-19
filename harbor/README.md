# Helm Chart for Harbor

## 介绍

This [Helm](https://github.com/kubernetes/helm) chart installs Harbor in a Kubernetes cluster.

此 chart 定义了如下组件：

- portal
- core
- adminserver
- registry
- clair
- jobservice
- notary
- chartmuseum
- database
- redis

## 环境要求

- Kubernetes 1.10 及以上版本、Beta APIs
- Kubernetes Ingress Controller
- Helm 2.8.0 及以上版本

## 安装 Chart

要安装版本名为 "harbor" 的 chart, 请在 Kubernetes 集群的 master 节点中运行:

```
helm install --name harbor --namespace <namespace> --set externalDomain=core.harbor.domain .
```

> **Tip**: 使用 `helm list` 列出所有版本

## 卸载 Chart

卸载/删除 `harbor`:

```
helm delete --purge harbor
```

该命令将删除与 `chart` 关联的所有 `Kubernetes` 资源并删除该版本. 

## 配置

可以到 `values.yaml` 中查看所有配置的默认值, 使用 `helm install` 的 `--set key=value[,key=value]` 参数设置每个参数.

或者, 可以在安装 `chart` 时提供指定参数值的 `YAML` 文件. 例如:

```
helm install --name harbor -f values.yaml .
```

## 镜像地址

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

*harbor 中有 `database、redis、chartmuseum、registry、jobservice` 有数据的产生，下面只以 database 的配置为例说明，其它类似。*

**在部署过程中创建 PVC**

```
--set database.persistence.enabled=true \
--set database.persistence.storageClass=default \
```

*storageClass 如果没有传，默认为 default*

**使用一个已存在的 PVC**

```
--set database.persistence.enabled=true \
--set database.persistence.existingClaim=<pvc name> \
...
```

### 主机路径

如果集群中没有 provision, 可以用如下方式替代:

**存储数据到当前 node 中**

```
--set database.persistence.enabled=false \
--set database.persistence.host.nodeName=<node name> \
--set database.persistence.host.path=<path on host to store data>
--set database.persistence.host.nodeName=<node name>
```

## 访问方式

### 通过 ip 访问

部署 gitlab 时候，需要确定 gitlab 的访问方式, 如果没有可用的域名，也可以通过 `<nodeIP>:<nodePort>` 的方式来访问，示例如下：

```
helm install . --name harbor --namespace default \
--set externalURL=http://${nodeIP}:${nodePort} \
--set harborAdminPassword=Harbor12345 \
--set ingress.enabled=false \
--set service.type=NodePort \
--set service.ports.http.nodePort=${nodePort} \
...
```

nodePort 的值应该在 `30000` 到 `32767` 中间取值，不要与集群其它服务端口冲突。

### 通过域名访问

```
helm install . --name harbor --namespace default \
--set externalURL=https://harbor.${DOMAIN} \
--set harborAdminPassword=Harbor12345 \
--set ingress.enabled=true \
--set ingress.hosts.core=harbor.${DOMAIN} \
--set ingress.hosts.notary=notary.${DOMAIN} \
```

## 其它配置

下面的表格列出了 harbor chart 中的所有配置字段，以及它们的默认值。

| 参数名称                  | 描述                        | 默认值                 |
| -----------------------    | ---------------------------------- | ----------------------- |
| **Harbor** |
| `externalURL`       | Ther external URL for Harbor core service | `https://core.harbor.domain` |
| `harborAdminPassword`  | The password of system admin | `Harbor12345` |
| `secretkey` | The key used for encryption. Must be a string of 16 chars | `not-a-secure-key` |
| `imagePullPolicy` | The image pull policy | `IfNotPresent` |
| **Ingress** |
| `ingress.enabled` | Enable ingress objects | `true` |
| `ingress.hosts.core` | The host of Harbor core service in ingress rule | `core.harbor.domain` |
| `ingress.hosts.notary` | The host of Harbor notary service in ingress rule | `notary.harbor.domain` |
| `ingress.annotations` | The annotations used in ingress | `true` |
| `ingress.tls.enabled` | Enable TLS | `true` |
| `ingress.tls.secretName` | Fill the secretName if you want to use the certificate of yourself when Harbor serves with HTTPS. A certificate will be generated automatically by the chart if leave it empty |
| `ingress.tls.notarySecretName` | Fill the notarySecretName if you want to use the certificate of yourself when Notary serves with HTTPS. if left empty, it uses the `ingress.tls.secretName` value |
| **Portal** |
| `portal.image.repository` | Repository for portal image | `goharbor/harbor-portal` |
| `portal.image.tag` | Tag for portal image | `dev` |
| `portal.replicas` | The replica count | `1` |
| `portal.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `portal.nodeSelector` | Node labels for pod assignment | `{}` |
| `portal.tolerations` | Tolerations for pod assignment | `[]` |
| `portal.affinity` | Node/Pod affinities | `{}` |
| **Adminserver** |
| `adminserver.image.repository` | Repository for adminserver image | `goharbor/harbor-adminserver` |
| `adminserver.image.tag` | Tag for adminserver image | `dev` |
| `adminserver.replicas` | The replica count | `1` |
| `adminserver.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `adminserver.nodeSelector` | Node labels for pod assignment | `{}` |
| `adminserver.tolerations` | Tolerations for pod assignment | `[]` |
| `adminserver.affinity` | Node/Pod affinities | `{}` |
| **Jobservice** |
| `jobservice.image.repository` | Repository for jobservice image | `goharbor/harbor-jobservice` |
| `jobservice.image.tag` | Tag for jobservice image | `dev` |
| `jobservice.replicas` | The replica count | `1` |
| `jobservice.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `jobservice.nodeSelector` | Node labels for pod assignment | `{}` |
| `jobservice.tolerations` | Tolerations for pod assignment | `[]` |
| `jobservice.affinity` | Node/Pod affinities | `{}` |
| **Core** |
| `core.image.repository` | Repository for Harbor core image | `goharbor/harbor-core` |
| `core.image.tag` | Tag for Harbor core image | `dev` |
| `core.replicas` | The replica count | `1` |
| `core.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `core.nodeSelector` | Node labels for pod assignment | `{}` |
| `core.tolerations` | Tolerations for pod assignment | `[]` |
| `core.affinity` | Node/Pod affinities | `{}` |
| **Database** |
| `database.useInternal` | If external database is used, set it to `false` | `true` |
| `database.image.repository` | Repository for database image | `goharbor/harbor-db` |
| `database.image.tag` | Tag for database image | `dev` |
| `database.password` | The password for database | `changeit` |
| `database.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `database.volumes` | The volume used to persistent data |
| `database.nodeSelector` | Node labels for pod assignment | `{}` |
| `database.tolerations` | Tolerations for pod assignment | `[]` |
| `database.affinity` | Node/Pod affinities | `{}` |
| `database.external.host` | The hostname of external database | `192.168.0.1` |
| `database.external.port` | The port of external database | `5432` |
| `database.external.username` | The username of external database | `user` |
| `database.external.password` | The password of external database | `password` |
| `database.external.coreDatabase` | The database used by core service | `registry` |
| `database.external.sslmode` | Connection method of external database (require|prefer|disable) | `disable`|
| `database.external.clairDatabase` | The database used by clair | `clair` |
| `database.external.notaryServerDatabase` | The database used by Notary server | `notary_server` |
| `database.external.notarySignerDatabase` | The database used by Notary signer | `notary_signer` |
| **Registry** |
| `registry.image.repository` | Repository for registry image | `goharbor/registry-photon` |
| `registry.image.tag` | Tag for registry image | `dev` |
| `registry.replicas` | The replica count | `1` |
| `registry.logLevel` | The log level | `info` |
| `registry.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `registry.volumes` | used to create PVCs if persistence is enabled (see instructions in values.yaml) | see values.yaml |
| `registry.nodeSelector` | Node labels for pod assignment | `{}` |
| `registry.tolerations` | Tolerations for pod assignment | `[]` |
| `registry.affinity` | Node/Pod affinities | `{}` |
| **Chartmuseum** |
| `chartmuseum.enabled` | Enable chartmusuem to store chart | `true` |
| `chartmuseum.image.repository` | Repository for chartmuseum image | `goharbor/chartmuseum-photon` |
| `chartmuseum.image.tag` | Tag for chartmuseum image | `dev` |
| `chartmuseum.replicas` | The replica count | `1` |
| `chartmuseum.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `chartmuseum.volumes` | used to create PVCs if persistence is enabled (see instructions in values.yaml) | see values.yaml |
| `chartmuseum.nodeSelector` | Node labels for pod assignment | `{}` |
| `chartmuseum.tolerations` | Tolerations for pod assignment | `[]` |
| `chartmuseum.affinity` | Node/Pod affinities | `{}` |
| **Storage For Registry And Chartmuseum** |
| `storage.type` | The storage backend used for registry and chartmuseum: `filesystem`, `azure`, `gcs`, `s3`, `swift`, `oss` | `filesystem` |
| `other values` | The other values please refer to https://github.com/docker/distribution/blob/master/docs/configuration.md#storage |  |
| **Clair** |
| `clair.enabled` | Enable Clair? | `true` |
| `clair.image.repository` | Repository for clair image | `goharbor/clair-photon` |
| `clair.image.tag` | Tag for clair image | `dev`
| `clair.replicas` | The replica count | `1` |
| `clair.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined
| `clair.nodeSelector` | Node labels for pod assignment | `{}` |
| `clair.tolerations` | Tolerations for pod assignment | `[]` |
| `clair.affinity` | Node/Pod affinities | `{}` |
| **Redis** |
| `redis.useInternal` | If an external Redis is used, set it to `false` | `true` |
| `redis.usePassword` | Whether use password | `false` |
| `redis.password` | The password for Redis | `changeit` |
| `redis.cluster.enabled` | Enable Redis cluster | `false` |
| `redis.master.persistence.enabled` | Persistent data   | `true` |
| `redis.external.host` | The hostname of external Redis | `192.168.0.2` |
| `redis.external.port` | The port of external Redis | `6379` |
| `redis.external.databaseIndex` | The database index of external Redis | `0` |
| `redis.external.usePassword` | Whether use password for external Redis | `false` |
| `redis.external.password` | The password of external Redis | `changeit` |
| **Notary** |
| `notary.enabled` | Enable Notary? | `true` |
| `notary.server.image.repository` | Repository for notary server image | `goharbor/notary-server-photon` |
| `notary.server.image.tag` | Tag for notary server image | `dev`
| `notary.server.replicas` | The replica count | `1` |
| `notary.signer.image.repository` | Repository for notary signer image | `goharbor/notary-signer-photon` |
| `notary.signer.image.tag` | Tag for notary signer image | `dev`
| `notary.signer.replicas` | The replica count | `1` |
| `notary.nodeSelector` | Node labels for pod assignment | `{}` |
| `notary.tolerations` | Tolerations for pod assignment | `[]` |
| `notary.affinity` | Node/Pod affinities | `{}` |