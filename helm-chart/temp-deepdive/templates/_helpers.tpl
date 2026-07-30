{{- define "temp-deepdive.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "temp-deepdive.selectorLabels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
managed-by: "helm"
{{- end -}}