#!/bin/bash

# 인스턴스 만들고 할 일
# 1. bastion에 eip 연결
# 2. eks에 cw container insights addon 설치
# 3. 

# 인프라 프로비저닝 스크립트
set -e

echo "🚀 AWS 인프라 프로비저닝을 시작합니다..."

# 1. Terraform으로 인프라 생성
echo "📦 1단계: Terraform으로 AWS 인프라 생성 중..."
terraform init
terraform plan
terraform apply -auto-approve

# 2. EKS 클러스터 설정
echo "🔧 2단계: EKS 클러스터 설정 중..."
aws eks update-kubeconfig --region ap-northeast-2 --name skills-eks-cluster

# addon 설치


# 3. 상태 확인
echo "✅ 3단계: 인프라 상태 확인 중..."
echo "📊 EKS 노드 상태:"
kubectl get nodes

echo "📊 EKS 클러스터 정보:"
aws eks describe-cluster --region ap-northeast-2 --name skills-eks-cluster --query 'cluster.{Name:name,Version:version,Status:status,Endpoint:endpoint}' --output table

echo "📊 RDS 클러스터 정보:"
aws rds describe-db-clusters --db-cluster-identifier skills-db-cluster --query 'DBClusters[0].{Identifier:DBClusterIdentifier,Engine:Engine,Status:Status,Endpoint:Endpoint}' --output table

echo "📊 ECR 리포지토리 정보:"
aws ecr describe-repositories --repository-names skills-green-repo skills-red-repo --query 'repositories[].{Name:repositoryName,URI:repositoryUri}' --output table

echo "📊 OpenSearch 도메인 정보:"
aws opensearch describe-domain --domain-name skills-opensearch --query 'DomainStatus.{Name:DomainName,Version:EngineVersion,Status:Processing}' --output table

echo "🎉 인프라 프로비저닝이 완료되었습니다!"
echo ""
echo "📋 접속 정보:"
echo "🔗 Bastion Server: ssh -p 2025 ec2-user@<bastion-ip> (Password: Skill53##)"
echo "📊 OpenSearch Dashboard: https://skills-opensearch-vpc-xxxxxxxx.ap-northeast-2.es.amazonaws.com (admin / Skill53##)"
echo "🗄️ RDS Endpoint: <rds-endpoint> (admin / Skill53##)"
echo ""
echo "💡 다음 단계:"
echo "  - ArgoCD 설치 및 설정"
echo "  - Helm Chart 배포"
echo "  - 애플리케이션 배포"
