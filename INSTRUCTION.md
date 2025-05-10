# Validation Instructions

This document provides instructions on how to validate the MySQL StatefulSet and Todo Application deployment.

## Prerequisites

- `kubectl` command-line tool installed
- `kind` installed for local Kubernetes cluster management

## Step 1: Deploy the Resources

Run the bootstrap script to deploy all resources:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## Step 2: Validate MySQL StatefulSet

### Check if MySQL StatefulSet is running:

```bash
kubectl get statefulset -n mysql
```

Expected output should show the StatefulSet with 3 replicas:
```
NAME    READY   AGE
mysql   3/3     <time>
```

### Check if MySQL pods are running:

```bash
kubectl get pods -n mysql
```

Expected output should show 3 pods in Running state:
```
NAME      READY   STATUS    RESTARTS   AGE
mysql-0   1/1     Running   0          <time>
mysql-1   1/1     Running   0          <time>
mysql-2   1/1     Running   0          <time>
```

### Verify MySQL connectivity:

Connect to the first MySQL pod:
```bash
kubectl exec -it mysql-0 -n mysql -- bash
```

Inside the container, connect to MySQL:
```bash
mysql -u root -p
# Enter the password when prompted (rootpass)
```

Check if the todoapp database exists:
```sql
SHOW DATABASES;
```

You should see the `todoapp` database in the list.

Check if the todos table exists:
```sql
USE todoapp;
SHOW TABLES;
```

You should see the `todos` table in the list.

Exit MySQL and the container:
```sql
EXIT;
exit
```

## Step 3: Validate Todo Application Deployment

### Check if the application deployment is running:

```bash
kubectl get deployment -n todoapp
```

Expected output:
```
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
todoapp   2/2     2            2           <time>
```

### Check if application pods are running:

```bash
kubectl get pods -n todoapp
```

Expected output should show pods in Running state.

### Test the application:

Access the application through NodePort:
```bash
curl http://localhost:30007/api/health
```

Expected output:
```
{"status":"ok"}
```

Create a new todo item:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"title":"Test Todo"}' http://localhost:30007/api/todos
```

List all todo items:
```bash
curl http://localhost:30007/api/todos
```

You should see the todo item you just created.

## Step 4: Validate Database Connection

To verify that the application is correctly connecting to MySQL:

```bash
kubectl logs $(kubectl get pod -n todoapp -l app=todoapp -o jsonpath="{.items[0].metadata.name}") -n todoapp
```

Look for any database connection errors in the logs. If the application is connecting properly, there should be no connection errors.

## Step 5: Validate Persistent Storage

Create some data in the application and then delete the pods to verify that data persists:

```bash
# Delete the application pod
kubectl delete pod -n todoapp -l app=todoapp
```

Wait for the new pod to start, then verify that your data is still available:

```bash
curl http://localhost:30007/api/todos
```

You should still see the todo items you created earlier.

## Step 6: Validate Horizontal Pod Autoscaler

Check if HPA is configured properly:

```bash
kubectl get hpa -n todoapp
```

Expected output:
```
NAME      REFERENCE            TARGETS                      MINPODS   MAXPODS   REPLICAS   AGE
todoapp   Deployment/todoapp   <current>%/<target>%         2         5         2          <time>
```

## Cleanup

To clean up the resources:

```bash
kubectl delete namespace todoapp
kubectl delete namespace mysql
kubectl delete pv pv-data
```