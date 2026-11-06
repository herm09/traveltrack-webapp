import 'dart:async';

import 'package:flutter/foundation.dart';

/// Transforme un [Stream] en [Listenable] pour que go_router puisse
/// relancer son callback `redirect` à chaque événement (ex: changement
/// de session Supabase), et pas seulement lors d'une navigation.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
      // Un lien expiré émet une erreur sur le flux : AuthViewModel l'affiche.
      onError: (Object _) {},
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
