import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/permission_service.dart';

class PermissionOnboardingScreen extends StatefulWidget {
  const PermissionOnboardingScreen({super.key});

  @override
  State<PermissionOnboardingScreen> createState() =>
      _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState
    extends State<PermissionOnboardingScreen> {
  bool _loading = true;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _skipIfAlreadyGranted();
  }

  Future<void> _skipIfAlreadyGranted() async {
    final location =
        await PermissionService.instance.checkLocationPermission();
    final camera = await PermissionService.instance.checkCameraPermission();
    final notifications =
        await PermissionService.instance.checkNotificationPermission();

    if (!mounted) return;

    final allGranted = location == AppPermissionStatus.granted &&
        camera == AppPermissionStatus.granted &&
        notifications == AppPermissionStatus.granted;

    if (allGranted) {
      context.go('/home');
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _requestAll() async {
    setState(() => _requesting = true);
    await PermissionService.instance.requestLocationPermission();
    await PermissionService.instance.requestCameraPermission();
    await PermissionService.instance.requestNotificationPermission();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: SizedBox.shrink());

    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'TravelTrack',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pour vivre pleinement vos quêtes,\nnous avons besoin de quelques accès.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              _PermissionItem(
                icon: Icons.location_on_outlined,
                title: 'Localisation',
                description:
                    'Pour valider vos quêtes et afficher les lieux autour de vous.',
              ),
              const SizedBox(height: 16),
              _PermissionItem(
                icon: Icons.camera_alt_outlined,
                title: 'Caméra',
                description:
                    'Pour prendre des photos comme preuve lors de vos quêtes.',
              ),
              const SizedBox(height: 16),
              _PermissionItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                description:
                    'Pour vous alerter des nouvelles quêtes disponibles près de vous.',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _requesting ? null : _requestAll,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _requesting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
