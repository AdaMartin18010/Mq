#!/bin/bash
# CI/CD配置检查脚本

set -e

echo "=== CI/CD配置检查 ==="
echo ""

check_cicd_config() {
    echo "检查CI/CD配置文件..."
    
    # 检查常见CI/CD配置文件
    CI_FILES=(
        ".github/workflows"
        ".gitlab-ci.yml"
        ".circleci/config.yml"
        "Jenkinsfile"
        ".travis.yml"
        "azure-pipelines.yml"
    )
    
    for file in "${CI_FILES[@]}"; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            echo "  ✅ $file"
        else
            echo "  ⚠️  $file (未找到)"
        fi
    done
    
    echo ""
    echo "检查Docker配置..."
    
    if [ -f "Dockerfile" ]; then
        echo "  ✅ Dockerfile"
    else
        echo "  ⚠️  Dockerfile (未找到)"
    fi
    
    if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        echo "  ✅ docker-compose.yml"
    else
        echo "  ⚠️  docker-compose.yml (未找到)"
    fi
    
    echo ""
    echo "检查Kubernetes配置..."
    
    if [ -d "k8s" ] || [ -d "kubernetes" ]; then
        K8S_COUNT=$(find k8s kubernetes -name "*.yaml" -o -name "*.yml" 2>/dev/null | wc -l)
        echo "  ✅ Kubernetes配置 ($K8S_COUNT个文件)"
    else
        echo "  ⚠️  Kubernetes配置 (未找到)"
    fi
    
    echo ""
    echo "检查部署脚本..."
    
    if [ -d "scripts" ]; then
        DEPLOY_SCRIPTS=$(find scripts -name "*deploy*" -o -name "*start*" -o -name "*stop*" 2>/dev/null | wc -l)
        echo "  ✅ 部署脚本 ($DEPLOY_SCRIPTS个)"
    else
        echo "  ⚠️  部署脚本目录 (未找到)"
    fi
}

check_cicd_config

echo ""
echo "CI/CD配置检查完成！"
