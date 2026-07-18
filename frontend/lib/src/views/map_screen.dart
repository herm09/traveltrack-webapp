import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/quest.dart';
import '../services/quest_service.dart';

const _leafletHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script>
    // Defined before the Leaflet CDN scripts below so it's ready the moment
    // the document is parsed, regardless of how long unpkg.com takes to
    // respond. Any marker requested before the map exists gets queued and
    // flushed once it's ready, instead of racing a guessed timeout.
    window._questQueue = [];
    window._mapReady = false;
    window.queueOrAddMarker = function(lat, lng, title) {
      if (window._mapReady) {
        L.marker([lat, lng]).addTo(window.map).bindPopup(title);
      } else {
        window._questQueue.push([lat, lng, title]);
      }
    };
  </script>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>html, body, #map { height: 100%; margin: 0; padding: 0; }</style>
</head>
<body>
  <div id="map"></div>
  <script>
    // Leaflet normally infers its own icon image paths from the <script>
    // tag it was loaded from. That detection doesn't work inside a srcdoc
    // iframe (no real document URL), so markers get added with a broken
    // icon and end up invisible. Point it at the CDN explicitly instead.
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
      iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
      shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png'
    });

    window.map = L.map('map').setView([48.8566, 2.3522], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(window.map);

    window._mapReady = true;
    window._questQueue.forEach(function(m) {
      window.queueOrAddMarker(m[0], m[1], m[2]);
    });
    window._questQueue = [];
  </script>
</body>
</html>
''';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final WebViewController _controller;
  List<Quest> _quests = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    // webview_flutter_web doesn't implement setJavaScriptMode (JS always
    // runs in the underlying iframe) or NavigationDelegate at all — see
    // https://github.com/flutter/flutter/issues/107877, open since 2022.
    // Both calls throw UnimplementedError on web, so they're native-only.
    // Not needed for correctness anymore anyway: marker injection is safe
    // regardless of page-load timing thanks to the JS-side queue above.
    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(onPageFinished: (_) => _addQuestMarkers()),
        );
    }

    _controller.loadHtmlString(_leafletHtml);
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    try {
      final quests = await QuestService.fetchQuests();
      setState(() => _quests = quests);
      _addQuestMarkers();
    } catch (e) {
      setState(() => _error = 'Impossible de charger les quêtes: $e');
    }
  }

  // Escape a string so it can be safely embedded in a single-quoted JS string.
  String _escapeJs(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll("'", "\\'")
      .replaceAll('\n', ' ');

  Future<void> _addQuestMarkers() async {
    for (final quest in _quests) {
      final title = _escapeJs(quest.title);
      await _controller.runJavaScript(
        "window.queueOrAddMarker(${quest.lat}, ${quest.lng}, '$title');",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_error != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
