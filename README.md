# GlitchTip Kubernetes Deployment

Bu klasör GlitchTip'i Kubernetes cluster'ına deploy etmek için gerekli manifest dosyalarını içerir.

## Önkoşullar

1. Çalışan bir Kubernetes cluster'ı
2. `kubectl` komutunun kurulu ve cluster'a bağlı olması
3. NGINX Ingress Controller (veya başka bir ingress controller)
4. Persistent Volume desteği

## Dosyalar

- `postgres-deployment.yaml` - PostgreSQL database deployment, service ve PVC
- `redis-deployment.yaml` - Redis deployment, service ve PVC
- `configmap-secret.yaml` - GlitchTip environment variables ve secrets
- `glitchtip-backend-deployment.yaml` - GlitchTip web server deployment ve PVC
- `glitchtip-worker-deployment.yaml` - GlitchTip Celery worker deployment
- `glitchtip-frontend-deployment.yaml` - GlitchTip Angular frontend deployment
- `glitchtip-service.yaml` - GlitchTip backend service
- `glitchtip-frontend-service.yaml` - GlitchTip frontend service
- `glitchtip-ingress.yaml` - HTTP/HTTPS trafiği için ingress
- `deploy.sh` - Otomatik deployment script'i
- `undeploy.sh` - Uygulamayı kaldırma script'i

## Deployment Öncesi Yapılması Gerekenler

### 1. Domain ve URL Ayarları

`configmap-secret.yaml` dosyasındaki aşağıdaki değeri kendi domain'inizle değiştirin:

```yaml
GLITCHTIP_URL: "https://glitchtip.example.com" # Kendi domain'iniz
```

`glitchtip-ingress.yaml` dosyasındaki host değerini değiştirin:

```yaml
- host: glitchtip.example.com # Kendi domain'iniz
```

### 2. Secret Değerlerini Değiştirin

`configmap-secret.yaml` dosyasındaki secret değerlerini güvenli olanlarla değiştirin:

**Temel Secret'lar:**

- `secret-key`: Django SECRET_KEY (güvenli bir değer)
- `database-password`: PostgreSQL şifresi

**AI Platform Ayarları (Opsiyonel):**

- `ai-platform`: "openai" veya "anthropic"
- `openai-api-key`: OpenAI API anahtarınız
- `anthropic-api-key`: Anthropic API anahtarınız
- `openai-model`: Kullanılacak OpenAI model
- `anthropic-model`: Kullanılacak Anthropic model

**ClickUp Entegrasyonu (Opsiyonel):**

- `clickup-api-token`: ClickUp API token'ınız
- `clickup-list-id`: ClickUp liste ID'si
- `clickup-parent-task-id`: Ana görev ID'si
- `clickup-assignee-id`: Atanan kişi ID'si

**Celery Worker Ayarları:**

- `celery-worker-concurrency`: Worker concurrency (varsayılan: 4)
- `celery-worker-prefetch-multiplier`: Prefetch multiplier (varsayılan: 25)
- `celery-worker-pool`: Worker pool tipi (varsayılan: threads)

Not: stringData formatı kullanıldığı için Base64 encoding gerekmez.

### 3. Docker Image'larını Hazırlayın

Backend, worker ve frontend deployment'larında image adreslerini güncelleyin:

**Backend & Worker için:**

- Kendi container registry'nizde build ettiğiniz image'ları kullanın
- Veya DockerHub'daki resmi GlitchTip image'ını kullanın

**Frontend için:**

- Frontend klasöründe `docker build -t glitchtip/glitchtip-frontend:latest .` komutuyla image build edin
- Kendi container registry'nize push edin
- Deployment dosyasındaki image adresini güncelleyin

## Deployment

### Otomatik Deployment

```bash
# Deploy script'ini çalıştırın
./deploy.sh
```

### Manuel Deployment

```bash
# Namespace oluşturun
kubectl create namespace glitchtip

# Sırasıyla apply edin
kubectl apply -n glitchtip -f configmap-secret.yaml
kubectl apply -n glitchtip -f postgres-deployment.yaml
kubectl apply -n glitchtip -f redis-deployment.yaml
kubectl apply -n glitchtip -f glitchtip-backend-deployment.yaml
kubectl apply -n glitchtip -f glitchtip-worker-deployment.yaml
kubectl apply -n glitchtip -f glitchtip-frontend-deployment.yaml
kubectl apply -n glitchtip -f glitchtip-service.yaml
kubectl apply -n glitchtip -f glitchtip-frontend-service.yaml
kubectl apply -n glitchtip -f glitchtip-ingress.yaml
```

## Deployment Sonrası

### Durumu Kontrol Edin

```bash
# Pod'ları kontrol edin
kubectl get pods -n glitchtip

# Service'leri kontrol edin
kubectl get services -n glitchtip

# Ingress'i kontrol edin
kubectl get ingress -n glitchtip
```

### Log'ları Kontrol Edin

```bash
# Backend log'ları
kubectl logs -f deployment/glitchtip-backend -n glitchtip

# Worker log'ları
kubectl logs -f deployment/glitchtip-worker -n glitchtip

# Frontend log'ları
kubectl logs -f deployment/glitchtip-frontend -n glitchtip
```

### Ilk Kullanıcıyı Oluşturun

```bash
# Backend pod'una bağlanın
kubectl exec -it deployment/glitchtip-backend -n glitchtip -- bash

# Superuser oluşturun
./manage.py createsuperuser
```

## SSL/TLS Ayarları (Opsiyonel)

Cert-manager kurulu ise `glitchtip-ingress.yaml` dosyasındaki TLS bölümünü aktif edin:

```yaml
metadata:
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
    - hosts:
        - glitchtip.example.com
      secretName: glitchtip-tls
```

## Uygulamayı Kaldırma

```bash
./undeploy.sh
```

## Sorun Giderme

### 1. Pod'lar Başlamıyor

```bash
kubectl describe pod <pod-name> -n glitchtip
```

### 2. Database Bağlantı Sorunu

PostgreSQL pod'unun çalıştığını ve backend'in database ayarlarını kontrol edin.

### 3. Redis Bağlantı Sorunu

Redis pod'unun çalıştığını ve worker'ın Redis ayarlarını kontrol edin.

### 4. Ingress Erişim Sorunu

- Ingress controller'ın çalıştığını kontrol edin
- DNS ayarlarını kontrol edin
- Domain'in cluster'a yönlendirildiğini kontrol edin

## Önemli Notlar

1. **Güvenlik**: Production ortamında mutlaka güvenli secret'lar kullanın
2. **Backup**: PostgreSQL veritabanının düzenli backup'ını alın
3. **Monitoring**: Resource kullanımını ve performansı izleyin
4. **Scaling**: İhtiyaç halinde replica sayılarını artırın

## Destek

GlitchTip ile ilgili sorularınız için:

- [GlitchTip Documentation](https://glitchtip.com/documentation/)
- [GlitchTip GitHub](https://github.com/mikekosulin/glitchtip-frontend)
