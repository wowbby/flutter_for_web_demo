# 🚀 快速开始指南

## 📦 部署到 GitHub Pages（3 步完成）

### 第 1 步：在 GitHub 创建仓库

1. 访问 https://github.com/new
2. 仓库名：`flutter_for_web_demo`
3. 选择 Public
4. 不要初始化 README（因为本地已有）
5. 点击 Create repository

### 第 2 步：运行部署脚本

```bash
./deploy_github.sh
```

脚本会自动：
- ✅ 初始化 Git（如果需要）
- ✅ 添加远程仓库
- ✅ 提交并推送代码
- ✅ 触发 GitHub Actions 自动部署

### 第 3 步：启用 GitHub Pages

1. 访问：`https://github.com/你的用户名/flutter_for_web_demo/settings/pages`
2. Source 选择：`Deploy from a branch`
3. Branch 选择：`gh-pages` / `root`
4. 点击 **Save**

**等待 2-3 分钟后访问：**
```
https://你的用户名.github.io/flutter_for_web_demo/
```

---

## 📱 在应用内加载（Flutter）

### 安装依赖

在你的主应用 `pubspec.yaml` 添加：

```yaml
dependencies:
  webview_flutter: ^4.4.2
```

运行：
```bash
flutter pub get
```

### 使用代码

```dart
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
      ..loadRequest(
        Uri.parse('https://你的用户名.github.io/flutter_for_web_demo/')
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Web Demo')),
      body: WebViewWidget(controller: controller),
    );
  }
}
```

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 添加网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS 配置

在 `ios/Runner/Info.plist` 添加：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

---

## 🔄 更新部署

每次修改代码后：

```bash
git add .
git commit -m "你的更新说明"
git push origin main
```

GitHub Actions 会自动重新部署！

---

## 📚 更多示例

查看 `examples/` 目录：
- `webview_example.dart` - 完整的 WebView 加载示例
- `pubspec_example.yaml` - 依赖配置示例

查看完整文档：
- `DEPLOY_GITHUB.md` - 详细部署指南
- `README.md` - 完整项目文档

---

## 💡 常见问题

### Q: 页面显示 404？
**A**: 等待 2-3 分钟让 GitHub Pages 生效，然后刷新页面。

### Q: WebView 显示白屏？
**A**: 确保启用了 JavaScript：
```dart
controller.setJavaScriptMode(JavaScriptMode.unrestricted)
```

### Q: 如何修改仓库名？
**A**: 
1. 修改 `.github/workflows/deploy.yml` 中的 `--base-href`
2. 在 GitHub 仓库 Settings 中修改仓库名

### Q: 如何使用自定义域名？
**A**: 查看 `DEPLOY_GITHUB.md` 中的"自定义域名"章节

---

## 🎯 项目结构

```
flutter_for_web_demo/
├── lib/main.dart              # Flutter 应用代码
├── web/index.html             # Web 入口（手写）
├── build/web/                 # 构建产物（自动生成）
├── .github/workflows/         # GitHub Actions 配置
│   └── deploy.yml
├── examples/                  # 示例代码
│   ├── webview_example.dart
│   └── pubspec_example.yaml
├── deploy_github.sh           # 快速部署脚本
├── DEPLOY_GITHUB.md           # 详细部署文档
└── README.md                  # 项目文档
```

---

**祝你使用愉快！🎉**

遇到问题？查看 `DEPLOY_GITHUB.md` 获取更多帮助。

