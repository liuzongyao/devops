{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gitlab.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gitlab.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "gitlab.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app: "{{ template "gitlab.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "gitlab.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ template "gitlab.name" . }}"
{{- end -}}

{{- define "gitlab.database.host" -}}
  {{- if .Values.database.useInternal -}}
    {{- template "gitlab.fullname" . }}-database
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.port" -}}
  {{- if .Values.database.useInternal -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.username" -}}
  {{- if .Values.database.useInternal -}}
    {{- .Values.database.postgresUser -}}
  {{- else -}}
    {{- .Values.database.external.postgresUser -}}
  {{- end -}}
{{- end -}}

{{/*the database name of gitlab*/}}
{{- define "gitlab.database.gitlabDatabase" -}}
  {{- if .Values.database.useInternal -}}
    {{- .Values.database.postgresDatabase -}}
  {{- else -}}
    {{- .Values.database.external.postgresDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.password" -}}
  {{- if .Values.database.useInternal -}}
    {{- .Values.database.postgresPassword | b64enc | quote -}}
  {{- else -}}
    {{- .Values.database.external.postgresPassword | b64enc | quote -}}
  {{- end -}}
{{- end -}}

{{- define "gitlab.database.rawPassword" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.postgresPassword -}}
  {{- else -}}
    {{- .Values.database.external.postgresPassword -}}
  {{- end -}}
{{- end -}}

{{/*the raw host and port of postgres*/}}
{{- define "gitlab.database.address" -}}
{{ template "gitlab.database.host" . }}:{{ template "gitlab.database.port" . }}
{{- end -}}

{{/*the raw connection string of postgres*/}}
{{- define "gitlab.database.rawGitlabDatabase" -}}
postgres://{{ template "gitlab.database.username" . }}:{{ template "gitlab.database.rawPassword" . }}@{{ template "gitlab.database.host" . }}:{{ template "gitlab.database.port" . }}/{{ template "gitlab.database.gitlabDatabase" . }}?sslmode=disable
{{- end -}}

{{/*the host of redis*/}}
{{- define "gitlab.redis.host" -}}
  {{- if .Values.redis.useInternal -}}
    {{- template "gitlab.fullname" . }}-redis
  {{- else -}}
    {{- .Values.redis.external.host -}}
  {{- end -}}
{{- end -}}

{{/*the port of redis, default is 6379*/}}
{{- define "gitlab.redis.port" -}}
  {{- if .Values.redis.useInternal -}}
    {{- printf "%s" "6379" -}}
  {{- else -}}
    {{- .Values.redis.external.port }}
  {{- end -}}
{{- end -}}

{{/*the database index of redis, default is 0*/}}
{{- define "gitlab.redis.databaseIndex" -}}
  {{- if .Values.redis.useInternal -}}
    {{- .Values.redis.databaseIndex -}}
  {{- else -}}
    {{- .Values.redis.external.databaseIndex -}}
  {{- end -}}
{{- end -}}

{{/*the password of redis*/}}
{{- define "gitlab.redis.password" -}}
  {{- if and .Values.redis.useInternal .Values.redis.usePassword -}}
    {{- .Values.redis.password | b64enc | quote -}}
  {{- else if and (not .Values.redis.useInternal) .Values.redis.external.usePassword -}}
    {{- .Values.redis.external.password | b64enc | quote -}}
  {{ else }}
    {{- printf "%s" "" -}}
  {{- end -}}
{{- end -}}

{{/*the raw password of redis*/}}
{{- define "gitlab.redis.rawPassword" -}}
  {{- if and .Values.redis.useInternal .Values.redis.usePassword -}}
    {{- .Values.redis.password -}}
  {{- else if and (not .Values.redis.useInternal) .Values.redis.external.usePassword -}}
    {{- .Values.redis.external.password -}}
  {{ else }}
    {{- printf "%s" "" -}}
  {{- end -}}    
{{- end -}}

{{/*the raw host and port of redis*/}}
{{- define "gitlab.redis.address" -}}
{{ template "gitlab.redis.host" . }}:{{ template "gitlab.redis.port" . }}
{{- end -}}

{{- define "portal.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.portal.repository .Values.global.images.portal.tag -}}
{{- end -}}

{{- define "database.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.database.repository .Values.global.images.database.tag -}}
{{- end -}}

{{- define "redis.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.redis.repository .Values.global.images.redis.tag -}}
{{- end -}}

{{- define "portal.volume" -}}
{{- if .Values.portal.persistence.enabled }}
persistentVolumeClaim:
  claimName: {{ .Values.portal.persistence.existingClaim | default (printf "%s" (include "gitlab.fullname" .)) }}  
{{- else }}
{{- if and (.Values.portal.persistence.host.nodeName) (.Values.portal.persistence.host.path) }}
hostPath:
  path: {{ .Values.portal.persistence.host.path }}
  type: DirectoryOrCreate
{{- else }}
emptyDir: {}
{{- end }}
{{- end }}
{{- end }}

{{- define "portal.nodeSelector" -}}
{{- if .Values.portal.nodeSelector }}
nodeSelector:
{{ toYaml .Values.portal.nodeSelector | indent 2 }}
{{- else }}
{{- if .Values.portal.persistence.host.nodeName }}
nodeSelector:
  kubernetes.io/hostname: {{ .Values.portal.persistence.host.nodeName }}
{{- end }}
{{- end }}
{{- end }}

{{- define "database.volume" -}}
{{- if .Values.database.persistence.enabled }}
persistentVolumeClaim:
  claimName: {{ .Values.database.persistence.existingClaim | default (printf "%s-database" (include "gitlab.fullname" .)) }}  
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


{{- define "redis.volume" -}}
{{- if .Values.redis.persistence.enabled }}
persistentVolumeClaim:
  claimName: {{ .Values.redis.persistence.existingClaim | default (printf "%s-redis" (include "gitlab.fullname" .)) }}  
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

{{- define "gitlab.protocal" -}}
{{- if and .Values.ingress.enabled .Values.ingress.tls.enabled }}
{{- printf "%s" "https" -}}
{{- else }}
{{- printf "%s" "http" -}}
{{- end }}
{{- end }}

{{- define "gitlab.host" -}}
{{- if .Values.ingress.enabled }}
{{- printf "%s" .Values.ingress.hosts.portal -}}
{{- else -}}
{{- printf "%s" .Values.gitlabHost -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.port" -}}
{{- if .Values.ingress.enabled -}}
{{ .Values.service.ports.http.port }}
{{- else -}}
{{ .Values.service.ports.http.nodePort }}
{{- end -}}
{{- end -}}

{{- define "gitlab.sshPort" -}}
{{- if .Values.ingress.enabled -}}
{{ .Values.service.ports.ssh.port }}
{{- else -}}
{{ .Values.service.ports.ssh.nodePort }}
{{- end -}}
{{- end -}}

{{- define "gitlab.externalURL" -}}
{{- printf "%s://%s:%s" (include "gitlab.protocal" .) (include "gitlab.host" .) (include "gitlab.port" .) -}}
{{- end -}}