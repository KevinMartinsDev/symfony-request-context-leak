<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Routing\RouterInterface;

final class TenantController
{
    #[Route('/{tenant}/dashboard', name: 'tenant_dashboard', defaults: ['tenant' => 'public'])]
    public function dashboard(Request $request, RouterInterface $router): JsonResponse
    {
        // Simulates a listener that sets the tenant on the router context only when it can resolve one
        if ($request->query->has('tenant')) {
            $router->getContext()->setParameter('tenant', $request->query->get('tenant'));
        }

        return new JsonResponse([
            'context_parameters' => $router->getContext()->getParameters(),
            'dashboard_link' => $router->generate('tenant_dashboard'),
        ]);
    }
}
