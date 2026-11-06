import 'dart:js_interop';

@JS('startPosthog')
external void _startPosthog();

/// Télécharge et initialise le SDK défini dans `web/index.html`.
void loadAnalyticsSdk() => _startPosthog();
