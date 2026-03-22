Param(
    [Parameter(Mandatory = $true)]
    [string]$Domain,
    [Parameter(Mandatory = $true)]
    [string]$Email,
    [string]$ServerHost = "101.133.161.203",
    [string]$User = "root",
    [string]$KeyPath = "$env:USERPROFILE\.ssh\CodexKey.pem",
    [string]$ProjectRoot = "/opt/elitesync/services/backend-laravel"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $KeyPath)) {
    throw "SSH key not found: $KeyPath"
}

$remoteScript = @"
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y certbot python3-certbot-nginx

cat > /etc/nginx/sites-available/elitesync.conf <<'NGINXCONF'
server {
    listen 80;
    listen [::]:80;
    server_name DOMAIN_PLACEHOLDER;
    root PROJECT_PLACEHOLDER/public;
    index index.php index.html;

    location ^~ /api/v1/messages/ws/ {
        proxy_http_version 1.1;
        proxy_set_header Upgrade @@DOLLAR@@http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host @@DOLLAR@@host;
        proxy_set_header X-Real-IP @@DOLLAR@@remote_addr;
        proxy_set_header X-Forwarded-For @@DOLLAR@@proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto @@DOLLAR@@scheme;
        proxy_pass http://127.0.0.1:8081;
    }

    location / {
        try_files @@DOLLAR@@uri @@DOLLAR@@uri/ /index.php?@@DOLLAR@@query_string;
    }

    location ~ \\.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\\.(?!well-known).* {
        deny all;
    }
}
NGINXCONF

sed -i "s#DOMAIN_PLACEHOLDER#DOMAIN_VALUE#g" /etc/nginx/sites-available/elitesync.conf
sed -i "s#PROJECT_PLACEHOLDER#PROJECT_VALUE#g" /etc/nginx/sites-available/elitesync.conf

rm -f /etc/nginx/sites-enabled/default || true
ln -sf /etc/nginx/sites-available/elitesync.conf /etc/nginx/sites-enabled/elitesync.conf
nginx -t
systemctl restart nginx

certbot --nginx -d DOMAIN_VALUE --non-interactive --agree-tos -m EMAIL_VALUE --redirect

cd PROJECT_VALUE
sed -i 's#^APP_URL=.*#APP_URL=https://DOMAIN_VALUE#' .env
if grep -q '^SECURITY_ENFORCE_HTTPS=' .env; then
  sed -i 's#^SECURITY_ENFORCE_HTTPS=.*#SECURITY_ENFORCE_HTTPS=true#' .env
else
  echo 'SECURITY_ENFORCE_HTTPS=true' >> .env
fi

php artisan config:cache
php artisan route:cache
php artisan view:cache
systemctl restart php8.4-fpm nginx elitesync-ws

curl -sS -o /dev/null -w '%{http_code}\n' https://DOMAIN_VALUE/up
"@

$remoteScript = $remoteScript.Replace("DOMAIN_VALUE", $Domain).Replace("EMAIL_VALUE", $Email).Replace("PROJECT_VALUE", $ProjectRoot).Replace("@@DOLLAR@@", "$")

$tmp = Join-Path $env:TEMP "elitesync_https_enable.sh"
Set-Content -Path $tmp -Value $remoteScript -Encoding ascii

scp -o StrictHostKeyChecking=no -i $KeyPath $tmp "$User@${ServerHost}:/tmp/elitesync_https_enable.sh"
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i $KeyPath "$User@$ServerHost" "bash /tmp/elitesync_https_enable.sh"

Write-Host "HTTPS/WSS enable flow finished for domain: $Domain"
