import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const TravelTrackApp());
}

class TravelTrackApp extends StatelessWidget {
  const TravelTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TravelTrack',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      routerConfig: appRouter,
      builder: (context, child) {
        // Force un rendu "mobile" même sur web/desktop :
        // on centre le contenu dans un cadre de largeur max type smartphone.
        return Container(
          color: const Color(0xFFEFEFEF), // fond gris autour du "téléphone"
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 430, // largeur type iPhone Pro Max
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: MediaQuery(
                // On garde la MediaQuery du parent (nécessaire pour go_router / Navigator)
                // mais on peut clipper l'affichage.
                data: MediaQuery.of(context),
                child: ClipRect(child: child!),
              ),
            ),
          ),
        );
      },
    );
  }
}
