// main template for insights-grafana
local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();

// The hiera parameters for the component
local params = inv.parameters.grafana_operator;

// Namespace
local namespace = kube.Namespace(params.namespace.name) {
  metadata: {
    [if std.length(params.namespace.annotations) > 0 then 'annotations']: params.namespace.annotations,
    labels: {
      'app.kubernetes.io/name': params.namespace.name,
      'app.kubernetes.io/part-of': 'insights',
      'app.kubernetes.io/managed-by': 'commodore',
      'pod-security.kubernetes.io/enforce': 'baseline',
      'pod-security.kubernetes.io/warn': 'restricted',
      'pod-security.kubernetes.io/audit': 'restricted',
    } + com.makeMergeable(params.namespace.labels),
    name: params.namespace.name,
  },
};

// Define outputs below
{
  '00_namespace': namespace,
}
