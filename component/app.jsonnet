local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.sentry_operators;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('sentry-operators', params.namespace);

{
  'sentry-operators': app,
}
