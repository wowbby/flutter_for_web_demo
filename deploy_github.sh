#!/bin/bash

# GitHub Pages 快速部署脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
print_info "=================================="
print_info "GitHub Pages 部署脚本"
print_info "=================================="
echo ""

# 检查 Git 是否初始化
if [ ! -d ".git" ]; then
    print_warning "Git 仓库未初始化"
    read -p "是否初始化 Git 仓库？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        print_success "Git 仓库初始化完成"
    else
        print_error "需要 Git 仓库才能继续"
        exit 1
    fi
fi

# 检查远程仓库
if ! git remote | grep -q origin; then
    print_warning "未配置远程仓库"
    echo ""
    print_info "请在 GitHub 上创建仓库，然后输入仓库地址："
    echo "格式：https://github.com/用户名/仓库名.git"
    read -p "远程仓库地址: " repo_url
    
    if [ -n "$repo_url" ]; then
        git remote add origin "$repo_url"
        print_success "远程仓库添加成功"
    else
        print_error "远程仓库地址不能为空"
        exit 1
    fi
fi

# 获取远程仓库 URL
REMOTE_URL=$(git remote get-url origin)
print_info "远程仓库: $REMOTE_URL"

# 提取仓库名
REPO_NAME=$(basename "$REMOTE_URL" .git)
print_info "仓库名: $REPO_NAME"

echo ""
print_info "开始部署流程..."
echo ""

# 1. 添加所有文件
print_info "1/5 添加文件到 Git..."
git add .

# 2. 提交更改
print_info "2/5 提交更改..."
read -p "提交信息 (默认: Update deployment): " commit_msg
commit_msg=${commit_msg:-"Update deployment"}
git commit -m "$commit_msg" || print_warning "没有新的更改需要提交"

# 3. 推送到 GitHub
print_info "3/5 推送到 GitHub..."
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
    BRANCH="main"
    git branch -M main
fi
print_info "当前分支: $BRANCH"

if git push -u origin "$BRANCH"; then
    print_success "推送成功"
else
    print_error "推送失败，请检查权限和网络"
    exit 1
fi

# 4. 等待 GitHub Actions
print_info "4/5 GitHub Actions 正在构建部署..."
print_info "查看构建状态: ${REMOTE_URL%.git}/actions"
echo ""
print_warning "请等待 2-3 分钟让 GitHub Actions 完成构建"
echo ""

# 5. 提示配置 GitHub Pages
print_info "5/5 配置 GitHub Pages"
echo ""
print_info "请按以下步骤操作："
echo "  1. 访问: ${REMOTE_URL%.git}/settings/pages"
echo "  2. Source 选择: 'Deploy from a branch'"
echo "  3. Branch 选择: 'gh-pages' 和 'root'"
echo "  4. 点击 Save"
echo ""

# 提取用户名
if [[ $REMOTE_URL =~ github.com[:/]([^/]+) ]]; then
    USERNAME="${BASH_REMATCH[1]}"
    PAGES_URL="https://${USERNAME}.github.io/${REPO_NAME}/"
    
    print_success "=================================="
    print_success "部署完成！"
    print_success "=================================="
    echo ""
    print_info "你的应用将在以下地址可用："
    echo ""
    echo "  🌐 $PAGES_URL"
    echo ""
    print_info "在应用内加载时使用："
    echo ""
    echo "  controller.loadRequest(Uri.parse('$PAGES_URL'));"
    echo ""
    
    # 询问是否打开浏览器
    read -p "是否在浏览器中打开？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v open &> /dev/null; then
            open "$PAGES_URL"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$PAGES_URL"
        else
            print_info "请手动访问: $PAGES_URL"
        fi
    fi
else
    print_warning "无法提取用户名，请手动检查部署地址"
fi

echo ""
print_info "查看详细文档: cat DEPLOY_GITHUB.md"
echo ""

