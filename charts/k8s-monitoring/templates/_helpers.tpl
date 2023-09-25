{{/* This function checks for the minimum Helm CLI version 3.7 */}}
{{/*   The use of .Subcharts requires 3.7 */}}
{{/*   The use of multi-line strings (in the fail below) requires 3.6 */}}
{{- define "checkHelmVersion" -}}
{{ if semverCompare "<3.7" .Capabilities.HelmVersion.Version }}
{{ fail "Helm version 3.7 or later is required for this chart" }}
{{- end }}
{{- end }}

{{/* This template checks that the port defined in .Values.traces.receiver.port is in the targetPort list on .grafana-agent */}}
{{- define "checkforTracePort" -}}
  {{- $port := .port -}}
  {{- $found := false -}}
  {{- range .agent.extraPorts -}}
    {{- if eq .targetPort $port }}
      {{- $found = true -}}
    {{- end }}
  {{- end }}
  {{- if not $found }}
    {{- fail (print .type " trace port not opened on the Grafana Agent.\nIn order for traces to work, the " .port " port needs to be opened on the Grafana Agent. For example, set this in your values file:\ngrafana-agent:\n  agent:\n    extraPorts:\n      - name: \"otlp-traces-" (lower .type) "\"\n        port: " .port "\n        targetPort: " .port "\n        protocol: \"TCP\"\nFor more examples, see https://github.com/grafana/k8s-monitoring-helm/tree/main/examples/traces-enabled") -}}
  {{- end -}}
{{- end -}}

{{/* Grafana Agent config */}}
{{- define "agentConfig" -}}
  {{- include "agent.config.nodes" . }}
  {{- include "agent.config.pods" . }}
  {{- include "agent.config.services" . }}

  {{- if .Values.metrics.enabled }}
    {{- if .Values.metrics.agent.enabled }}
      {{- include "agent.config.agent" . }}
    {{- end }}

    {{- if .Values.metrics.kubelet.enabled }}
      {{- include "agent.config.kubelet" . }}
    {{- end }}

    {{- if .Values.metrics.cadvisor.enabled }}
      {{- include "agent.config.cadvisor" . }}
    {{- end }}

    {{- if (index .Values.metrics "kube-state-metrics").enabled }}
      {{- include "agent.config.kube_state_metrics" . }}
    {{- end }}

    {{- if (index .Values.metrics "node-exporter").enabled }}
      {{- include "agent.config.node_exporter" . }}
    {{- end }}

    {{- if (index .Values.metrics "windows-exporter").enabled }}
      {{- include "agent.config.windows_exporter" . }}
    {{- end }}

    {{- if .Values.metrics.cost.enabled }}
      {{- include "agent.config.opencost" . }}
    {{- end }}

    {{- if .Values.metrics.podMonitors.enabled }}
      {{- include "agent.config.pod_monitors" . }}
    {{- end }}

    {{- if .Values.metrics.probes.enabled }}
      {{- include "agent.config.probes" . }}
    {{- end }}

    {{- if .Values.metrics.serviceMonitors.enabled }}
      {{- include "agent.config.service_monitors" . }}
    {{- end }}

    {{- include "agent.config.prometheus" . }}
  {{- end }}

  {{- if and .Values.logs.enabled .Values.logs.cluster_events.enabled }}
    {{- include "agent.config.logs.cluster_events" . }}
    {{- include "agent.config.loki" . }}
  {{- end }}

  {{- if and .Values.traces.enabled }}
    {{- include "agent.config.traces" . }}
    {{- include "agent.config.tempo" . }}
  {{- end }}

  {{- if .Values.extraConfig }}
    {{- print "\n" .Values.extraConfig }}
  {{- end }}
{{- end -}}

{{/* Grafana Agent Logs config */}}
{{- define "agentLogsConfig" -}}
  {{- include "agent.config.pods" . }}
  {{- include "agent.config.logs.pod_logs" . }}
  {{- include "agent.config.loki" . }}

  {{- if .Values.logs.extraConfig }}
    {{- print "\n" .Values.logs.extraConfig }}
  {{- end }}
{{- end -}}
