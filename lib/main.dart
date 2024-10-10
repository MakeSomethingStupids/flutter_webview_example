import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
// 플랫폼별 임포트
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() => runApp(const MaterialApp(home: ThreeJSWebView()));

class ThreeJSWebView extends StatefulWidget {
  const ThreeJSWebView({super.key});

  @override
  State<ThreeJSWebView> createState() => _ThreeJSWebViewState();
}

class _ThreeJSWebViewState extends State<ThreeJSWebView> {
  late final WebViewController _controller;
  String? _htmlContent;

  @override
  void initState() {
    super.initState();
    _loadHtmlFromAssets();

    // 플랫폼별 WebViewController 생성
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // 투명 배경 설정 (필요 시)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView 로딩 중: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('페이지 로딩 시작: $url');
          },
          onPageFinished: (String url) {
            debugPrint('페이지 로딩 완료: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('웹 리소스 에러: $error');
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    _controller = controller;
  }

  // HTML 파일 로드
  Future<void> _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/threejs_sphere.html');
    setState(() {
      _htmlContent = fileText;
      _loadHtmlString(_htmlContent!);
    });
  }

  // HTML 문자열 로드
  void _loadHtmlString(String htmlContent) {
    final String contentBase64 =
    base64Encode(const Utf8Encoder().convert(htmlContent));
    _controller.loadRequest(
      Uri.parse('data:text/html;base64,$contentBase64'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Three.js 회전하는 구체'),
      ),
      body: _htmlContent == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
