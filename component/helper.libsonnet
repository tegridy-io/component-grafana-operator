local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local so = import 'lib/sentry-operators.libsonnet';
local inv = kap.inventory();

// The hiera parameters for the component
local params = inv.parameters.sentry_operators;

// Cluster Role
local clusterRole = kube.ClusterRole('grafana-agent') {
  metadata: {
    labels: {
      'app.kubernetes.io/name': 'grafana-agent',
      'app.kubernetes.io/managed-by': 'commodore',
    },
    name: 'grafana-agent',
  },
  rules: [
    {
      apiGroups: [ '' ],
      resources: [
        'nodes',
        'nodes/proxy',
        'nodes/metrics',
        'services',
        'endpoints',
        'pods',
        'events',
      ],
      verbs: [ 'get', 'list', 'watch' ],
    },
    {
      apiGroups: [ 'networking.k8s.io' ],
      resources: [ 'ingresses' ],
      verbs: [ 'get', 'list', 'watch' ],
    },
    {
      nonResourceURLs: [ '/metrics', '/metrics/cadvisor' ],
      verbs: [ 'get' ],
    },
  ],
};

// Namespace
local namespaceName(instance) = '%s-%s' % [ params.agent.namespacePrefix, instance ];
local namespace(instance) = kube.Namespace('') {
  metadata: {
    labels: {
      'app.kubernetes.io/name': namespaceName(instance),
      'app.kubernetes.io/managed-by': 'commodore',
      'pod-security.kubernetes.io/enforce': 'baseline',
      'pod-security.kubernetes.io/warn': 'restricted',
      'pod-security.kubernetes.io/audit': 'restricted',
    },
    name: namespaceName(instance),
  },
};

// Service Account
local serviceAccount(instance) = kube.ServiceAccount('grafana-agent') {
  metadata: {
    labels: {
      'app.kubernetes.io/name': 'grafana-agent',
      'app.kubernetes.io/managed-by': 'commodore',
    },
    namespace: namespaceName(instance),
    name: 'grafana-agent',
  },
};

// Role Binding
local roleBinding(instance) = kube.RoleBinding('grafana-agent') {
  metadata: {
    labels: {
      'app.kubernetes.io/name': 'grafana-agent',
      'app.kubernetes.io/managed-by': 'commodore',
    },
    namespace: namespaceName(instance),
    name: 'grafana-agent',
  },
  roleRef_:: clusterRole,
  subjects_:: [ serviceAccount(instance) ],
};

// Metrics Instance

local agent(instance) = so.agent(instance) {
  metadata+: {
    namespace: namespaceName(instance),
  },
  spec: {
    image: 'grafana/agent:v0.40.1',
    integrations: {
      selector: {
        matchLabels: {
          'efk.tegridy.io/integrations': instance,
        },
      },
    },
    logLevel: 'info',
    serviceAccountName: 'grafana-agent',
    metrics: {
      instanceSelector: {
        matchLabels: {
          'efk.tegridy.io/metrics': instance,
        },
        // externalLabels: {
        //   cluster: 'cloud',
        // },
      },
    },
    logs: {
      instanceSelector: {
        matchLabels: {
          'efk.tegridy.io/logs': instance,
        },
      },
    },
  },
};

local metrics(instance) = so.metricsInstance(instance) {
  metadata+: {
    namespace: namespaceName(instance),
  },
  spec: {
    additionalScrapeConfigs: {},
    maxWALTime: {},
    minWALTime: {},
    podMonitorNamespaceSelector: {},
    podMonitorSelector: {},
    probeNamespaceSelector: {},
    probeSelector: {},
    remoteFlushDeadline: {},
    remoteWrite: {},
    serviceMonitorNamespaceSelector: {},
    serviceMonitorSelector: {},
    walTruncateFrequency: {},
    writeStaleOnShutdown: {},
  },
};


// Define outputs below
{
  clusterRole: clusterRole,
  instance(instance): [
    namespace(instance),
    serviceAccount(instance),
    roleBinding(instance),
    agent(instance),
  ],
}
