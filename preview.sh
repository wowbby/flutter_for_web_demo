#!/bin/bash

# Flutter Web 本地预览脚本
# 用法: ./preview.sh

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}Flutter Web 本地预览${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# 检查构建目录是否存在
if [ ! -d "build/web" ]; then
    echo -e "${BLUE}[INFO]${NC} 构建目录不存在，开始构建..."
    flutter build web --release
    echo ""
fi

# 启动本地服务器
echo -e "${GREEN}[SUCCESS]${NC} 启动本地预览服务器..."
echo -e "${BLUE}[INFO]${NC} 访问地址: http://localhost:8000"
echo -e "${BLUE}[INFO]${NC} 按 Ctrl+C 停止服务器"
echo ""

cd build/web
python3 -m http.server 8000

