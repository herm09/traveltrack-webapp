import 'dart:async';

import 'package:flutter/foundation.dart';

/// Transforme un [Stream] en [Listenable] pour que go_router puisse
/// relancer son callback `redirect` à chaque événement (ex: changement
/// de session Supabase), et pas seulement lors d'une navigation.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
