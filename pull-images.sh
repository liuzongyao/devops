#!/bin/bash

curVersion="v1.6.0"
images=(
    # harbor
    "goharbor/harbor-portal:dev alaudak8s/harbor-portal:${curVersion}"
    "goharbor/harbor-core:dev alaudak8s/harbor-core:${curVersion}"
    "goharbor/harbor-adminserver:dev alaudak8s/harbor-adminserver:${curVersion}"
    "goharbor/harbor-jobservice:dev alaudak8s/harbor-jobservice:${curVersion}"
    "goharbor/harbor-db:dev alaudak8s/harbor-db:${curVersion}"
    "goharbor/registry-photon:dev alaudak8s/harbor-registry-registry:${curVersion}"
    "goharbor/harbor-registryctl:dev alaudak8s/harbor-registry-controller:${curVersion}"
    "goharbor/chartmuseum-photon:dev alaudak8s/harbor-chartmuseum:${curVersion}"
    "goharbor/clair-photon:dev alaudak8s/harbor-clair:${curVersion}"
    "goharbor/notary-server-photon:dev alaudak8s/harbor-notary-server:${curVersion}"
    "goharbor/notary-signer-photon:dev alaudak8s/harbor-notary-signer:${curVersion}"
    # gitlab
    "sameersbn/gitlab:11.4.0 alaudak8s/gitlab-ce:11.4.0"
    "sameersbn/postgresql:10 alaudak8s/postgresql:10"
    "sameersbn/redis:4.0.9-1 alaudak8s/redis:4.0.9-1"
)

for i in "${images[@]}" ; do
    b=($i)
    docker pull ${b[0]}
    docker tag ${b[0]} "index.alauda.cn/${b[1]}"
    docker push "index.alauda.cn/${b[1]}"
done