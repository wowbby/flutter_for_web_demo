// Flutter 应用内加载 GitHub Pages 上的 Flutter Web 应用示例
// 
// 使用前需要在 pubspec.yaml 中添加依赖：
// dependencies:
//   webview_flutter: ^4.4.2

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Loader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      // 启用 JavaScript（Flutter Web 必需）
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      
      // 启用后台运行
      ..setBackgroundColor(Colors.white)
      
      // 设置导航代理
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            print('🔵 页面开始加载: $url');
            setState(() {
              loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            print('✅ 页面加载完成: $url');
            setState(() {
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ 加载错误: ${error.description}');
          },
        ),
      )
      
      // 加载你的 GitHub Pages 地址
      // 替换为你的实际地址：https://你的用户名.github.io/flutter_for_web_demo/
      ..loadRequest(Uri.parse('https://你的用户名.github.io/flutter_for_web_demo/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Web Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          
          // 显示加载进度条
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}

// ============================================
// 高级示例：带导航控制的 WebView
// ============================================

class AdvancedWebViewPage extends StatefulWidget {
  const AdvancedWebViewPage({super.key});

  @override
  State<AdvancedWebViewPage> createState() => _AdvancedWebViewPageState();
}

class _AdvancedWebViewPageState extends State<AdvancedWebViewPage> {
  late final WebViewController controller;
  int loadingPercentage = 0;
  bool canGoBack = false;
  bool canGoForward = false;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              loadingPercentage = 0;
              currentUrl = url;
            });
            _updateNavigationState();
          },
          onPageFinished: (String url) {
            setState(() {
              loadingPercentage = 100;
              currentUrl = url;
            });
            _updateNavigationState();
          },
          onNavigationRequest: (NavigationRequest request) {
            // 可以在这里控制哪些 URL 可以导航
            print('导航请求: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://你的用户名.github.io/flutter_for_web_demo/'));
  }

  Future<void> _updateNavigationState() async {
    final back = await controller.canGoBack();
    final forward = await controller.canGoForward();
    setState(() {
      canGoBack = back;
      canGoForward = forward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Flutter Web Demo'),
            if (currentUrl.isNotEmpty)
              Text(
                Uri.parse(currentUrl).host,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: canGoBack
                ? () async {
                    await controller.goBack();
                    _updateNavigationState();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: canGoForward
                ? () async {
                    await controller.goForward();
                    _updateNavigationState();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          
          if (loadingPercentage < 100)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: loadingPercentage / 100.0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================
// 与 Flutter Web 通信示例（JavaScript Bridge）
// ============================================

class WebViewWithCommunication extends StatefulWidget {
  const WebViewWithCommunication({super.key});

  @override
  State<WebViewWithCommunication> createState() => _WebViewWithCommunicationState();
}

class _WebViewWithCommunicationState extends State<WebViewWithCommunication> {
  late final WebViewController controller;
  String messageFromWeb = '';

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      
      // 添加 JavaScript 通道
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            messageFromWeb = message.message;
          });
          print('收到来自 Web 的消息: ${message.message}');
        },
      )
      
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // 页面加载完成后，注入 JavaScript 代码
            controller.runJavaScript('''
              // 在 Web 页面中可以通过这个方法发送消息到 Flutter
              window.sendToFlutter = function(message) {
                FlutterChannel.postMessage(message);
              };
              
              console.log('Flutter JavaScript Bridge 已就绪');
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://你的用户名.github.io/flutter_for_web_demo/'));
  }

  // 从 Flutter 发送消息到 Web
  void sendMessageToWeb(String message) {
    controller.runJavaScript('''
      console.log('收到来自 Flutter 的消息: $message');
      // 可以在这里调用 Web 页面的函数
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ↔ Web 通信'),
      ),
      body: Column(
        children: [
          // 显示来自 Web 的消息
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.message),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    messageFromWeb.isEmpty 
                        ? '等待 Web 消息...' 
                        : '来自 Web: $messageFromWeb',
                  ),
                ),
              ],
            ),
          ),
          
          // WebView
          Expanded(
            child: WebViewWidget(controller: controller),
          ),
          
          // 发送消息到 Web
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                sendMessageToWeb('Hello from Flutter!');
              },
              child: const Text('发送消息到 Web'),
            ),
          ),
        ],
      ),
    );
  }
}

