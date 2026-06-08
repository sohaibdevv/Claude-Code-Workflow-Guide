# Rollback Procedures

## Immediate Rollback (< 5 min)

If you just deployed and something is broken:

```bash
# Revert to previous deployment
npm run deploy:rollback
# or
vercel rollback
```

## Git-Based Rollback

```bash
# Find the last good commit
git log --oneline -10

# Create a revert commit (safe, preserves history)
git revert HEAD
git push origin main

# Redeploy
npm run deploy:prod
```

## Database Rollback

If the deploy included migrations:
```bash
# Roll back last migration
npm run db:migrate:rollback

# Verify data integrity
npm run db:verify
```

**Warning**: Rolling back database migrations can cause data loss if new data was written in the new schema. Assess carefully.

## Incident Communication

When rolling back:
1. Post in #incidents: "Deploying rollback for [feature], ETA [X] minutes"
2. Post when rollback complete: "Rollback complete, service restored"
3. File post-mortem within 24 hours
