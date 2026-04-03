# Ziwei Dependency Audit (Phase 2.5)

Date: 2026-03-30

## Scope

Ziwei profile canonical implementation, explanation, and matching integration.

## Audit Requirement

All Ziwei-related dependencies must be verified for:

- repository availability
- license text
- closed-source distribution impact
- commercial-use restrictions
- whether the dependency is a canonical runtime or only research/prototype use

## Candidate Stack to Audit

| Name | Intended Use | Status |
|---|---|---|
| `iztro` | Ziwei canonical or adapter candidate | pending verify |
| `py-iztro` | Python-side Ziwei canonical or batch/backfill candidate | pending verify |

## Mandatory Gate

Until license and repo availability are verified:

- do not set as `canonical_default=true`
- do not embed directly into closed-source mobile runtime
- do not describe as production-ready in external docs

## Next Steps

1. Verify repository and license of `iztro`.
2. Verify repository and license of `py-iztro`.
3. Choose canonical path for backend implementation.
4. Update `config/astrology_dependency_gate.php` accordingly.

