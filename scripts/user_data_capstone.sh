#!/bin/bash
set -e

dnf update -y
dnf install -y httpd php php-mysqlnd php-fpm php-json php-mbstring php-xml php-gd docker stress-ng

systemctl enable --now docker httpd

cat <<EOF > /home/ec2-user/.env
SUPABASE_URL=${supabase_url}
SUPABASE_ANON_KEY=${supabase_amon_key}
RDS_CONN_STRING=postgresql+psycopg2://${db_username}:${db_password}@${rds_endpoint}/${db_name}
EOF

docker run -d -p 80:8501 --env-file /home/ec2-user/.env --name aws-tools-app shaahin1359/aws-tools-app:v1.0.2

# Create IP info page showing instance details from metadata
cat << 'EOF' | tee /var/www/html/ip.php
<?php
$token = shell_exec("curl -s -X PUT 'http://169.254.169.254/latest/api/token' -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600'");
$az       = shell_exec("curl -s -H 'X-aws-ec2-metadata-token: $token' http://169.254.169.254/latest/meta-data/placement/availability-zone");
$id       = shell_exec("curl -s -H 'X-aws-ec2-metadata-token: $token' http://169.254.169.254/latest/meta-data/instance-id");
$local_ip = shell_exec("curl -s -H 'X-aws-ec2-metadata-token: $token' http://169.254.169.254/latest/meta-data/local-ipv4");
echo "<h2>Instance ID: $id</h2>";
echo "<h2>Private IP: $local_ip</h2>";
echo "<h2>Availability Zone: $az</h2>";
?>
EOF

stress-ng --cpu 0 --cpu-load 80 --timeout 5m

# Restart Apache
sudo systemctl restart httpd
