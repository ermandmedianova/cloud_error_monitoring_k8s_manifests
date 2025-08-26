#!/bin/bash

# Docker Image Build Script for GlitchTip
# Bu script GlitchTip frontend ve backend image'larını build eder

set -e

REGISTRY="ermand172"  # Change this to your registry
TAG=$(openssl rand -hex 8)  # Generate random hexadecimal tag

echo "🐳 GlitchTip Docker Image'ları Build Ediliyor..."

# Backend image build et
echo "🖥️  Backend image build ediliyor..."
cd ../cloud_error_monitoring_backend
docker build --no-cache -t glitchtip/glitchtip-backend:$TAG .
docker tag glitchtip/glitchtip-backend:$TAG $REGISTRY/glitchtip-backend:$TAG

# Frontend image build et
echo "🌍 Frontend image build ediliyor..."
cd ../cloud_error_monitoring_frontend
docker build -t glitchtip/glitchtip-frontend:$TAG .
docker tag glitchtip/glitchtip-frontend:$TAG $REGISTRY/glitchtip-frontend:$TAG

echo ""
echo "✅ Docker image'ları başarıyla build edildi!"
echo ""
echo "📤 Registry'ye push ediliyor..."
docker push $REGISTRY/glitchtip-backend:$TAG
docker push $REGISTRY/glitchtip-frontend:$TAG

echo ""
echo "🔄 Kubernetes deployment dosyaları güncelleniyor..."

cd ../cloud_error_monitoring_k8s_manifests

# Update backend deployment
sed -i "s|image: glitchtip/glitchtip-backend:.*|image: $REGISTRY/glitchtip-backend:$TAG|g" glitchtip-backend-deployment.yaml

# Update worker deployment  
sed -i "s|image: glitchtip/glitchtip-backend:.*|image: $REGISTRY/glitchtip-backend:$TAG|g" glitchtip-worker-deployment.yaml

# Update frontend deployment
sed -i "s|image: glitchtip/glitchtip-frontend:.*|image: $REGISTRY/glitchtip-frontend:$TAG|g" glitchtip-frontend-deployment.yaml

echo ""
echo "✅ Tüm işlemler tamamlandı!"
echo ""
echo "📋 Kullanılan TAG: $TAG"
echo "📋 Registry: $REGISTRY"
echo ""
echo "🚀 Deploy etmek için:"
echo "./deploy.sh"
