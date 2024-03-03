local kube = import 'lib/kube.libjsonnet';

// Agent
local agent(name) = kube._Object('monitoring.grafana.com/v1alpha1', 'GrafanaAgent', name) {
  metadata: {
    labels: {
      'app.kubernetes.io/name': name,
      'app.kubernetes.io/managed-by': 'commodore',
    },
    name: name,
  },
};

local metricsInstance(name) = kube._Object('monitoring.grafana.com/v1alpha1', 'MetricsInstance', name) {
  metadata: {
    labels: {
      'app.kubernetes.io/name': name,
      'app.kubernetes.io/managed-by': 'commodore',
    },
    name: name,
  },
};

{
  agent: agent,
  metricsInstance: metricsInstance,
}
