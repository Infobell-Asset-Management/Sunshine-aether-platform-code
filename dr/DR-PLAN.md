# Disaster Recovery Plan

## Velero Backup

To create a backup:
```bash
velero backup create daily-$(date +%F) --include-namespaces assettrack
```

## DR Drill

1. **Scale down app:**
   ```bash
   kubectl -n assettrack scale deployment processor --replicas=0
   ```

2. **Delete PostgreSQL PVC:**
   ```bash
   kubectl -n assettrack delete pvc data-postgres-0
   ```

3. **Restore from Velero backup:**
   ```bash
   velero restore create --from-backup daily-<DATE>
   ```

4. **Scale app back up and validate data:**
   ```bash
   kubectl -n assettrack scale deployment processor --replicas=1
   # Validate app and DB data
   ```
