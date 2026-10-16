import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KnowledgeBaseView extends StatefulWidget {
  const KnowledgeBaseView({super.key});

  @override
  State<KnowledgeBaseView> createState() => _KnowledgeBaseViewState();
}

class _KnowledgeBaseViewState extends State<KnowledgeBaseView> {
  // onPageFinished waits on the Google Fonts stylesheet, so don't let a slow network hold the spinner
  static const _maxLoadingDuration = Duration(milliseconds: 1500);

  bool _isLoading = true;
  Timer? _loadingTimer;

  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.transparent)
    ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) => _finishLoading()))
    ..loadFlutterAsset('assets/html/asthma_knowledge_base.html');

  @override
  void initState() {
    super.initState();
    _loadingTimer = Timer(_maxLoadingDuration, _finishLoading);
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _finishLoading() {
    _loadingTimer?.cancel();
    if (!mounted || !_isLoading) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: _isLoading ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
