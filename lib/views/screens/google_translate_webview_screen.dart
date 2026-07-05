import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/translate_view_model.dart';

class GoogleTranslateWebViewScreen extends StatefulWidget {
  const GoogleTranslateWebViewScreen({super.key});

  @override
  State<GoogleTranslateWebViewScreen> createState() =>
      _GoogleTranslateWebViewScreenState();
}

class _GoogleTranslateWebViewScreenState
    extends State<GoogleTranslateWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const _translateUrl = 'https://translate.google.com/?hl=en&op=translate';

  static const _themeScript = '''
(function() {
  if (window.__langoThemeApplied) return;
  window.__langoThemeApplied = true;
  const style = document.createElement('style');
  style.textContent = `
    html, body {
      background-color: #FFF8F0 !important;
      font-family: system-ui, -apple-system, sans-serif !important;
    }
    header, footer, .gb_ye, .gb_Ad, .gb_yc, .gb_ka {
      background-color: #FFF8F0 !important;
    }
    textarea, input[type="text"] {
      background-color: #FFFFFF !important;
      border-radius: 16px !important;
      border: 1px solid #E8E0F8 !important;
    }
    .VfPpkd-LgbsSe, button {
      border-radius: 12px !important;
    }
    a { color: #9B8AD4 !important; }
  `;
  document.head.appendChild(style);
})();
''';

  static const _historyScript = '''
(function() {
  if (window.__langoHistoryWatcher) return;
  window.__langoHistoryWatcher = true;
  let lastKey = '';

  function getSourceText() {
    const ta = document.querySelector('textarea');
    return ta ? ta.value.trim() : '';
  }

  function getTranslatedText() {
    const selectors = [
      '[data-language-to-translate-target] span',
      '.Q4iAWc span',
      '.ryNqvb',
      '[data-attrid="translation"] span',
      '.HwtZe span',
      '.jCAhz span',
    ];
    for (const sel of selectors) {
      const nodes = document.querySelectorAll(sel);
      for (const node of nodes) {
        const text = (node.textContent || '').trim();
        if (text && !node.closest('textarea')) return text;
      }
    }
    const blocks = document.querySelectorAll('[lang]:not([lang=""])');
    for (const block of blocks) {
      if (block.tagName === 'TEXTAREA') continue;
      const text = (block.textContent || '').trim();
      if (text.length > 1 && text.length < 5000) return text;
    }
    return '';
  }

  function getLangFromUrl(param, fallback) {
    try {
      return new URLSearchParams(window.location.search).get(param) || fallback;
    } catch (e) {
      return fallback;
    }
  }

  function report() {
    if (typeof LangoBridge === 'undefined') return;
    const source = getSourceText();
    const translated = getTranslatedText();
    if (!source || !translated || source === translated) return;

    const key = source + '|||' + translated;
    if (key === lastKey) return;
    lastKey = key;

    LangoBridge.postMessage(JSON.stringify({
      sourceText: source,
      translatedText: translated,
      sourceLang: getLangFromUrl('sl', 'auto'),
      targetLang: getLangFromUrl('tl', 'en'),
    }));
  }

  setInterval(report, 3000);
  document.addEventListener('input', function() {
    setTimeout(report, 2500);
  }, true);

  const observer = new MutationObserver(function() {
    setTimeout(report, 2000);
  });
  observer.observe(document.body, {
    childList: true,
    subtree: true,
    characterData: true,
  });
})();
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.cream)
      ..addJavaScriptChannel(
        'LangoBridge',
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _injectScripts(),
          onProgress: (progress) {
            if (progress == 100 && mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_translateUrl));
  }

  Future<void> _injectScripts() async {
    await _controller.runJavaScript(_themeScript);
    await _controller.runJavaScript(_historyScript);
    if (mounted) setState(() => _isLoading = false);
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final sourceText = data['sourceText'] as String? ?? '';
      final translatedText = data['translatedText'] as String? ?? '';
      final sourceLang = data['sourceLang'] as String? ?? 'auto';
      final targetLang = data['targetLang'] as String? ?? 'en';

      if (sourceText.isEmpty || translatedText.isEmpty) return;

      context.read<TranslateViewModel>().saveWebTranslation(
            sourceText: sourceText,
            translatedText: translatedText,
            sourceLang: sourceLang,
            targetLang: targetLang,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Online Translation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.lavenderDeep,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.lavenderLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 18,
                  color: AppColors.lavenderDeep,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Powered by Google Translate · Saved to History',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.lavenderDeep,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: WebViewWidget(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
