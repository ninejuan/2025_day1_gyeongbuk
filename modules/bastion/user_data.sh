#!/bin/bash

# Update system
yum update -y

# Install required packages
yum install -y awscli2 curl jq nano 

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Install GitHub CLI
yum install -y dnf
dnf install -y 'dnf-command(config-manager)'
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf install -y gh

# Change SSH port
sed -i "s/#Port 22/Port ${ssh_port}/" /etc/ssh/sshd_config
systemctl restart sshd

# Set password for ec2-user
echo "ec2-user:${login_password}" | chpasswd

# Create SSH directory and set permissions
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

# Create images directory structure
mkdir -p /home/ec2-user/images/green
mkdir -p /home/ec2-user/images/red
chown -R ec2-user:ec2-user /home/ec2-user/images

# Create Dockerfile for Green application
cat > /home/ec2-user/images/green/Dockerfile << 'EOF'
FROM alpine:latest
RUN apk add --no-cache curl
COPY green_1.0.1 /app/green_1.0.1
EXPOSE 8080
CMD ["/app/green_1.0.1"]
EOF

# Create Dockerfile for Red application
cat > /home/ec2-user/images/red/Dockerfile << 'EOF'
FROM alpine:latest
RUN apk add --no-cache curl
COPY red_1.0.1 /app/red_1.0.1
EXPOSE 8080
CMD ["/app/red_1.0.1"]
EOF

# Set permissions for Dockerfiles
chown -R ec2-user:ec2-user /home/ec2-user/images/green/Dockerfile
chown -R ec2-user:ec2-user /home/ec2-user/images/red/Dockerfile

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Download binaries from S3 and build Docker images
cd /home/ec2-user/images

# Get AWS region and account ID
AWS_REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="skills-chart-bucket-sija"

# Download binaries from S3
aws s3 cp s3://$BUCKET_NAME/images/green_1.0.1 green/
aws s3 cp s3://$BUCKET_NAME/images/red_1.0.1 red/

# Set permissions
chmod +x green/green_1.0.1
chmod +x red/red_1.0.1

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push Green image
cd green
docker build -t $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/skills-green-repo:v1.0.0 .
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/skills-green-repo:v1.0.0

# Build and push Red image
cd ../red
docker build -t $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/skills-red-repo:v1.0.0 .
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/skills-red-repo:v1.0.0

cd ~

# Install curl in containers (for future use)
echo '#!/bin/bash' > /usr/local/bin/install-curl
echo 'yum install -y curl' >> /usr/local/bin/install-curl
chmod +x /usr/local/bin/install-curl 