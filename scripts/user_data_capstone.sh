#!/bin/bash
set -e
yum install -y docker
systemctl enable --now docker

cat <<EOF > /home/ec2-user/.env
SUPABASE_URL=${supabase_url}
SUPABASE_ANON_KEY=${supabase_amon_key}
AWS_SESSION_KEY=${aws_session_key}
RDS_CONN_STRING=postgresql+psycopg2://${db_username}:${db_password}@${rds_endpoint}/${db_name}
EOF

docker run -d -p 80:8501 --env-file /home/ec2-user/.env --name aws-tools-app shaahin1359/aws-tools-app:v1.0.5
