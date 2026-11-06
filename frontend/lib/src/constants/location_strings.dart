/// Textes affichés autour de la géolocalisation de l'utilisateur sur la carte.
abstract final class LocationStrings {
  static const permissionRequiredMessage =
      'La localisation est nécessaire pour afficher les quêtes autour de vous.';
  static const permissionBlockedHint =
      "Votre navigateur bloque l'accès à votre position. Autorisez-le via "
      "l'icône à gauche de l'adresse du site, puis réessayez.";
  static const locationNotSupportedMessage =
      'Votre navigateur ne permet pas de vous géolocaliser.';
  static const positionUnavailableMessage =
      'Position introuvable pour le moment. Vérifiez votre connexion puis '
      'réessayez.';
  static const enableLocationAction = 'Activer la localisation';
  static const retryAction = 'Réessayer';
  static const closeMessageTooltip = 'Fermer';
  static const recenterButtonLabel = 'Recentrer sur ma position';
}
