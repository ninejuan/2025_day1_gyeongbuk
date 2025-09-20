# WorldSkills Korea National 2025 Cloud Computing Day1 - Gyeongbuk Terraform

---

### 지금 고민중인 내용
```
- App 배포를 Ingress가 아닌 TargetGroupBinding으로 바꾸면 어떨까? 그러면 굳이 ELB 생성하고 TG 빼서 끼우는걸 안해도 되지 않을까?
```

## 체크리스트

### TAA 이후
- [ ] Firewall Routing 세팅 (세팅1참고)
- [ ] EKS Cluster 접근은 private으로 전환. no public.
- [ ] Bastion에 argocli, gh, awscli 세팅
- [ ] Bastion에 repo 넣은 후, 내부 파일들 과제지 지시대로 배치
- [ ] EKS에 ALB Ingress Controller, Fluentd, ArgoCD, Argo Repo Server 패치(세팅3참고) 적용
- [ ] Helm package 후, s3 업로드. 그리고 index, secrets 생성 (세팅2참고)
- [ ] Github에 values push하고, Argo App 배포.

### App 배포 전
- [ ] helm chart의 version과 argo app의 target Revision이 일치하는지 확인.
- [ ] helm 배포 전 index 넣어주면 좋음. (세팅2참고)

### 채점 전 체크리스트
- [ ] VPC Endpoint에서 vpce-svc가 3개인지 확인.
- [ ] EKS Cluster가 Private 모드인지 확인.
- [ ] Bastion에서 ifconfig.me가 timeout 되는지 확인.
- [ ] S3, ec2-user 디렉토리에 과제지에서 명시한 파일이 적절하게 위치해있는지 확인.
- [ ] K8s pods에 app label이 잘 구성되어 있는지 확인.
- [ ] ELB가 잘 구성되었는지 확인. 만약 이상하다면, 비상 ingress 사용해서 어떻게든 되게 만들어야 함.
- [ ] OpenSearch index-pattern이 app-log이고, 템플릿대로 로그 수집되었는지, health는 안 받아오는지 확인해야 함.
- [ ] Container Insights가 정상인지 확인해야 함. -> CW에서 대시보드 확인.

## 세팅

### (세팅1) Firewall Route 설정하기
- 1. igw RTB 생성
   - (igw-rtb) edge 연결로 igw 잡고, hub public subnet들의 cidr 값과 firewall vpce 매핑
   - (firewall-rtb) 0.0.0.0/0 - igw conn
   - (pub-rtb 2개 모두) 0.0.0.0/0을 AZ에 맞는 firewall vpce와 연동.

### (세팅2) Helm Tips
Commands. 아래 s3a는 예시 repo name이므로 자유롭게 수정하셔도 됩니다.  
```sh
# Helm packaging
helm package app/

# Install Helm-s3 plugin
helm plugin install https://github.com/hypnoglow/helm-s3.git

# Init S3 helm repo
helm s3 init s3://<bucket-name>/app

# Add helm repo (S3 protocol)
helm repo add s3a s3://<bucket-name>/app

# Pull s3a repo
helm pull s3a/app --version "1.0.0"

# Push helm chart to s3 repo
helm s3 push app-1.0.0.tgz s3a # --force if u get err

# Generate helm chart index
helm repo index . --url s3://<bucket-name>/app
aws s3 cp index.yaml s3://<bucket-name>/app

# Regenerate helm chart index
helm s3 reindex s3a
```
만약 Helm chart 업데이트 했는데 반영 안되면 App 리스트 페이지에서 Hard refresh 할 수 있음.

### (세팅3) Argo Repo Server Patch 적용하기
```sh
cd app-files/k8s
kubectl -n argocd patch deployment argocd-repo-server --patch-file patch-argo-reposerver.yaml
```

### (세팅4) OpenSearch 딸깍하기
`opensearch-create-examplelog.sh` 한번 실행 후, OpenSearch에서 index pattern 생성하면 됨.  
그러면 11번 모두 정답 나오게 됨.  

### (세팅5) 죽어도 CW Container Insights 활성화하기 힘들다면?
그럴 때는 achimchan 계정 dummyeks 레포 eks.yaml eksctl로 생성하면 됨.