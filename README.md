# 9_gyeongbuk 인프라 프로비저닝

이 프로젝트는 AWS 기반의 완전한 클라우드 인프라를 Terraform을 사용하여 자동화합니다.

## 기능경기대회 체크리스트

### TAA 이후
- [ ] Firewall Routing 세팅 (세팅1참고)
- [ ] EKS Cluster 접근은 private으로 전환. no public.
- [ ] Bastion에 repo 넣은 후, 내부 파일들 과제지 지시대로 배치
- [ ] Helm package 후, s3 업로드. 그리고 index 생성 (세팅2참고)
- [ ] EKS에 Fluentd, ArgoCD, ALB Ingress Controller 적용
- [ ] opensearch-create-examplelog.sh 실행 및 Index Pattern 생성
- [ ] Image들 **v1.0.0** 태그로 ECR Push
- [ ] Github에 values push, s3에 app chart 업로드
- [ ] Argo App 실행

### App 배포 전
- [ ] helm chart의 version과 argo app의 target Revision이 일치하는지 확인.
- [ ] helm 배포 전 index 넣어주면 좋음. (세팅2참고)

### 채점 전 체크리스트
- [ ] VPC Endpoint에서 vpce-svc가 3개인지 확인.
- [ ] EKS Cluster가 Private 모드인지 확인.
- [ ] Bastion에서 ifconfig.me가 timeout 되는지 확인.
- [ ] Bastion에 **EIP**를 줬는지 확인.
- [ ] S3, ec2-user 디렉토리에 과제지에서 명시한 파일이 적절하게 위치해있는지 확인.
- [ ] ELB가 잘 구성되었는지 확인. 만약 이상하다면, 비상 ingress 사용해서 어떻게든 되게 만들어야 함.
- [ ] OpenSearch index-pattern이 app-log이고, 템플릿대로 로그 수집하는지, health는 안 받아오는지 확인해야 함.
- [ ] Container Insights가 정상인지 확인해야 함. -> CW에서 대시보드 확인.

## 세팅

### (세팅1) Firewall Route 설정하기
- 1. igw RTB 생성
   - (igw-rtb) edge 연결로 igw 잡고, hub public subnet들의 cidr 값과 firewall vpce 매핑
   - (firewall-rtb) 0.0.0.0/0 - igw conn
   - (pub-rtb 2개 모두) 0.0.0.0/0을 AZ에 맞는 firewall vpce와 연동.

### (세팅2) Helm chart Config
Helm 패키징
```sh
helm package app/
```

Index 생성
```sh
helm repo index . --url s3://skills-chart-bucket-<4words>/app
aws s3 cp index.yaml s3://skills-chart-bucket-<4words>/app/
```

### (세팅3) 죽어도 CW Container Insights 활성화하기 힘들다면?
그럴 때는 achimchan 계정 dummyeks 레포 eks.yaml eksctl로 생성하면 됨.

## 🏗️ 아키텍처 구성

### 3. VPC 구성

- **Hub VPC**: `10.0.0.0/16` (Bastion, Network Firewall)
- **Application VPC**: `192.168.0.0/16` (EKS, RDS, OpenSearch)
- **VPC Peering**: Hub ↔ Application VPC 간 통신

### 4. VPC Peering

- **Peering Connection**: `skills-peering`
- **라우팅**: 양방향 통신 구성

### 5. Network Firewall

- **Firewall**: `skills-firewall`
- **Policy**: `skills-firewall-policy`
- **규칙**: ifconfig.me 차단
- **Subnet**: `skills-inspect-subnet-a/b`

### 6. Bastion Server

- **Instance**: Amazon Linux 2023, t3.small
- **SSH Port**: 2025
- **Password**: `Skill53##`
- **IAM Role**: AdministratorAccess
- **Packages**: awscliv2, curl, jq, eksctl, kubectl, argocd cli, gh cli

### 7. Secret Store

- **Secret**: `skills-secrets`
- **암호화**: KMS
- **내용**: DB 연결 정보

### 9. RDBMS

- **Engine**: Aurora MySQL 8.0
- **Cluster**: `skills-db-cluster`
- **Credentials**: admin / `Skill53##`
- **Instance**: db.t3.medium

### 10. S3 Bucket

- **Bucket**: `skills-chart-bucket-sija`
- **용도**: Helm Charts, Binary Files

### 11. Container Registry

- **Repositories**: `skills-green-repo`, `skills-red-repo`
- **Features**: KMS 암호화, 취약점 분석, 불변성

### 13. Container Orchestration

- **EKS Cluster**: `skills-eks-cluster` (v1.32)
- **NodeGroups**: Application, Addon
- **Fargate**: CoreDNS 전용

### 14. Logging

- **OpenSearch**: `skills-opensearch` (v2.19)
- **Data Nodes**: 2개 (r7g.medium.search)
- **Master Nodes**: 3개
- **Index Pattern**: `app-log-*`

### 15. Load Balancer

- **Internal ALB**: `skills-alb`
- **Internal NLB**: `skills-internal-nlb`
- **External NLB**: `skills-nlb`

### 16. Monitoring

- **CloudWatch**: Container Insights
- **Metrics**: CPU, Memory, Nodes, Pods

## 🚀 설치 방법

### 전체 인프라 프로비저닝

```bash
# 전체 인프라 자동 프로비저닝
bash scripts/install-all.sh
```

### 단계별 설치

```bash
# 1. Terraform 인프라 생성
terraform init
terraform plan
terraform apply -auto-approve

# 2. EKS 클러스터 설정
aws eks update-kubeconfig --region ap-northeast-2 --name skills-eks-cluster

# 3. 상태 확인
kubectl get nodes
```

## 📋 접속 정보

### Bastion Server

- **SSH**: `ssh -p 2025 ec2-user@<bastion-ip>`
- **Password**: `Skill53##`

### OpenSearch Dashboard

- **URL**: https://skills-opensearch-vpc-xxxxxxxx.ap-northeast-2.es.amazonaws.com
- **Username**: admin
- **Password**: `Skill53##`

### RDS Database

- **Endpoint**: `<rds-endpoint>`
- **Username**: admin
- **Password**: `Skill53##`

## 🔧 유용한 명령어

### 인프라 상태 확인

```bash
# EKS 클러스터 정보
aws eks describe-cluster --region ap-northeast-2 --name skills-eks-cluster

# RDS 클러스터 정보
aws rds describe-db-clusters --db-cluster-identifier skills-db-cluster

# S3 버킷 내용
aws s3 ls s3://skills-chart-bucket-sija/ --recursive

# ECR 리포지토리 정보
aws ecr describe-repositories --repository-names skills-green-repo skills-red-repo

# OpenSearch 도메인 정보
aws opensearch describe-domain --domain-name skills-opensearch
```

### 클러스터 상태

```bash
# 노드 상태
kubectl get nodes

# 네임스페이스 확인
kubectl get namespaces
```

## 📁 프로젝트 구조

```
9_gyeongbuk/
├── main.tf                          # 메인 Terraform 설정
├── modules/                         # Terraform 모듈들
│   ├── vpc/                        # VPC 구성
│   ├── vpc_peering/                # VPC Peering
│   ├── network_firewall/           # Network Firewall
│   ├── bastion/                    # Bastion Server
│   ├── rds/                        # RDS Aurora
│   ├── s3/                         # S3 Bucket
│   ├── ecr/                        # ECR Repositories
│   ├── eks/                        # EKS Cluster
│   ├── vpc_endpoints/              # VPC Endpoints
│   ├── load_balancers/             # Load Balancers
│   ├── opensearch/                 # OpenSearch
│   └── monitoring/                 # CloudWatch
└── scripts/                        # 설치 스크립트
    └── install-all.sh              # 전체 인프라 프로비저닝
```

## 🔒 보안 구성

- **Kubernetes API**: 외부 접근 차단 (Bastion에서만 접근)
- **RDS**: Bastion에서만 접근 가능
- **Network Firewall**: ifconfig.me 차단
- **Secrets**: KMS 암호화
- **ECR**: 불변성 태그, 취약점 분석

## 📊 모니터링

- **CloudWatch Container Insights**: EKS 클러스터 모니터링
- **OpenSearch**: 로그 수집 및 분석 준비
- **Load Balancer**: 트래픽 분산 준비

## 🛠️ 문제 해결

### 일반적인 문제들

1. **EKS 노드가 준비되지 않는 경우**

   ```bash
   # 노드 상태 확인
   kubectl get nodes

   # 노드 상세 정보
   kubectl describe node <node-name>
   ```

2. **RDS 연결 실패**

   ```bash
   # RDS 상태 확인
   aws rds describe-db-clusters --db-cluster-identifier skills-db-cluster

   # 보안 그룹 확인
   aws ec2 describe-security-groups --group-ids <security-group-id>
   ```

3. **OpenSearch 접근 실패**

   ```bash
   # OpenSearch 상태 확인
   aws opensearch describe-domain --domain-name skills-opensearch

   # 엔드포인트 확인
   aws opensearch describe-domain --domain-name skills-opensearch --query 'DomainStatus.Endpoints'
   ```

## 📝 다음 단계

인프라 프로비저닝 완료 후:

1. **ArgoCD 설치 및 설정**
2. **Helm Chart 생성 및 배포**
3. **애플리케이션 배포**
4. **CI/CD 파이프라인 구성**

짜야될 파일들
- App Dockerfile (green/red) -> ecr
- App Helm Chart (green/red) -> s3
   - fluent series
   - aws secrets (w. rbac)
   - argo rollout
- argocd app