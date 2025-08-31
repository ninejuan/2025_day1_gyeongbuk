{{- define "app.name" -}}
{{- .Release.Name -}}
{{- end -}}

{{- define "app.fullname" -}}
{{- printf "%s-deploy" .Release.Name -}}
{{- end -}}
