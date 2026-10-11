import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KnowledgeBaseView extends StatefulWidget {
  const KnowledgeBaseView({super.key});

  @override
  State<KnowledgeBaseView> createState() => _KnowledgeBaseViewState();
}

class _KnowledgeBaseViewState extends State<KnowledgeBaseView> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.transparent)
    ..loadFlutterAsset('assets/html/asthma_knowledge_base.html');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: WebViewWidget(controller: _controller),
    );
  }
}
