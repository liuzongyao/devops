# Jenkins Helm Chart

此 chart 定义了如下组件：

- Jenkins Master

## Prerequisites

- Kubernetes cluster 1.9+ with Beta APIs enabled
- Kubernetes Ingress Controller is enabled
- Helm 2.8.0+


## Installing the Chart

* Jenkins 安装时会默认配置`动态 Jenkins agent` 来执行任务。此 `agent` 类型是在执行流水线的过程当中自动创建为 `Kubernetes Pod`。任务完成之后自动退出。

要安装版本名为 "jenkins" 的 chart, 请在 Kubernetes 集群的 master 节点中运行:


```
helm install --name jenkins --namespace <namespace> stable/jenkins
```

{{% notice info %}}
执行 `helm search jenkins` 来搜索 `jenkins` chart 的名称
{{% /notice %}}


## Uninstalling the Chart

卸载/删除 `jenkins`:

```
helm delete --purge jenkins
```

该命令将删除与 `chart` 关联的所有 `Kubernetes` 资源并删除该版本. 


## 配置

可以到 `values.yaml` 中查看所有配置的默认值, 使用 `helm install` 的 `--set key=value[,key=value]` 参数设置每个参数. 例如,

```
helm install --name jenkins --namespace <namespace>  stable/jenkins \
    --set MasterHostName=jenkins.mydomain,Master.AdminPassword=pass1234 
```

或者, 可以在安装 `chart` 时提供指定参数值的 `YAML` 文件. 例如:

```
helm install --name jenkins -f values.yaml .
```

## 管理源用户名和密码


```
helm install --name jenkins --namespace <namespace>  stable/jenkins \
    --set AdminPassword=admin --set Master.AdminPassword=pass1234 
```

## Registry address

In a private network environment, access to the Internet may be limited and a local registry might be used. To specify the registry address. For a registry that can be accessed using the `10.0.0.2`:

```
--set global.registry.address=10.0.0.2
```


## Domain

To use a domain to access Jenkins, the following arguments can be used to automatically create an `Ingress` resource. Using `jenkins.example.com` as example:

```
--set Master.ServiceType=ClusterIP --set Master.HostName=jenkins.example.com
```

Make sure that the specific DNS records are pointing to the Kubernetes Master

If a domain is not available, it is still possible to use a specific port of the Kubernetes Master node to access Jenkins:

```
--set Master.ServiceType=NodePort --set Master.NodePort=32000
```

After deploying, Jenkins can be accessed using the Kubernetes Master node IP and the indicated `NodePort` value

The `Master.NodePort` should be between `30000` to `32767` as default. Check with your cluster administrator for the possible values.


## Data persistance

Before installing the chart please chose how to persist Jenkins data:
1. Persistent Volume Claim (recommended)
2. Host path

### Persistent Volume Claim

默认情况下，Harbor 会将数据保存在一些持久卷中。卷使用动态卷配置创建。如果要使用现有的持久性卷声明，请在安装期间指定它们。

如果 k8s 集群已经有可用的 StorageClass 和 provisioner，在安装 chart 过程中会自动创建 pvc 来存储数据。
想了解更多关于 StorageClass 和 PVC 的内容，可以参考 [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/)

**To create a new PVC on deploy**

```
--set Persistence.Enabled=true
```

**To use an already existing PVC**

```
--set Persistence.ExistingClaim=<pvc name>
```

The full list of arguments can be found below

### Host path

If the kubernetes cluster doesn't have Storage related capabilities, the following can be used instead:

**Store and deploy Jenkins to a specific node**
```
--set Persistence.Enabled=false --set Persistence.Host.NodeName=<node name> --set Persistence.Host.Path=<path on host to store data>
```

Use `kubectl get nodes` to list all the nodes available in the cluster. Use the first column Name as `Persistence.Host.NodeName`

## 其它配置

完整的 Helm chart 配置，执行 `helm fetch --untar -d <目标目录> stable/jenkins` 来下载 Jenkins Helm chart。进去目录就可以看到 chart中的 `values.yaml` 文件
{{% notice info %}}
注意：目标目录需要提前创建好
{{% /notice %}} 

## 使用 Jenkins Agent

安装之后可以使用的 `agent label` 如下:
- `maven`, `java` 或 `java-openjdk8` 包含一个 `java` 容器来编译 `maven` 程序
- `golang-1.10` 包含 `golang` 容器来编译 `go` 程序
- `nodejs-10` 包含 `nodejs` 容器来编译 `nodejs` 程序
- `python-2.7` 包含 `python` 容器来编译 `python 2.7` 程序
- `python-3.6` 包含 `python` 容器来编译 `python 3.6` 程序
- `python-3.7` 包含 `python` 容器来编译 `python 3.7` 程序

所有的 `agent` 包含两个容器：
- `jnlp` 跟 `Jenkins Master` 执行通信
- `tools` 包含多种通用的工具：
  - `git`
  - `zip`和`unzip`
  - `curl` 和 `rsync`
  - `docker`
  - `kubectl`
  - `helm`
  - `acp`等

如下 `Jenkinsfile` 为例

``` groovy
pipeline {
  agent {
    label 'java-openjdk8'
  }

  stages {
    stage('checkout') {
      steps {
        checkout([
          $class: 'GitSCM', branches: [[name: '*/master']], 
          extensions: [], submoduleCfg: [], 
          userRemoteConfigs: [[url: 'https://github.com/alauda-devops-quickstarts/hello-world-java']]
        ])
      }
    }
    stage('build') {
      steps {
        dir('examples/test-app-maven') {
          // 切倒 java 容器
          container('java') {
            sh "mvn clean package"
          }
        }
      }
    }
    stage('docker') {
      steps {
        // 切到 tools 容器
        container('tools') {
          sh "docker ps"
        }
      }
    }

}

```


## Configuration

The following tables list the configurable parameters of the Jenkins chart and their default values.

### Jenkins Master
| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `nameOverride`                    | Override the resource name prefix    | `jenkins`                                                                    |
| `fullnameOverride`                | Override the full resource names     | `jenkins-{release-name}` (or `jenkins` if release-name is `jenkins`)         |
| `Master.Name`                     | Jenkins master name                  | `jenkins-master`                                                             |
| `Master.Image`                    | Master image name                    | `jenkinsci/jenkins`                                                          |
| `Master.ImageTag`                 | Master image tag                     | `lts`                                                                     |
| `Master.ImagePullPolicy`          | Master image pull policy             | `Always`                                                                     |
| `Master.ImagePullSecret`          | Master image pull secret             | Not set                                                                      |
| `Master.Component`                | k8s selector key                     | `jenkins-master`                                                             |
| `Master.UseSecurity`              | Use basic security                   | `true`                                                                       |
| `Master.AdminUser`                | Admin username (and password) created as a secret if useSecurity is true | `admin`                                  |
| `Master.AdminPassword`            | Admin password (and user) created as a secret if useSecurity is true | Random value                                  |
| `Master.JenkinsAdminEmail`        | Email address for the administrator of the Jenkins instance | Not set                                               |
| `Master.resources`                | Resources allocation (Requests and Limits) | `{requests: {cpu: 50m, memory: 256Mi}, limits: {cpu: 2000m, memory: 2048Mi}}`|
| `Master.InitContainerEnv`         | Environment variables for Init Container                                 | Not set                                  |
| `Master.ContainerEnv`             | Environment variables for Jenkins Container                              | Not set                                  |
| `Master.UsePodSecurityContext`    | Enable pod security context (must be `true` if `RunAsUser` or `FsGroup` are set) | `true`                           |
| `Master.RunAsUser`                | uid that jenkins runs with           | `0`                                                                          |
| `Master.FsGroup`                  | uid that will be used for persistent volume | `0`                                                                   |
| `Master.ServiceAnnotations`       | Service annotations                  | `{}`                                                                         |
| `Master.ServiceType`              | k8s service type                     | `LoadBalancer`                                                               |
| `Master.ServicePort`              | k8s service port                     | `8080`                                                                       |
| `Master.NodePort`                 | k8s node port                        | Not set                                                                      |
| `Master.HealthProbes`             | Enable k8s liveness and readiness probes | `true`                                                                   |
| `Master.HealthProbesLivenessTimeout`      | Set the timeout for the liveness probe | `120`                                                       |
| `Master.HealthProbesReadinessTimeout` | Set the timeout for the readiness probe | `60`                                                       |
| `Master.HealthProbeLivenessFailureThreshold` | Set the failure threshold for the liveness probe | `12`                                                       |
| `Master.SlaveListenerPort`        | Listening port for agents            | `50000`                                                                      |
| `Master.DisabledAgentProtocols`   | Disabled agent protocols             | `JNLP-connect JNLP2-connect`                                                                      |
| `Master.CSRF.DefaultCrumbIssuer.Enabled` | Enable the default CSRF Crumb issuer | `true`                                                                      |
| `Master.CSRF.DefaultCrumbIssuer.ProxyCompatability` | Enable proxy compatibility | `true`                                                                      |
| `Master.CLI`                      | Enable CLI over remoting             | `false`                                                                      |
| `Master.LoadBalancerSourceRanges` | Allowed inbound IP addresses         | `0.0.0.0/0`                                                                  |
| `Master.LoadBalancerIP`           | Optional fixed external IP           | Not set                                                                      |
| `Master.JMXPort`                  | Open a port, for JMX stats           | Not set                                                                      |
| `Master.CustomConfigMap`          | Use a custom ConfigMap               | `false`                                                                      |
| `Master.OverwriteConfig`          | Replace config w/ ConfigMap on boot  | `false`                                                                      |
| `Master.Ingress.Annotations`      | Ingress annotations                  | `{}`                                                                         |
| `Master.Ingress.TLS`              | Ingress TLS configuration            | `[]`                                                                         |
| `Master.InitScripts`              | List of Jenkins init scripts         | Not set                                                                      |
| `Master.CredentialsXmlSecret`     | Kubernetes secret that contains a 'credentials.xml' file | Not set                                                  |
| `Master.SecretsFilesSecret`       | Kubernetes secret that contains 'secrets' files | Not set                                                           |
| `Master.Jobs`                     | Jenkins XML job configs              | Not set                                                                      |
| `Master.InstallPlugins`           | List of Jenkins plugins to install   | `kubernetes:1.12.0 workflow-aggregator:2.5 credentials-binding:1.16 git:3.9.1 workflow-job:2.23` |
| `Master.ScriptApproval`           | List of groovy functions to approve  | Not set                                                                      |
| `Master.NodeSelector`             | Node labels for pod assignment       | `{}`                                                                         |
| `Master.Affinity`                 | Affinity settings                    | `{}`                                                                         |
| `Master.Tolerations`              | Toleration labels for pod assignment | `{}`                                                                         |
| `Master.PodAnnotations`           | Annotations for master pod           | `{}`                                                                         |
| `NetworkPolicy.Enabled`           | Enable creation of NetworkPolicy resources. | `false`                                                               |
| `NetworkPolicy.ApiVersion`        | NetworkPolicy ApiVersion             | `extensions/v1beta1`                                                         |
| `rbac.install`                    | Create service account and ClusterRoleBinding for Kubernetes plugin | `false`                                       |
| `rbac.apiVersion`                 | RBAC API version                     | `v1beta1`                                                                    |
| `rbac.roleRef`                    | Cluster role name to bind to         | `cluster-admin`                                                              |
| `rbac.roleBindingKind`            | Role kind (`RoleBinding` or `ClusterRoleBinding`)| `ClusterRoleBinding`                                             |

### Jenkins Agent

| Parameter                  | Description                                     | Default                |
| -------------------------- | ----------------------------------------------- | ---------------------- |
| `Agent.AlwaysPullImage`    | Always pull agent container image before build  | `false`                |
| `Agent.CustomJenkinsLabels`| Append Jenkins labels to the agent              | `{}`                   |
| `Agent.Enabled`            | Enable Kubernetes plugin jnlp-agent podTemplate | `true`                 |
| `Agent.Image`              | Agent image name                                | `jenkinsci/jnlp-slave` |
| `Agent.ImagePullSecret`    | Agent image pull secret                         | Not set                |
| `Agent.ImageTag`           | Agent image tag                                 | `2.62`                 |
| `Agent.Privileged`         | Agent privileged container                      | `false`                |
| `Agent.resources`          | Resources allocation (Requests and Limits)      | `{requests: {cpu: 200m, memory: 256Mi}, limits: {cpu: 200m, memory: 256Mi}}`|
| `Agent.volumes`            | Additional volumes                              | `nil`                  |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/jenkins
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Mounting volumes into your Agent pods

Your Jenkins Agents will run as pods, and it's possible to inject volumes where needed:

```yaml
Agent:
  volumes:
  - type: Secret
    secretName: jenkins-mysecrets
    mountPath: /var/run/secrets/jenkins-mysecrets
```

The supported volume types are: `ConfigMap`, `EmptyDir`, `HostPath`, `Nfs`, `Pod`, `Secret`. Each type supports a different set of configurable attributes, defined by [the corresponding Java class](https://github.com/jenkinsci/kubernetes-plugin/tree/master/src/main/java/org/csanchez/jenkins/plugins/kubernetes/volumes).

## NetworkPolicy

To make use of the NetworkPolicy resources created by default,
install [a networking plugin that implements the Kubernetes
NetworkPolicy spec](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy#before-you-begin).

For Kubernetes v1.5 & v1.6, you must also turn on NetworkPolicy by setting
the DefaultDeny namespace annotation. Note: this will enforce policy for _all_ pods in the namespace:

    kubectl annotate namespace default "net.beta.kubernetes.io/network-policy={\"ingress\":{\"isolation\":\"DefaultDeny\"}}"

Install helm chart with network policy enabled:

    $ helm install stable/jenkins --set NetworkPolicy.Enabled=true

## Persistence

The Jenkins image stores persistence under `/var/jenkins_home` path of the container. A dynamically managed Persistent Volume
Claim is used to keep the data across deployments, by default. This is known to work in GCE, AWS, and minikube. Alternatively,
a previously configured Persistent Volume Claim can be used.

It is possible to mount several volumes using `Persistence.volumes` and `Persistence.mounts` parameters.

### Persistence Values

| Parameter                   | Description                     | Default         |
| --------------------------- | ------------------------------- | --------------- |
| `Persistence.Enabled`       | Enable the use of a Jenkins PVC | `true`          |
| `Persistence.ExistingClaim` | Provide the name of a PVC       | `nil`           |
| `Persistence.AccessMode`    | The PVC access mode             | `ReadWriteOnce` |
| `Persistence.Size`          | The size of the PVC             | `8Gi`           |
| `Persistence.volumes`       | Additional volumes              | `nil`           |
| `Persistence.mounts`        | Additional mounts               | `nil`           |

#### Existing PersistentVolumeClaim

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart

```bash
$ helm install --name my-release --set Persistence.ExistingClaim=PVC_NAME stable/jenkins
```

## Custom ConfigMap

When creating a new parent chart with this chart as a dependency, the `CustomConfigMap` parameter can be used to override the default config.xml provided.
It also allows for providing additional xml configuration files that will be copied into `/var/jenkins_home`. In the parent chart's values.yaml,
set the `jenkins.Master.CustomConfigMap` value to true like so

```yaml
jenkins:
  Master:
    CustomConfigMap: true
```

and provide the file `templates/config.tpl` in your parent chart for your use case. You can start by copying the contents of `config.yaml` from this chart into your parent charts `templates/config.tpl` as a basis for customization. Finally, you'll need to wrap the contents of `templates/config.tpl` like so:

```yaml
{{- define "override_config_map" }}
    <CONTENTS_HERE>
{{ end }}
```

## RBAC

If running upon a cluster with RBAC enabled you will need to do the following:

* `helm install stable/jenkins --set rbac.install=true`
* Create a Jenkins credential of type Kubernetes service account with service account name provided in the `helm status` output.
* Under configure Jenkins -- Update the credentials config in the cloud section to use the service account credential you created in the step above.

## Run Jenkins as non root user

The default settings of this helm chart let Jenkins run as root user with uid `0`.
Due to security reasons you may want to run Jenkins as a non root user.
Fortunately the default jenkins docker image `jenkins/jenkins` contains a user `jenkins` with uid `1000` that can be used for this purpose.

Simply use the following settings to run Jenkins as `jenkins` user with uid `1000`.

```yaml
jenkins:
  Master:
    RunAsUser: 1000
    FsGroup: 1000
```

## Providing jobs xml

Jobs can be created (and overwritten) by providing jenkins config xml within the `values.yaml` file.
The keys of the map will become a directory within the jobs directory.
The values of the map will become the `config.xml` file in the respective directory.

Below is an example of a `values.yaml` file and the directory structure created:

#### values.yaml
```yaml
Master:
  Jobs:
    test-job: |-
      <?xml version='1.0' encoding='UTF-8'?>
      <project>
        <keepDependencies>false</keepDependencies>
        <properties/>
        <scm class="hudson.scm.NullSCM"/>
        <canRoam>false</canRoam>
        <disabled>false</disabled>
        <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
        <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
        <triggers/>
        <concurrentBuild>false</concurrentBuild>
        <builders/>
        <publishers/>
        <buildWrappers/>
      </project>
    test-job-2: |-
      <?xml version='1.0' encoding='UTF-8'?>
      <project>
        <keepDependencies>false</keepDependencies>
        <properties/>
        <scm class="hudson.scm.NullSCM"/>
        <canRoam>false</canRoam>
        <disabled>false</disabled>
        <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
        <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
        <triggers/>
        <concurrentBuild>false</concurrentBuild>
        <builders/>
        <publishers/>
        <buildWrappers/>
```

#### Directory structure of jobs directory
```
.
├── _test-job-1
|   └── config.xml
├── _test-job-2
|   └── config.xml
```

Docs taken from https://github.com/jenkinsci/docker/blob/master/Dockerfile:
_Jenkins is run with user `jenkins`, uid = 1000. If you bind mount a volume from the host or a data container,ensure you use the same uid_

## Running behind a forward proxy

The master pod uses an Init Container to install plugins etc. If you are behind a corporate proxy it may be useful to set `Master.InitContainerEnv` to add environment variables such as `http_proxy`, so that these can be downloaded.

Additionally, you may want to add env vars for the Jenkins container, and the JVM (`Master.JavaOpts`).

```yaml
Master:
  InitContainerEnv:
    - name: http_proxy
      value: "http://192.168.64.1:3128"
    - name: https_proxy
      value: "http://192.168.64.1:3128"
    - name: no_proxy
      value: ""
  ContainerEnv:
    - name: http_proxy
      value: "http://192.168.64.1:3128"
    - name: https_proxy
      value: "http://192.168.64.1:3128"
  JavaOpts: >-
    -Dhttp.proxyHost=192.168.64.1
    -Dhttp.proxyPort=3128
    -Dhttps.proxyHost=192.168.64.1
    -Dhttps.proxyPort=3128
```
