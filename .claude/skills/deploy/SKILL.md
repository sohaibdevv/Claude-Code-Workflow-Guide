---
name: production-deploy
description: Use when deploying to production, releasing a version, shipping to users, going live, or rolling back a deployment. Also handles deployment failures and health checks.
---

# Production Deployment Skill

## Pre-Deploy Gate

All must pass before deploying:

```bash
npm test          # tests must pass
npm run lint      # no lint errors
npm run typecheck # no type errors
```

If any fail: STOP. Do not deploy. Fix first.

## Build

```bash
npm run build
```

Verify build output exists and looks correct.

## Deploy

```bash
npm run deploy:prod
# or
# vercel --prod
# or your deployment command
```

## Post-Deploy Verification

Wait 60 seconds, then verify:

1. Health check endpoint responds
2. Key user flows work (login, core action)
3. Error rate in monitoring is normal
4. Response times are normal

If issues found → see @references/rollback.md

## Monitoring

For post-deploy monitoring setup: @references/monitoring.md

## Rollback

For rollback procedures: @references/rollback.md
