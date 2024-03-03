// main template for insights-grafana
local helper = import 'helper.libsonnet';
local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();

// The hiera parameters for the component
local params = inv.parameters.sentry_operators;

// Namespace
local namespace = kube.Namespace(params.namespace.name) {
  metadata: {
    [if std.length(params.namespace.annotations) > 0 then 'annotations']: params.namespace.annotations,
    labels: {
      'app.kubernetes.io/name': params.namespace.name,
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
} + if params.agent.enabled then {
  '20_clusterrole': helper.clusterRole,
  '30_instance_system': helper.instance('cluster'),
} else {}
