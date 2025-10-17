# 📦 GitHub Pages 部署指南

本文档详细说明如何将 Flutter Web 应用部署到 GitHub Pages，以及如何在其他应用中加载。

## 🚀 快速部署步骤

### 第一步：推送代码到 GitHub

```bash
# 1. 初始化 Git 仓库（如果还没有）
git init

# 2. 添加所有文件
git add .

# 3. 提交代码
git commit -m "Initial commit: Flutter Web Demo"

# 4. 创建 GitHub 仓库后，添加远程仓库
git remote add origin https://github.com/你的用户名/flutter_for_web_demo.git

# 5. 推送到 GitHub
git branch -M main
git push -u origin main
```

### 第二步：GitHub 自动部署（已配置）

代码推送后，GitHub Actions 会自动：
1. ✅ 检出代码
2. ✅ 安装 Flutter 环境
3. ✅ 构建 Web 应用
4. ✅ 部署到 `gh-pages` 分支

查看部署状态：
- 访问：`https://github.com/你的用户名/flutter_for_web_demo/actions`
- 等待构建完成（约 2-3 分钟）

### 第三步：启用 GitHub Pages

1. 进入仓库 Settings → Pages
2. Source 选择：`Deploy from a branch`
3. Branch 选择：`gh-pages` / `root`
4. 点击 Save

等待几分钟后，访问：
```
https://你的用户名.github.io/flutter_for_web_demo/
```

## 🌐 访问地址

部署成功后，你的应用将在以下地址可用：
```
https://你的用户名.github.io/flutter_for_web_demo/
```

例如，如果你的 GitHub 用户名是 `zhangsan`：
```
https://zhangsan.github.io/flutter_for_web_demo/
```

## 📱 在应用内加载（WebView）

### 方案 1：使用 WebView 加载（推荐）

#### Android 原生代码

```kotlin
// MainActivity.kt
import android.webkit.WebView
import android.webkit.WebSettings

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val webView = WebView(this)
        webView.settings.apply {
            javaScriptEnabled = true  // 必须启用 JS
            domStorageEnabled = true  // 启用 DOM 存储
            databaseEnabled = true
            setAppCacheEnabled(true)
            loadWithOverviewMode = true
            useWideViewPort = true
        }
        
        // 加载你的 GitHub Pages 地址
        webView.loadUrl("https://你的用户名.github.io/flutter_for_web_demo/")
        
        setContentView(webView)
    }
}
```

#### iOS 原生代码

```swift
// ViewController.swift
import UIKit
import WebKit

class ViewController: UIViewController {
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加载你的 GitHub Pages 地址
        let url = URL(string: "https://你的用户名.github.io/flutter_for_web_demo/")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
```

#### Flutter 应用内加载（使用 webview_flutter）

```yaml
# pubspec.yaml
dependencies:
  webview_flutter: ^4.4.2
```

```dart
// lib/web_page.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 显示加载进度
            print('Loading: $progress%');
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://你的用户名.github.io/flutter_for_web_demo/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Web Demo'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
```

### 方案 2：使用 iframe 嵌入网页

```html
<!DOCTYPE html>
<html>
<head>
    <title>Flutter Web Embedded</title>
    <style>
        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            overflow: hidden;
        }
        iframe {
            width: 100%;
            height: 100%;
            border: none;
        }
    </style>
</head>
<body>
    <iframe src="https://你的用户名.github.io/flutter_for_web_demo/"></iframe>
</body>
</html>
```

### 方案 3：React/Vue 中嵌入

#### React 组件

```jsx
import React from 'react';

function FlutterWebEmbed() {
  return (
    <div style={{ width: '100%', height: '100vh' }}>
      <iframe
        src="https://你的用户名.github.io/flutter_for_web_demo/"
        style={{ width: '100%', height: '100%', border: 'none' }}
        title="Flutter Web Demo"
      />
    </div>
  );
}

export default FlutterWebEmbed;
```

#### Vue 组件

```vue
<template>
  <div class="flutter-web-container">
    <iframe
      src="https://你的用户名.github.io/flutter_for_web_demo/"
      frameborder="0"
      class="flutter-iframe"
    ></iframe>
  </div>
</template>

<style scoped>
.flutter-web-container {
  width: 100%;
  height: 100vh;
}
.flutter-iframe {
  width: 100%;
  height: 100%;
}
</style>
```

## 🔄 更新部署

每次修改代码后：

```bash
# 1. 提交更改
git add .
git commit -m "Update: 描述你的更改"

# 2. 推送到 GitHub
git push origin main

# 3. GitHub Actions 会自动重新部署
# 等待 2-3 分钟后访问网站查看更新
```

## 🛠️ 手动部署（备选方案）

如果不想用 GitHub Actions，可以手动部署：

```bash
# 1. 构建 Web 应用
flutter build web --release --base-href /flutter_for_web_demo/

# 2. 安装 gh-pages 工具（需要 Node.js）
npm install -g gh-pages

# 3. 部署到 gh-pages 分支
gh-pages -d build/web

# 或使用 Git subtree
git subtree push --prefix build/web origin gh-pages
```

## 🎯 自定义域名（可选）

如果你有自己的域名：

1. 在仓库根目录创建 `CNAME` 文件：
```bash
echo "your-domain.com" > CNAME
```

2. 修改 `.github/workflows/deploy.yml`：
```yaml
- name: 部署到 GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./build/web
    cname: your-domain.com  # 改为你的域名
```

3. 在域名 DNS 设置中添加 CNAME 记录：
```
CNAME  www  你的用户名.github.io
```

## 📊 监控和调试

### 查看部署日志
1. 进入 GitHub 仓库
2. 点击 Actions 标签
3. 选择最新的 workflow 运行
4. 查看详细日志

### 常见问题

**Q1: 页面 404 错误？**
- 检查 GitHub Pages 是否已启用
- 确认分支选择正确（gh-pages）
- 等待几分钟让 GitHub 更新

**Q2: 资源加载失败？**
- 检查 `--base-href` 参数是否正确
- 应该是：`--base-href /仓库名/`

**Q3: 构建失败？**
- 查看 Actions 日志
- 检查 Flutter 版本兼容性
- 确认 pubspec.yaml 配置正确

**Q4: 在 WebView 中白屏？**
- 确保启用了 JavaScript
- 确保启用了 DOM Storage
- 检查网络连接

## 🔒 安全注意事项

1. **跨域配置**：如果需要与主应用通信，注意 CORS 配置
2. **HTTPS**：GitHub Pages 自动提供 HTTPS
3. **敏感信息**：不要在前端代码中存储密钥
4. **CSP 配置**：注意 Content Security Policy 设置

## 📈 性能优化

### 启用 CDN 加速（可选）

使用 Cloudflare、jsDelivr 等 CDN：

```html
<!-- 通过 CDN 加载 -->
<script src="https://cdn.jsdelivr.net/gh/你的用户名/flutter_for_web_demo@gh-pages/main.dart.js"></script>
```

### 预加载资源

在主应用中预加载 Flutter Web：

```html
<link rel="preload" href="https://你的用户名.github.io/flutter_for_web_demo/main.dart.js" as="script">
```

## 💡 最佳实践

1. **版本控制**：使用 Git tags 管理版本
2. **分支策略**：main 分支自动部署，develop 分支用于开发
3. **测试环境**：可以部署多个分支到不同路径
4. **缓存策略**：合理配置资源缓存时间
5. **监控**：接入分析工具（如 Google Analytics）

## 📞 获取帮助

- [Flutter Web 文档](https://docs.flutter.dev/platform-integration/web)
- [GitHub Pages 文档](https://docs.github.com/pages)
- [GitHub Actions 文档](https://docs.github.com/actions)

---

**祝部署顺利！🎉**

