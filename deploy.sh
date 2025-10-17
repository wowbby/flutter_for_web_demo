#!/bin/bash

# Flutter Web 部署脚本
# 用法: ./deploy.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印彩色消息
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

# 显示帮助信息
show_help() {
    echo "Flutter Web 部署脚本"
    echo ""
    echo "用法: ./deploy.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示帮助信息"
    echo "  -b, --build-only        只构建，不部署"
    echo "  -r, --renderer [TYPE]   指定渲染器 (auto/html/canvaskit)"
    echo "  -p, --base-href [PATH]  设置 base href 路径"
    echo "  -s, --source-maps       生成源码映射文件"
    echo "  --clean                 构建前清理"
    echo ""
    echo "示例:"
    echo "  ./deploy.sh                              # 默认构建"
    echo "  ./deploy.sh --renderer html              # 使用 HTML 渲染器"
    echo "  ./deploy.sh --base-href /myapp/          # 设置子路径"
    echo "  ./deploy.sh --build-only                 # 只构建不部署"
    echo ""
}

# 默认参数
BUILD_ONLY=false
RENDERER="auto"
BASE_HREF="/"
SOURCE_MAPS=false
CLEAN=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--build-only)
            BUILD_ONLY=true
            shift
            ;;
        -r|--renderer)
            RENDERER="$2"
            shift 2
            ;;
        -p|--base-href)
            BASE_HREF="$2"
            shift 2
            ;;
        -s|--source-maps)
            SOURCE_MAPS=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 打印配置信息
print_info "==================================="
print_info "Flutter Web 构建配置"
print_info "==================================="
print_info "渲染器: $RENDERER"
print_info "Base Href: $BASE_HREF"
print_info "源码映射: $SOURCE_MAPS"
print_info "清理构建: $CLEAN"
print_info "==================================="
echo ""

# 检查 Flutter 环境
print_info "检查 Flutter 环境..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter 未安装或未添加到 PATH"
    exit 1
fi

flutter --version
echo ""

# 清理构建目录
if [ "$CLEAN" = true ]; then
    print_info "清理构建目录..."
    flutter clean
    print_success "清理完成"
    echo ""
fi

# 获取依赖
print_info "获取依赖..."
flutter pub get
print_success "依赖获取完成"
echo ""

# 构建 Web 应用
print_info "开始构建 Flutter Web 应用..."
BUILD_CMD="flutter build web --release --web-renderer=$RENDERER --base-href=$BASE_HREF"

if [ "$SOURCE_MAPS" = true ]; then
    BUILD_CMD="$BUILD_CMD --source-maps"
fi

print_info "执行命令: $BUILD_CMD"
eval $BUILD_CMD

if [ $? -eq 0 ]; then
    print_success "构建成功！"
    print_info "构建产物位于: build/web/"
    echo ""
    
    # 显示构建产物大小
    print_info "构建产物大小:"
    du -sh build/web
    du -sh build/web/* | sort -h
    echo ""
else
    print_error "构建失败！"
    exit 1
fi

# 显示下一步操作提示
print_success "==================================="
print_success "构建完成！"
print_success "==================================="
echo ""
print_info "下一步操作:"
echo ""
echo "  1. 本地预览:"
echo "     cd build/web && python3 -m http.server 8000"
echo "     然后访问 http://localhost:8000"
echo ""
echo "  2. 部署到服务器:"
echo "     scp -r build/web/* user@your-server:/var/www/html/"
echo ""
echo "  3. 部署到 Firebase:"
echo "     firebase deploy --only hosting"
echo ""
echo "  4. 部署到 GitHub Pages:"
echo "     git subtree push --prefix build/web origin gh-pages"
echo ""
echo "  5. Docker 部署:"
echo "     docker build -t flutter-web-demo ."
echo "     docker run -d -p 8080:80 flutter-web-demo"
echo ""

# 如果只构建则退出
if [ "$BUILD_ONLY" = true ]; then
    print_info "只构建模式，跳过部署步骤"
    exit 0
fi

# 询问是否本地预览
read -p "是否启动本地预览服务器？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "启动本地服务器..."
    cd build/web
    print_success "服务器已启动，访问 http://localhost:8000"
    print_warning "按 Ctrl+C 停止服务器"
    python3 -m http.server 8000
fi

