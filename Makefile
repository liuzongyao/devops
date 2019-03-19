REGISTRY=index.alauda.cn
DOMAIN=sparrow.li
NODE_IP=62.234.104.184
NODE_NAME=devops-test-master
HOST_PATH=/alauda/harbor

jenkins-install-host:
	helm install ./jenkins --name jenkins --namespace default \
	--set global.registry.address=${REGISTRY} \
	--set Master.ServiceType=NodePort \
	--set Master.NodePort=32000 \
	--set Master.AdminPassword="Jenkins12345" \
	--set Persistence.Enabled=false \
	--set Persistence.Host.NodeName=${NODE_NAME} \
	--set Persistence.Host.Path=/tmp/jenkins \
	--set AlaudaACP.Enabled=true \
	# --debug --dry-run \

jenkins-install-pvc-local:
	helm install ./jenkins --name jenkins --namespace default \
	--set global.registry.address=${REGISTRY} \
	--set Master.ServiceType=NodePort \
	--set Master.NodePort=32000 \
	--set Master.AdminPassword="Jenkins12345" \
	--set Persistence.Enabled=true \
	--set AlaudaACP.Enabled=true \
	# --debug --dry-run \


harbor-install-host:
	helm install ./harbor --name harbor --namespace default \
	--set global.registry.address=${REGISTRY} \
	--set externalURL=http://${NODE_IP}:31104 \
	--set harborAdminPassword=Harbor12345 \
	--set ingress.enabled=false \
	--set service.type=NodePort \
	--set service.ports.http.nodePort=31104 \
	--set service.ports.ssh.nodePort=31105 \
	--set service.ports.https.nodePort=31106 \
	--set database.password=pg-pwd \
	--set redis.usePassword=true \
	--set redis.password=redis-pwd \
	--set database.persistence.enabled=false \
	--set database.persistence.host.nodeName=${NODE_NAME} \
	--set database.persistence.host.path=${HOST_PATH}/database \
	--set redis.persistence.enabled=false \
	--set redis.persistence.host.nodeName=${NODE_NAME} \
	--set redis.persistence.host.path=${HOST_PATH}/redis \
	--set chartmuseum.persistence.enabled=false \
	--set chartmuseum.persistence.host.nodeName=${NODE_NAME} \
	--set chartmuseum.persistence.host.path=${HOST_PATH}/chartmuseum \
	--set registry.persistence.enabled=false \
	--set registry.persistence.host.nodeName=${NODE_NAME} \
	--set registry.persistence.host.path=${HOST_PATH}/registry \
	--set jobservice.persistence.enabled=false \
	--set jobservice.persistence.host.nodeName=${NODE_NAME} \
	--set jobservice.persistence.host.path=${HOST_PATH}/jobservice \
	--set AlaudaACP.Enabled=false \
	# --debug --dry-run \


# Uses pvc as storage for harbor
harbor-install-pvc:
	helm install ./harbor --name harbor --namespace default \
	--set global.registry.address=${REGISTRY} \
	--set externalURL=http://${NODE_IP}:31104 \
	--set harborAdminPassword=Harbor12345 \
	--set ingress.enabled=false \
	--set service.type=NodePort \
	--set service.ports.http.nodePort=31104 \
	--set service.ports.ssh.nodePort=31105 \
	--set service.ports.https.nodePort=31106 \
	--set database.password=pg-pwd \
	--set redis.usePassword=true \
	--set redis.password=redis-pwd \
	--set database.persistence.enabled=true \
	--set redis.persistence.enabled=true \
	--set chartmuseum.persistence.enabled=true \
	--set registry.persistence.enabled=true \
	--set jobservice.persistence.enabled=true \
	--set AlaudaACP.Enabled=false \
	# --debug --dry-run \

# Uses specific host as storage
# adds a domain for ingress
harbor-install-host-with-domain:
	helm install ./harbor --name harbor --namespace default \
	--set global.registry.address=${REGISTRY} \
	--set externalURL=https://harbor.${DOMAIN} \
	--set harborAdminPassword=Harbor12345 \
	--set ingress.enabled=true \
	--set ingress.hosts.core=harbor.${DOMAIN} \
	--set ingress.hosts.notary=notary.${DOMAIN} \
	--set ingress.tls.enabled=true \
	--set database.password=pg-pwd \
	--set redis.usePassword=true \
	--set redis.password=redis-pwd \
	--set database.persistence.enabled=false \
	--set database.persistence.host.nodeName=${NODE_NAME} \
	--set database.persistence.host.path=${HOST_PATH}/database \
	--set redis.persistence.enabled=false \
	--set redis.persistence.host.nodeName=${NODE_NAME} \
	--set redis.persistence.host.path=${HOST_PATH}/redis \
	--set chartmuseum.persistence.enabled=false \
	--set chartmuseum.persistence.host.nodeName=${NODE_NAME} \
	--set chartmuseum.persistence.host.path=${HOST_PATH}/chartmuseum \
	--set registry.persistence.enabled=false \
	--set registry.persistence.host.nodeName=${NODE_NAME} \
	--set registry.persistence.host.path=${HOST_PATH}/registry \
	--set jobservice.persistence.enabled=false \
	--set jobservice.persistence.host.nodeName=${NODE_NAME} \
	--set jobservice.persistence.host.path=${HOST_PATH}/jobservice \
	--set AlaudaACP.Enable=true\
	# --debug --dry-run \


gitlab-install-host:
	helm install ./gitlab-ce --name gitlab-ce --namespace default \
	--set global.registry.address=${REGISTRY} \
	--set portal.debug=true \
	--set gitlabHost=${NODE_IP} \
	--set gitlabRootPassword=Gitlab12345 \
	--set service.type=NodePort \
	--set service.ports.http.nodePort=31101 \
	--set service.ports.ssh.nodePort=31102 \
	--set service.ports.https.nodePort=31103 \
	--set portal.persistence.enabled=false \
	--set portal.persistence.host.nodeName=${NODE_NAME} \
	--set portal.persistence.host.path="/tmp/gitlab/portal" \
	--set portal.persistence.host.nodeName="${NODE_NAME}" \
	--set database.persistence.enabled=false \
	--set database.persistence.host.nodeName=${NODE_NAME} \
	--set database.persistence.host.path="/tmp/gitlab/database" \
	--set database.persistence.host.nodeName="${NODE_NAME}" \
	--set redis.persistence.enabled=false \
	--set redis.persistence.host.nodeName=${NODE_NAME} \
	--set redis.persistence.host.path="/tmp/gitlab/redis" \
	--set redis.persistence.host.nodeName="${NODE_NAME}" \
	# --dry-run --debug

gitlab-install-pvc:
	helm install ./gitlab-ce --name gitlab-ce --namespace default \
	--set global.registry.address=${REGISTRY} \
	--set portal.debug=true \
	--set gitlabHost=${NODE_IP} \
	--set gitlabRootPassword=Gitlab12345 \
	--set service.type=NodePort \
	--set service.ports.http.nodePort=31101 \
	--set service.ports.ssh.nodePort=31102 \
	--set service.ports.https.nodePort=31103 \
	--set portal.persistence.enabled=true \
	--set database.persistence.enabled=true \
	--set redis.persistence.enabled=true \
	# --dry-run --debug

gitlab-install-host-with-domain:
	helm install ./gitlab-ce --name gitlab-ce --namespace default \
	--set global.registry.address=${REGISTRY} \
	--set portal.debug=true \
	--set ingress.enabled=true \
	--set ingress.hosts.portal="gitlab.${DOMAIN}" \
	--set gitlabRootPassword=Gitlab12345 \
	--set service.ports.http.nodePort=31101 \
	--set service.ports.ssh.nodePort=31102 \
	--set service.ports.https.nodePort=31103 \
	--set portal.persistence.enabled=false \
	--set portal.persistence.host.nodeName=${NODE_NAME} \
	--set portal.persistence.host.path="/tmp/gitlab/portal" \
	--set portal.persistence.host.nodeName="${NODE_NAME}" \
	--set database.persistence.enabled=false \
	--set database.persistence.host.nodeName=${NODE_NAME} \
	--set database.persistence.host.path="/tmp/gitlab/database" \
	--set database.persistence.host.nodeName="${NODE_NAME}" \
	--set redis.persistence.enabled=false \
	--set redis.persistence.host.nodeName=${NODE_NAME} \
	--set redis.persistence.host.path="/tmp/gitlab/redis" \
	--set redis.persistence.host.nodeName="${NODE_NAME}" \
	# --dry-run --debug

gitlab-del:
	helm del --purge gitlab-ce

jenkins-del:
	helm del --purge jenkins	

harbor-del:
	helm del --purge harbor