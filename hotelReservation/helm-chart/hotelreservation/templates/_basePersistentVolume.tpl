{{- define "hotelreservation.templates.basePersistentVolume" }}
{{- if .Values.global.mongodb.persistentVolume.hostPath.enabled }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ .Values.name}}-{{ .Release.Name }}-pv
  labels:
    app-name: {{ .Values.name }}-{{ .Release.Name }}
spec:
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: {{ .Values.global.mongodb.persistentVolume.size }}
  hostPath:
    path: {{ .Values.global.mongodb.persistentVolume.hostPath.path }}/{{ .Values.name }}-{{ .Release.Name }}pv
    type: DirectoryOrCreate
{{- end }}
{{- end }}
