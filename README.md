# Flutter Web Demo

这是一个完整的 Flutter Web 应用示例项目，可以直接编译打包并部署到生产环境。

## 📋 项目简介

本项目展示了如何创建、开发和部署一个 Flutter Web 应用。包含：
- ✨ 现代化的 UI 设计（Material Design 3）
- 🌓 支持浅色/深色主题自动切换
- 📱 响应式布局，适配各种屏幕尺寸
- 🚀 优化的加载体验
- 🔍 完整的 SEO 配置
- 📦 生产环境构建优化

## 🛠️ 开发环境要求

- **Flutter SDK**: 3.0.0 或更高版本
- **Dart SDK**: 3.0.0 或更高版本
- **支持的浏览器**: Chrome, Safari, Firefox, Edge (最新版本)

### 检查 Flutter 环境

```bash
flutter --version
flutter doctor
```

## 🚀 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 本地运行

```bash
# 在 Chrome 浏览器中运行
flutter run -d chrome

# 或者启动开发服务器（支持热重载）
flutter run -d web-server --web-port=8080
```

访问 `http://localhost:8080` 即可查看应用。

### 3. 开发调试

```bash
# 启用详细日志
flutter run -d chrome --verbose

# 在特定浏览器中运行
flutter run -d edge        # Microsoft Edge
flutter run -d firefox     # Firefox
```

## 📦 构建生产版本

### 标准构建

```bash
flutter build web
```

构建产物会生成在 `build/web/` 目录下。

### 优化构建选项

```bash
# 使用 CanvasKit 渲染器（推荐用于桌面端，性能更好）
flutter build web --web-renderer canvaskit

# 使用 HTML 渲染器（更小的包体积，适合移动端）
flutter build web --web-renderer html

# 自动选择渲染器（默认选项）
flutter build web --web-renderer auto

# 指定 base href（用于子路径部署）
flutter build web --base-href /myapp/

# Release 模式构建（生产环境推荐）
flutter build web --release

# 添加源码映射（便于调试）
flutter build web --source-maps
```

### 构建产物说明

构建完成后，`build/web/` 目录包含：
- `index.html` - 应用入口
- `main.dart.js` - 编译后的应用代码
- `assets/` - 资源文件
- `icons/` - 应用图标
- `manifest.json` - PWA 配置
- `favicon.png` - 网站图标

## 🌐 部署指南

### 方案 1：部署到 Nginx

#### 1.1 安装 Nginx

```bash
# macOS
brew install nginx

# Ubuntu/Debian
sudo apt-get install nginx

# CentOS/RHEL
sudo yum install nginx
```

#### 1.2 配置 Nginx

创建配置文件 `/etc/nginx/sites-available/flutter_web_demo`:

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名
    
    root /var/www/flutter_web_demo;  # 指向 build/web 目录
    index index.html;
    
    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    location / {
        try_files $uri $uri/ /index.html;
        
        # 添加缓存头
        add_header Cache-Control "public, max-age=3600";
    }
    
    # 静态资源缓存策略
    location ~* \.(js|css|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # PWA manifest 和 service worker
    location ~* (manifest\.json|flutter_service_worker\.js)$ {
        add_header Cache-Control "no-cache";
    }
}
```

#### 1.3 部署步骤

```bash
# 1. 复制构建产物到服务器
scp -r build/web/* user@your-server:/var/www/flutter_web_demo/

# 2. 启用配置
sudo ln -s /etc/nginx/sites-available/flutter_web_demo /etc/nginx/sites-enabled/

# 3. 测试配置
sudo nginx -t

# 4. 重启 Nginx
sudo systemctl restart nginx
```

### 方案 2：部署到 Apache

#### 2.1 安装 Apache

```bash
# Ubuntu/Debian
sudo apt-get install apache2

# CentOS/RHEL
sudo yum install httpd
```

#### 2.2 创建 .htaccess 文件

在 `build/web/` 目录创建 `.htaccess`:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^.*$ index.html [L]
</IfModule>

# Gzip 压缩
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>

# 缓存设置
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/html "access plus 1 hour"
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType text/javascript "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
</IfModule>
```

#### 2.3 部署步骤

```bash
# 1. 复制构建产物
sudo cp -r build/web/* /var/www/html/flutter_web_demo/

# 2. 启用必要的 Apache 模块
sudo a2enmod rewrite
sudo a2enmod deflate
sudo a2enmod expires

# 3. 重启 Apache
sudo systemctl restart apache2
```

### 方案 3：部署到 GitHub Pages

#### 3.1 添加 GitHub Actions 工作流

创建 `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build Web
      run: flutter build web --release --base-href /flutter_for_web_demo/
    
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
```

#### 3.2 配置 GitHub Pages

1. 推送代码到 GitHub 仓库
2. 进入仓库 Settings → Pages
3. Source 选择 `gh-pages` 分支
4. 点击 Save

访问 `https://your-username.github.io/flutter_for_web_demo/`

### 方案 4：部署到 Firebase Hosting

#### 4.1 安装 Firebase CLI

```bash
npm install -g firebase-tools
```

#### 4.2 初始化 Firebase

```bash
firebase login
firebase init hosting
```

配置选项：
- Public directory: `build/web`
- Configure as single-page app: `Yes`
- Automatic builds with GitHub: 根据需要选择

#### 4.3 部署

```bash
# 构建应用
flutter build web --release

# 部署到 Firebase
firebase deploy --only hosting
```

### 方案 5：部署到 Vercel

#### 5.1 安装 Vercel CLI

```bash
npm install -g vercel
```

#### 5.2 配置 vercel.json

创建 `vercel.json`:

```json
{
  "version": 2,
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

#### 5.3 部署

```bash
vercel
```

### 方案 6：Docker 容器化部署

#### 6.1 创建 Dockerfile

创建 `Dockerfile`:

```dockerfile
# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# Runtime stage
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

创建 `nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
```

#### 6.2 构建和运行

```bash
# 构建镜像
docker build -t flutter-web-demo .

# 运行容器
docker run -d -p 8080:80 flutter-web-demo

# 访问应用
open http://localhost:8080
```

## 🔧 常见问题

### Q1: 构建后文件太大怎么办？

**A**: 使用以下优化方案：

```bash
# 使用 HTML 渲染器减小包体积
flutter build web --web-renderer html

# 启用代码分割
flutter build web --split-debug-info=build/debug-info

# 移除未使用的代码
flutter build web --tree-shake-icons
```

### Q2: 页面加载慢怎么优化？

**A**: 
1. 启用服务器 Gzip 压缩
2. 配置 CDN 加速
3. 使用 Service Worker 缓存
4. 优化图片资源（使用 WebP 格式）
5. 启用浏览器缓存策略

### Q3: 路由刷新 404 错误？

**A**: 确保服务器配置了路由重写规则，将所有请求重定向到 `index.html`。

### Q4: 跨域问题怎么解决？

**A**: 
1. 配置 CORS 头
2. 使用代理服务器
3. 后端 API 添加跨域支持

### Q5: 如何启用 PWA 功能？

**A**: 
1. 确保 `manifest.json` 配置正确
2. 使用 HTTPS 部署（或 localhost 测试）
3. Service Worker 会自动注册

## 📊 性能优化建议

1. **代码分割**: 使用 `--split-debug-info` 参数
2. **懒加载**: 对大型资源使用异步加载
3. **图片优化**: 使用合适的图片格式和尺寸
4. **CDN**: 将静态资源部署到 CDN
5. **缓存策略**: 合理配置浏览器和服务器缓存
6. **预加载**: 使用 `<link rel="preload">` 预加载关键资源

## 🔒 安全建议

1. 始终使用 HTTPS 部署
2. 配置 CSP (Content Security Policy) 头
3. 定期更新 Flutter SDK 和依赖包
4. 不要在前端代码中硬编码敏感信息
5. 使用环境变量管理配置

## 📚 相关资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Flutter Web 文档](https://docs.flutter.dev/platform-integration/web)
- [Flutter Web 性能优化](https://docs.flutter.dev/perf/web-performance)
- [Flutter Web 渲染器对比](https://docs.flutter.dev/platform-integration/web/renderers)

## 📝 更新日志

### v1.0.0 (2025-10-16)
- ✨ 初始版本发布
- 🎨 现代化 UI 设计
- 🌓 支持深色模式
- 📱 响应式布局
- 📦 完整的部署文档

## 📄 许可证

本项目仅供学习和参考使用。

## 💬 反馈与支持

如有问题或建议，欢迎提出 Issue 或 Pull Request。

---

**祝你部署顺利！🚀**
