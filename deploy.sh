#!/bin/bash

# GlitchTip Kubernetes Deployment Script
# Bu script GlitchTip'i Kubernetes cluster'ınıza deploy eder

set -e

NAMESPACE="glitchtip"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 GlitchTip Kubernetes Deployment Başlatılıyor..."

# Namespace oluştur
echo "📦 Namespace oluşturuluyor: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Secrets ve ConfigMaps'i apply et
echo "🔐 Secrets ve ConfigMaps uygulanıyor..."
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/config/configmap-secret.yaml"

# PostgreSQL deploy et
echo "🐘 PostgreSQL deploy ediliyor..."
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/db/postgres-deployment.yaml"

# Redis deploy et
echo "📮 Redis deploy ediliyor..."
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/redis/redis-deployment.yaml"

# PostgreSQL ve Redis'in hazır olmasını bekle
echo "⏳ PostgreSQL ve Redis'in hazır olması bekleniyor..."
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=300s
kubectl wait --for=condition=ready pod -l app=redis -n $NAMESPACE --timeout=300s

# GlitchTip Backend deploy et
echo "🖥️  GlitchTip Backend deploy ediliyor..."
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/backend/glitchtip-backend-deployment.yaml"

# GlitchTip Worker deploy et
echo "👷 GlitchTip Worker deploy ediliyor..."
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/backend/glitchtip-worker-deployment.yaml"

# GlitchTip Frontend deploy et
echo "🌍 GlitchTip Frontend deploy ediliyor..."
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/frontend/glitchtip-frontend-deployment.yaml"

# Service'leri deploy et
echo "🌐 Services deploy ediliyor..."
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/backend/glitchtip-backend-service.yaml"
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/frontend/glitchtip-frontend-service.yaml"

# Ingress deploy et
echo "🚪 Ingress deploy ediliyor..."
kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR/frontend/glitchtip-ingress.yaml"


echo ""
echo "✅ GlitchTip başarıyla deploy edildi!"
echo ""
echo "📋 Deployment bilgileri:"
echo "Namespace: $NAMESPACE"
echo ""
echo "🔍 Pod'ları kontrol etmek için:"
echo "kubectl get pods -n $NAMESPACE"
echo ""
echo "📱 Service'leri görmek için:"
echo "kubectl get services -n $NAMESPACE"
echo ""
echo "🌍 Ingress bilgilerini görmek için:"
echo "kubectl get ingress -n $NAMESPACE"
echo ""
echo "📊 Deployment durumunu kontrol etmek için:"
echo "kubectl get deployments -n $NAMESPACE"
echo ""
echo "🔗 GlitchTip'e erişmek için Ingress'te tanımlanan domain'i kullanın"
echo "   (Önce /etc/hosts dosyanızı güncellemeyi veya DNS ayarlarını yapmayı unutmayın)"
echo ""
echo "⚠️  Önemli Notlar:"
echo "1. ConfigMap'teki GLITCHTIP_URL değerini kendi domain'inizle değiştirin"
echo "2. Secret'taki secret-key ve database-password değerlerini güvenli değerlerle değiştirin"
echo "3. Ingress'teki host değerini kendi domain'inizle değiştirin"
echo "4. SSL sertifikası için cert-manager kurabilir ve TLS ayarlarını aktif edebilirsiniz"
echo ""
echo "🧹 Temizlik için:"
echo "./undeploy.sh"
