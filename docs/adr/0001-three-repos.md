# ADR 0001: Three focused repositories

- Status: accepted
- Date: 2026-11-03

## Context

The portfolio needs to show platform, security and evidence work to a hiring panel that reads repositories, not slides. Three shapes were considered:

1. one monorepo toolkit,
2. three focused repositories that compose by pinned tags,
3. one golden-path template that scaffolds a fully wired service.

## Decision

Three focused repositories:

| Repo | Owns |
| --- | --- |
| `platform-modules` | network, cluster, identity and observability modules, plus local and cloud examples |
| `secure-delivery` | reusable CI/security/deploy workflows, the demo service, and policy gates |
| `evidence-kit` | evidence collection, signing and the release report |

Each repo is independently usable and pinned by tag. `platform-modules` is built first because the other two consume its module outputs and its local example.

## Consequences

- A reviewer can open one repo and see a complete concern without reading a monorepo.
- Cross-repo contracts (`role_arn`, `workload_identity_provider`, module tags) are versioned, so a broken change fails in the consumer rather than silently in one tree.
- Cost: three sets of documentation and three release cadences. Accepted, because each repo stays small enough to read in one sitting.
- Rejected the monorepo: a single failure would take down every artifact at once, and the result reads as one project rather than three capabilities.
- Rejected the golden-path template for now: it is the heaviest build and the LocalStack/kind seam is where it would most likely stay half-finished. The `secure-delivery` demo covers the missing narrative.
