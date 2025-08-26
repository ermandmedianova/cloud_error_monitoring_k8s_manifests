#!/bin/bash

# GlitchTip Kubernetes Undeploy Script
# Bu script GlitchTip'i Kubernetes cluster'ınızdan kaldırır

set -e

NAMESPACE="glitchtip"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🗑️  GlitchTip Kubernetes Undeploy Başlatılıyor..."

# Ingress'i kaldır
echo "🚪 Ingress kaldırılıyor..."
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/glitchtip-ingress.yaml" --ignore-not-found

# Service'leri kaldır
echo "🌐 Services kaldırılıyor..."
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/glitchtip-service.yaml" --ignore-not-found
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/glitchtip-frontend-service.yaml" --ignore-not-found

# GlitchTip Frontend'i kaldır
echo "🌍 GlitchTip Frontend kaldırılıyor..."
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/glitchtip-frontend-deployment.yaml" --ignore-not-found

# GlitchTip Worker'ı kaldır
echo "👷 GlitchTip Worker kaldırılıyor..."
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/glitchtip-worker-deployment.yaml" --ignore-not-found

# GlitchTip Backend'i kaldır
echo "🖥️  GlitchTip Backend kaldırılıyor..."
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/glitchtip-backend-deployment.yaml" --ignore-not-found

# Redis'i kaldır
echo "📮 Redis kaldırılıyor..."
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/redis-deployment.yaml" --ignore-not-found

# PostgreSQL'i kaldır
echo "🐘 PostgreSQL kaldırılıyor..."
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/postgres-deployment.yaml" --ignore-not-found

# Secrets ve ConfigMaps'i kaldır
echo "🔐 Secrets ve ConfigMaps kaldırılıyor..."
kubectl delete -n $NAMESPACE -f "$SCRIPT_DIR/configmap-secret.yaml" --ignore-not-found

echo ""
echo "⚠️  PersistentVolumeClaim'ler korundu. Veri kaybını önlemek için elle silinmeleri gerekiyor:"
echo "kubectl delete pvc -n $NAMESPACE postgres-pvc redis-pvc glitchtip-media-pvc"
echo ""

# Namespace'i kaldır (opsiyonel)
read -p "🗑️  Namespace'i de kaldırmak istiyor musunuz? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "📦 Namespace kaldırılıyor: $NAMESPACE"
    kubectl delete namespace $NAMESPACE --ignore-not-found
else
    echo "📦 Namespace korundu: $NAMESPACE"
fi

echo ""
echo "✅ GlitchTip başarıyla kaldırıldı!"
