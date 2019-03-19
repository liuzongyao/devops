{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "harbor.name" -}}
{{- default "harbor" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "harbor.fullname" -}}
{{- $name := default "harbor" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "harbor.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app: "{{ template "harbor.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "harbor.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ template "harbor.name" . }}"
{{- end -}}

{{- define "harbor.portal" -}}
  {{- printf "%s-portal" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.core" -}}
  {{- printf "%s-core" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.adminserver" -}}
  {{- printf "%s-adminserver" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.jobservice" -}}
  {{- printf "%s-jobservice" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.registry" -}}
  {{- printf "%s-registry" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.chartmuseum" -}}
  {{- printf "%s-chartmuseum" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.database" -}}
  {{- printf "%s-database" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.clair" -}}
  {{- printf "%s-clair" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.notary-server" -}}
  {{- printf "%s-notary-server" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.notary-signer" -}}
  {{- printf "%s-notary-signer" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.nginx" -}}
  {{- printf "%s-nginx" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.autoGenCertForIngress" -}}
  {{- if and .Values.ingress.enabled (and .Values.ingress.tls.enabled (not .Values.ingress.tls.secretName)) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.autoGenCertForNginx" -}}
  {{- if and (not .Values.ingress.enabled) (and .Values.nginx.tls.enabled (not .Values.nginx.tls.secretName)) -}}    
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.autoGenCert" -}}
  {{- if or (eq (include "harbor.autoGenCertForIngress" .) "true") (eq (include "harbor.autoGenCertForNginx" .) "true") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}	
  {{- end -}}
{{- end -}}

{{- define "harbor.usesHttps" -}}
  {{- if and (and .Values.ingress.enabled .Values.ingress.tls.enabled) (not .Values.ingress.tls.secretName) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.notaryServiceName" -}}
{{- printf "%s-notary-server" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.database.host" -}}
  {{- if .Values.database.useInternal -}}
    {{- template "harbor.fullname" . }}-database
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.port" -}}
  {{- if .Values.database.useInternal -}}
    {{- .Values.database.port -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.username" -}}
  {{- if .Values.database.useInternal -}}
    {{- printf "%s" "postgres" -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.password" -}}
  {{- if .Values.database.useInternal -}}
    {{- .Values.database.password | b64enc | quote -}}
  {{- else -}}
    {{- .Values.database.external.password | b64enc | quote -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.rawPassword" -}}
  {{- if .Values.database.useInternal -}}
    {{- .Values.database.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.coreDatabase" -}}
  {{- if .Values.database.useInternal -}}
    {{- printf "%s" "registry" -}}
  {{- else -}}
    {{- .Values.database.external.coreDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.clairDatabase" -}}
  {{- if .Values.database.useInternal -}}
    {{- printf "%s" "postgres" -}}
  {{- else -}}
    {{- .Values.database.external.clairDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.notaryServerDatabase" -}}
  {{- if .Values.database.useInternal -}}
    {{- printf "%s" "notaryserver" -}}
  {{- else -}}
    {{- .Values.database.external.notaryServerDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.notarySignerDatabase" -}}
  {{- if .Values.database.useInternal -}}
    {{- printf "%s" "notarysigner" -}}
  {{- else -}}
    {{- .Values.database.external.notarySignerDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.sslmode" -}}
  {{- if .Values.database.useInternal -}}
    {{- printf "%s" "disable" -}}
  {{- else -}}
    {{- .Values.database.external.sslmode -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.clair" -}}
postgres://{{ template "harbor.database.username" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.clairDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.database.notaryServer" -}}
postgres://{{ template "harbor.database.username" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.notaryServerDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.database.notarySigner" -}}
postgres://{{ template "harbor.database.username" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.notarySignerDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.redis.host" -}}
  {{- if .Values.redis.useInternal -}}
    {{- template "harbor.fullname" . }}-redis
  {{- else -}}
    {{- .Values.redis.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.port" -}}
  {{- if .Values.redis.useInternal -}}
    {{- .Values.redis.port }}
  {{- else -}}
    {{- .Values.redis.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.coreDatabaseIndex" -}}
  {{- if .Values.redis.useInternal -}}
    {{- printf "%s" "0" }}
  {{- else -}}
    {{- .Values.redis.external.coreDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.jobserviceDatabaseIndex" -}}
  {{- if .Values.redis.useInternal -}}
    {{- printf "%s" "1" }}
  {{- else -}}
    {{- .Values.redis.external.jobserviceDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.registryDatabaseIndex" -}}
  {{- if .Values.redis.useInternal -}}
    {{- printf "%s" "2" }}
  {{- else -}}
    {{- .Values.redis.external.registryDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.chartmuseumDatabaseIndex" -}}
  {{- if .Values.redis.useInternal -}}
    {{- printf "%s" "3" }}
  {{- else -}}
    {{- .Values.redis.external.chartmuseumDatabaseIndex -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.password" -}}
  {{- if and .Values.redis.useInternal .Values.redis.usePassword -}}
    {{- .Values.redis.password -}}
  {{- else if and (not .Values.redis.useInternal) .Values.redis.external.usePassword -}}
    {{- .Values.redis.external.password -}}
  {{- end -}}
{{- end -}}

{{/*the username redis is used for a placeholder as no username needed in redis*/}}
{{- define "harbor.redisForJobservice" -}}
  {{- if and .Values.redis.useInternal .Values.redis.usePassword -}}
    {{- printf "redis://redis:%s@%s:%s/%s" (include "harbor.redis.password" . ) (include "harbor.redis.host" . ) (include "harbor.redis.port" . ) (include "harbor.redis.jobserviceDatabaseIndex" . ) }}
  {{- else if and (not .Values.redis.useInternal) .Values.redis.external.usePassword -}}
    {{- printf "redis://redis:%s@%s:%s/%s" (include "harbor.redis.password" . ) (include "harbor.redis.host" . ) (include "harbor.redis.port" . ) (include "harbor.redis.jobserviceDatabaseIndex" . ) }}
  {{- else }}
    {{- template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }}/{{ template "harbor.redis.jobserviceDatabaseIndex" . }}
  {{- end -}}
{{- end -}}

{{/*the username redis is used for a placeholder as no username needed in redis*/}}
{{- define "harbor.redisForGC" -}}
  {{- if and .Values.redis.useInternal .Values.redis.usePassword -}}
    {{- printf "redis://redis:%s@%s:%s/%s" (include "harbor.redis.password" . ) (include "harbor.redis.host" . ) (include "harbor.redis.port" . ) (include "harbor.redis.registryDatabaseIndex" . ) }}
  {{- else if and (not .Values.redis.useInternal) .Values.redis.external.usePassword -}}
    {{- printf "redis://redis:%s@%s:%s/%s" (include "harbor.redis.password" . ) (include "harbor.redis.host" . ) (include "harbor.redis.port" . ) (include "harbor.redis.registryDatabaseIndex" . ) }}
  {{- else }}
    {{- printf "redis://%s:%s/%s" (include "harbor.redis.host" . ) (include "harbor.redis.port" . ) (include "harbor.redis.registryDatabaseIndex" . ) -}}
  {{- end -}}
{{- end -}}

{{/*
host:port,pool_size,password
100 is the default value of pool size
*/}}
{{- define "harbor.redisForCore" -}}
  {{- template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }},100,{{ template "harbor.redis.password" . }}
{{- end -}}

{{- define "adminserver.image" -}}
{{- $registryAddress := .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.adminserver.repository -}}
{{- $tag := .Values.global.images.adminserver.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "jobservice.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.jobservice.repository -}}
{{- $tag := .Values.global.images.jobservice.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "registryRegistry.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.registryRegistry.repository -}}
{{- $tag := .Values.global.images.registryRegistry.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "registryController.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.registryController.repository -}}
{{- $tag := .Values.global.images.registryController.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "chartmuseum.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.chartmuseum.repository -}}
{{- $tag := .Values.global.images.chartmuseum.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "clair.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.clair.repository -}}
{{- $tag := .Values.global.images.clair.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "notaryServer.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.notaryServer.repository -}}
{{- $tag := .Values.global.images.notaryServer.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "notarySigner.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.notarySigner.repository -}}
{{- $tag := .Values.global.images.notarySigner.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "core.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.core.repository -}}
{{- $tag := .Values.global.images.core.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "portal.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.portal.repository -}}
{{- $tag := .Values.global.images.portal.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "db.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.db.repository -}}
{{- $tag := .Values.global.images.db.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "redis.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.redis.repository -}}
{{- $tag := .Values.global.images.redis.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "redisMetrics.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.redisMetrics.repository -}}
{{- $tag := .Values.global.images.redisMetrics.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "nginx.image" -}}
{{- $registryAddress :=  .Values.global.registry.address -}}
{{- $repositoryName := .Values.global.images.nginx.repository -}}
{{- $tag := .Values.global.images.nginx.tag -}}
{{- printf "%s/%s:%s" $registryAddress $repositoryName $tag -}}
{{- end -}}

{{- define "jobservice.volume" -}}
{{- if .Values.jobservice.persistence.enabled }}
persistentVolumeClaim:
  claimName: {{ .Values.jobservice.persistence.existingClaim | default (printf "%s-jobservice" (include "harbor.fullname" .)) }}  
{{- else }}
{{- if and (.Values.jobservice.persistence.host.nodeName) (.Values.jobservice.persistence.host.path) }}
hostPath:
  path: {{ .Values.jobservice.persistence.host.path }}
  type: DirectoryOrCreate
{{- else }}
emptyDir: {}
{{- end }}
{{- end }}
{{- end }}

{{- define "jobservice.nodeSelector" -}}
{{- if .Values.jobservice.nodeSelector }}
nodeSelector:
{{ toYaml .Values.jobservice.nodeSelector | indent 2 }}
{{- else }}
{{- if .Values.jobservice.persistence.host.nodeName }}
nodeSelector:
  kubernetes.io/hostname: {{ .Values.jobservice.persistence.host.nodeName }}
{{- end }}
{{- end }}
{{- end }}

{{- define "registry.volume" -}}
{{- if .Values.registry.persistence.enabled }}
persistentVolumeClaim:
  claimName: {{ .Values.registry.persistence.existingClaim | default (printf "%s-registry" (include "harbor.fullname" .)) }}  
{{- else }}
{{- if and (.Values.registry.persistence.host.nodeName) (.Values.registry.persistence.host.path) }}
hostPath:
  path: {{ .Values.registry.persistence.host.path }}
  type: DirectoryOrCreate
{{- else }}
emptyDir: {}
{{- end }}
{{- end }}
{{- end }}

{{- define "registry.nodeSelector" -}}
{{- if .Values.registry.nodeSelector }}
nodeSelector:
{{ toYaml .Values.registry.nodeSelector | indent 2 }}
{{- else }}
{{- if .Values.registry.persistence.host.nodeName }}
nodeSelector:
  kubernetes.io/hostname: {{ .Values.registry.persistence.host.nodeName }}
{{- end }}
{{- end }}
{{- end }}

{{- define "database.volume" -}}
{{- if .Values.database.persistence.enabled }}
persistentVolumeClaim:
  claimName: {{ .Values.database.persistence.existingClaim | default (printf "%s-database" (include "harbor.fullname" .)) }}  
{{- else }}
{{- if and (.Values.database.persistence.host.nodeName) (.Values.database.persistence.host.path) }}
hostPath:
  path: {{ .Values.database.persistence.host.path }}
  type: DirectoryOrCreate
{{- else }}
emptyDir: {}
{{- end }}
{{- end }}
{{- end }}

{{- define "database.nodeSelector" -}}
{{- if .Values.database.nodeSelector }}
nodeSelector:
{{ toYaml .Values.database.nodeSelector | indent 2 }}
{{- else }}
{{- if .Values.database.persistence.host.nodeName }}
nodeSelector:
  kubernetes.io/hostname: {{ .Values.database.persistence.host.nodeName }}
{{- end }}
{{- end }}
{{- end }}

{{- define "chartmuseum.volume" -}}
{{- if .Values.chartmuseum.persistence.enabled }}
persistentVolumeClaim:
  claimName: {{ .Values.chartmuseum.persistence.existingClaim | default (printf "%s-chartmuseum" (include "harbor.fullname" .)) }}  
{{- else }}
{{- if and (.Values.chartmuseum.persistence.host.nodeName) (.Values.chartmuseum.persistence.host.path) }}
hostPath:
  path: {{ .Values.chartmuseum.persistence.host.path }}
  type: DirectoryOrCreate
{{- else }}
emptyDir: {}
{{- end }}
{{- end }}
{{- end }}

{{- define "chartmuseum.nodeSelector" -}}
{{- if .Values.chartmuseum.nodeSelector }}
nodeSelector:
{{ toYaml .Values.chartmuseum.nodeSelector | indent 2 }}
{{- else }}
{{- if .Values.chartmuseum.persistence.host.nodeName }}
nodeSelector:
  kubernetes.io/hostname: {{ .Values.chartmuseum.persistence.host.nodeName }}
{{- end }}
{{- end }}
{{- end }}

{{- define "redis.volume" -}}
{{- if .Values.redis.persistence.enabled }}
persistentVolumeClaim:
  claimName: {{ .Values.redis.persistence.existingClaim | default (printf "%s-redis" (include "harbor.fullname" .)) }}  
{{- else }}
{{- if and (.Values.redis.persistence.host.nodeName) (.Values.redis.persistence.host.path) }}
hostPath:
  path: {{ .Values.redis.persistence.host.path }}
  type: DirectoryOrCreate
{{- else }}
emptyDir: {}
{{- end }}
{{- end }}
{{- end }}

{{- define "redis.nodeSelector" -}}
{{- if .Values.redis.nodeSelector }}
nodeSelector:
{{ toYaml .Values.redis.nodeSelector | indent 2 }}
{{- else }}
{{- if .Values.redis.persistence.host.nodeName }}
nodeSelector:
  kubernetes.io/hostname: {{ .Values.redis.persistence.host.nodeName }}
{{- end }}
{{- end }}
{{- end }}

{{- define "portal.nodeSelector" -}}
{{- if .Values.portal.nodeSelector }}
nodeSelector:
{{ toYaml .Values.portal.nodeSelector | indent 2 }}
{{- end }}
{{- end }}

{{- define "core.nodeSelector" -}}
{{- if .Values.core.nodeSelector }}
nodeSelector:
{{ toYaml .Values.core.nodeSelector | indent 2 }}
{{- end }}
{{- end }}

{{- define "adminserver.nodeSelector" -}}
{{- if .Values.adminserver.nodeSelector }}
nodeSelector:
{{ toYaml .Values.adminserver.nodeSelector | indent 2 }}
{{- end }}
{{- end }}

{{- define "clair.nodeSelector" -}}
{{- if .Values.clair.nodeSelector }}
nodeSelector:
{{ toYaml .Values.clair.nodeSelector | indent 2 }}
{{- end }}
{{- end }}

{{- define "notary.nodeSelector" -}}
{{- if .Values.notary.nodeSelector }}
nodeSelector:
{{ toYaml .Values.notary.nodeSelector | indent 2 }}
{{- end }}
{{- end }}