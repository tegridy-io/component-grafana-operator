local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.sentry_operators;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('grafana-operator', params.namespace.name);

{
  'grafana-operator': app {
    spec+: {
      syncPolicy+: {
        syncOptions+: [
          'ServerSideApply=true',
        ],
      },
    },
  },
}
