import 'dart:html' as html;

bool isMobileBrowser() {
  try {
    final ua = html.window.navigator.userAgent.toLowerCase();
    return ua.contains('mobi') ||
        ua.contains('android') ||
        ua.contains('iphone');
  } catch (_) {
    return false;
  }
}

void triggerDownload(String url, {String? filename}) {
  try {
    final anchor = html.AnchorElement(href: url);
    if (filename != null && filename.isNotEmpty) {
      anchor.download = filename;
    }
    anchor.target = '_blank';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  } catch (e) {}
}
