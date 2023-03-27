{{- define "hotelreservation.templates.baseConfigMap" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.name }}-{{ .Release.Name }}
  labels:
    hotelreservation/service: {{ .Values.name }}-{{ .Release.Name }}
data:
 {{- range $configMap := .Values.configMaps }}
  {{- $filePath := printf "configs/%s" $configMap.value }}
  {{ $configMap.name -}}: |
{{- tpl ($.Files.Get $filePath) $ | indent 4 -}}
  {{- end }}

{{- end }}
