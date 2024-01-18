{{/*
Expand the name of the chart.
*/}}
{{- define "openex.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openex.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "openex.postgresql.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "openex.minio.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "minio" "chartValues" .Values.minio "context" $) -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "openex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openex.labels" -}}
helm.sh/chart: {{ include "openex.chart" . }}
{{ include "openex.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openex.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openex.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openex.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
openex root URL
*/}}
{{- define "openex.rootURL" -}}
{{- if .Values.rootURL -}}
    {{- print .Values.rootURL -}}
{{- else if .Values.ingress.enabled -}}
    {{- printf "http%s://%s" (ternary "" "s" (empty .Values.ingress.tls) ) .Values.ingress.hostname -}}
{{- else if (and (eq .Values.service.type "LoadBalancer") .Values.service.loadBalancerIP) -}}
    {{- $url := printf "http://%s" .Values.service.loadBalancerIP -}}
    {{- $port:= .Values.service.ports.http | toString }}
    {{- if (ne $port "80") -}}
        {{- $url = printf "%s:%s" $url $port -}}
    {{- end -}}
    {{- print $url -}}
{{- end -}}
{{- end -}}

{{/*
openex credential secret name
*/}}
{{- define "openex.secretName" -}}
{{- coalesce .Values.existingSecret (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Return true if a secret object should be created
*/}}
{{- define "openex.createSecret" -}}
{{- if .Values.auth.existingSecret -}}
{{- else -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the PostgreSQL Hostname
*/}}
{{- define "openex.databaseHost" -}}
{{- if .Values.postgresql.enabled }}
    {{- if eq .Values.postgresql.architecture "replication" }}
        {{- printf "%s-%s" (include "openex.postgresql.fullname" .) "primary" | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- print (include "openex.postgresql.fullname" .) -}}
    {{- end -}}
{{- else -}}
    {{- print .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the PostgreSQL Port
*/}}
{{- define "openex.databasePort" -}}
{{- if .Values.postgresql.enabled }}
    {{- print .Values.postgresql.primary.service.ports.postgresql -}}
{{- else -}}
    {{- printf "%d" (.Values.externalDatabase.port | int ) -}}
{{- end -}}
{{- end -}}

{{/*
Return the PostgreSQL Database Name
*/}}
{{- define "openex.databaseName" -}}
{{- if .Values.postgresql.enabled }}
    {{- print .Values.postgresql.auth.database -}}
{{- else -}}
    {{- print .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database user
*/}}
{{- define "openex.databaseUser" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.global.postgresql -}}
        {{- if .Values.global.postgresql.auth -}}
            {{- coalesce .Values.global.postgresql.auth.username .Values.postgresql.auth.username -}}
        {{- else -}}
            {{- .Values.postgresql.auth.username -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.postgresql.auth.username -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the PostgreSQL Secret Name
*/}}
{{- define "openex.databaseSecretName" -}}
{{- if .Values.postgresql.enabled }}
    {{- if .Values.postgresql.auth.existingSecret -}}
    {{- print .Values.postgresql.auth.existingSecret -}}
    {{- else -}}
    {{- print (include "openex.postgresql.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalDatabase.existingSecret -}}
    {{- print .Values.externalDatabase.existingSecret -}}
{{- else -}}
    {{- printf "%s-%s" (include "common.names.fullname" .) "externaldb" -}}
{{- end -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "openex.databaseSecretPasswordKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- print "password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecret -}}
        {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
            {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
        {{- else -}}
            {{- print "db-password" -}}
        {{- end -}}
    {{- else -}}
        {{- print "db-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "openex.databaseSecretHostKey" -}}
    {{- if .Values.externalDatabase.existingSecretHostKey -}}
        {{- printf "%s" .Values.externalDatabase.existingSecretHostKey -}}
    {{- else -}}
        {{- print "db-host" -}}
    {{- end -}}
{{- end -}}
{{- define "openex.databaseSecretPortKey" -}}
    {{- if .Values.externalDatabase.existingSecretPortKey -}}
        {{- printf "%s" .Values.externalDatabase.existingSecretPortKey -}}
    {{- else -}}
        {{- print "db-port" -}}
    {{- end -}}
{{- end -}}
{{- define "openex.databaseSecretUserKey" -}}
    {{- if .Values.externalDatabase.existingSecretUserKey -}}
        {{- printf "%s" .Values.externalDatabase.existingSecretUserKey -}}
    {{- else -}}
        {{- print "db-port" -}}
    {{- end -}}
{{- end -}}
{{- define "openex.databaseSecretDatabaseKey" -}}
    {{- if .Values.externalDatabase.existingSecretDatabaseKey -}}
        {{- printf "%s" .Values.externalDatabase.existingSecretDatabaseKey -}}
    {{- else -}}
        {{- print "db-port" -}}
    {{- end -}}
{{- end -}}

{{/*
Return the Minio hostname
*/}}
{{- define "openex.minioHost" -}}
{{- ternary (include "openex.minio.fullname" .) (tpl .Values.externalMinio.host $) .Values.minio.enabled -}}
{{- end -}}

{{/*
Return the Minio Port
*/}}
{{- define "openex.minioPort" -}}
{{- if .Values.minio.enabled }}
    {{- print .Values.minio.service.ports.api -}}
{{- else -}}
    {{- printf "%d" (.Values.externalMinio.port | int ) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Minio user
*/}}
{{- define "openex.minioUser" -}}
{{- if .Values.minio.enabled -}}
    {{- .Values.minio.auth.rootuser -}}
{{- else -}}
    {{- .Values.externalMinio.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the Minio Secret Name
*/}}
{{- define "openex.minioSecretName" -}}
{{- if .Values.minio.enabled }}
    {{- if .Values.minio.auth.existingSecret -}}
    {{- print .Values.minio.auth.existingSecret -}}
    {{- else -}}
    {{- print (include "openex.minio.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalMinio.existingSecret -}}
    {{- print .Values.externalMinio.existingSecret -}}
{{- end -}}
{{- end -}}