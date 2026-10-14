# Reproducer: `RequestContext` parameters leak between requests in worker mode

A parameter set with `RequestContext::setParameter()` during one request is still set for the following requests handled by the same worker, and keeps being used as a default value by the URL generator.

This repository is a fresh `symfony/skeleton` (8.0) with a single controller: [`src/Controller/TenantController.php`](src/Controller/TenantController.php). It sets the `tenant` parameter on the router context only when the request provides one, like a multi-tenant listener would, then generates a link to the `tenant_dashboard` route without passing `tenant`.

The same image runs twice with FrankenPHP, in production mode (`APP_ENV=prod`, `APP_DEBUG=0`):

| Service | Port | Mode |
|---|---|---|
| `worker` | 8180 | Worker mode, 1 worker: Symfony boots once and serves every request |
| `classic` | 8181 | Classic mode: a fresh application for every request |

## Run it

```bash
docker compose up -d --build
./reproduce.sh
```

`reproduce.sh` sends the same two requests to each service: one with `?tenant=acme`, then one without any tenant.

## Result

```
=== worker mode (port 8180)
1) request that sets tenant=acme:
{"context_parameters":{"_locale":"en","tenant":"acme"},"dashboard_link":"\/acme\/dashboard"}
2) next request, without tenant:
{"context_parameters":{"_locale":"en","tenant":"acme"},"dashboard_link":"\/acme\/dashboard"}

=== classic mode (port 8181)
1) request that sets tenant=acme:
{"context_parameters":{"_locale":"en","tenant":"acme"},"dashboard_link":"\/acme\/dashboard"}
2) next request, without tenant:
{"context_parameters":{"_locale":"en"},"dashboard_link":"\/public\/dashboard"}
```

The second request does not set any tenant. In classic mode it links to `/public/dashboard`. In worker mode it still links to `/acme/dashboard`: the parameter set by the previous request leaked.

To start again from a clean worker: `docker compose restart worker`.

## Why

`router.request_context` is shared by all the requests of a worker. On each main request, `RouterListener` refreshes it with `RequestContext::fromRequest()`, which updates the base URL, path info, method, host, scheme, ports and query string, but not the parameters. The service is not tagged with `kernel.reset` either, so nothing restores the parameters between requests.

Found with [igor-php](https://github.com/igor-php/igor-php), a static analyzer that detects state leaks in worker mode.
