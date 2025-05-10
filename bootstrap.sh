#!/bin/bash
set -e

echo "Creating PersistentVolume..."
kubectl apply -f .infrastructure/pv.yml

echo "Creating MySQL namespace..."
kubectl apply -f .infrastructure/statefull/namespace.yml

echo "Creating MySQL Secret..."
kubectl apply -f .infrastructure/statefull/secret.yml

echo "Creating MySQL ConfigMap with init script..."
kubectl apply -f .infrastructure/statefull/config-map.yml

echo "Creating MySQL Headless Service..."
kubectl apply -f .infrastructure/statefull/headless-service.yml

echo "Deploying MySQL StatefulSet..."
kubectl apply -f .infrastructure/statefull/stateful-set.yml

echo "Waiting for MySQL StatefulSet to be ready..."
kubectl wait --for=condition=Ready pod/mysql-0 -n mysql --timeout=120s

echo "Creating application namespace..."
kubectl apply -f .infrastructure/deployment/namespace.yml

echo "Creating application PersistentVolumeClaim..."
kubectl apply -f .infrastructure/deployment/pvc.yml

echo "Creating application ConfigMap..."
kubectl apply -f .infrastructure/deployment/configMap.yml

echo "Creating application Secret..."
kubectl apply -f .infrastructure/deployment/secret.yml

echo "Creating application Services..."
kubectl apply -f .infrastructure/deployment/clusterIp.yml
kubectl apply -f .infrastructure/deployment/nodeport.yml

echo "Deploying application..."
kubectl apply -f .infrastructure/deployment/deployment.yml

echo "Setting up HorizontalPodAutoscaler..."
kubectl apply -f .infrastructure/deployment/hpa.yml

echo "Waiting for application deployment to be ready..."
kubectl wait --for=condition=Available deployment/todoapp -n todoapp --timeout=120s

echo "All resources have been successfully deployed!"
echo "You can access the application at http://localhost:30007"
