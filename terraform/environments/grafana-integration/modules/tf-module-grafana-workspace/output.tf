output "grafana_workspace_id" {
  value = join("", aws_grafana_workspace.grafana_workspace.*.id)
}
