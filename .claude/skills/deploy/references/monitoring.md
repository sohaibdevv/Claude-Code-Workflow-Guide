# Post-Deploy Monitoring

## Immediate Checks (first 5 minutes)

```bash
# Check application health
curl https://yourapp.com/health

# Check error logs
tail -f /var/log/app/error.log
# or: check your logging platform
```

## Key Metrics to Watch

| Metric | Normal | Alert Threshold |
|---|---|---|
| Error rate | < 0.1% | > 1% |
| P95 latency | < 200ms | > 1000ms |
| CPU usage | < 60% | > 90% |
| Memory usage | < 70% | > 90% |

## Automated Health Check Script

```bash
#!/bin/bash
ENDPOINT="https://yourapp.com/health"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $ENDPOINT)

if [ "$STATUS" != "200" ]; then
  echo "HEALTH CHECK FAILED: $STATUS"
  exit 1
fi
echo "Health check passed: $STATUS"
```

## Monitoring Platforms

- **Datadog**: Check `api-latency` dashboard
- **Sentry**: Watch for new error fingerprints
- **PagerDuty**: Confirm no new alerts triggered
