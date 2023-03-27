{{- define "hotelreservation.templates.baseDeploymentServices" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    service: {{ .Values.name }}-{{ .Release.Name }}
  name: {{ .Values.name }}-{{ .Release.Name }}
spec:
  replicas: {{ .Values.replicas | default .Values.global.replicas }}
  selector:
    matchLabels:
      service: {{ .Values.name }}-{{ .Release.Name }}
  template:
    metadata:
      labels:
        service: {{ .Values.name }}-{{ .Release.Name }}
        app: {{ .Values.name }}-{{ .Release.Name }}
    spec:
      containers:
      {{- with .Values.container }}
      - name: "{{ .name }}"
        image: {{ .dockerRegistry | default $.Values.global.dockerRegistry }}/{{ .image }}:{{ .imageVersion | default $.Values.global.defaultImageVersion }}
        imagePullPolicy: {{ .imagePullPolicy | default $.Values.global.imagePullPolicy }}
        ports:
        {{- range $cport := .ports }}
        - containerPort: {{ $cport.containerPort -}}
        {{ end }}
        env:
          - name: LOG_LEVEL
            value: {{ $.Values.global.services.environments.logLevel | quote }}
          - name: JAEGER_SAMPLE_RATIO
            value: {{ $.Values.global.services.environments.jaegerSampleRatio | quote }}
          - name: MEMC_TIMEOUT
            value: {{ $.Values.global.services.environments.memcachedTimeout | quote }}
          - name: GC
            value: {{ $.Values.global.services.environments.gcPercent | quote }}
        {{- if .command}}
        command:
        - {{ .command }}
        {{- end -}}
        {{- if .args}}
        args:
        {{- range $arg := .args}}
        - {{ $arg }}
        {{- end -}}
        {{- end }}
        {{- if .resources }}
        resources:
          {{ tpl .resources $ | nindent 6 | trim }}
        {{- else if hasKey $.Values.global "resources" }}
        resources:
          {{ tpl $.Values.global.resources $ | nindent 6 | trim }}
        {{- end }}
        {{- if $.Values.configMaps }}        
        volumeMounts: 
        {{- range $configMap := $.Values.configMaps }}
        - name: {{ $.Values.name }}-{{ $.Release.Name }}-config
          mountPath: {{ $configMap.mountPath }}
          subPath: {{ $configMap.name }}
        {{- end }}
        {{- end }}
      {{- end -}}
      {{- if $.Values.configMaps }}
      volumes:
      - name: {{ $.Values.name }}-{{ $.Release.Name }}-config
        configMap:
          name: {{ $.Values.name }}-{{ $.Release.Name }}
      {{- end }}
      {{- if hasKey .Values "topologySpreadConstraints" }}
      topologySpreadConstraints:
        {{ tpl .Values.topologySpreadConstraints . | nindent 6 | trim }}
      {{- else if hasKey $.Values.global  "topologySpreadConstraints" }}
      topologySpreadConstraints:
        {{ tpl $.Values.global.topologySpreadConstraints . | nindent 6 | trim }}
      {{- end }}
      hostname: {{ $.Values.name }}
      restartPolicy: {{ .Values.restartPolicy | default .Values.global.restartPolicy}}
{{- end}}
