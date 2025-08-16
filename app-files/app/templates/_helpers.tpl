{{- define "app.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "app.fullname" -}}
{{- printf "%s-deploy" .Release.Name -}}
{{- end -}}
