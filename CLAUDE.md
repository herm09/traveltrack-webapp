## Product: QuestLog

**Pitch:** "QuestLog — Donnez un score à votre curiosité."

Aujourd'hui, on voyage pour l'image, mais on consomme le monde de manière passive. On veut tous cette photo incroyable à la Casbah ou devant le Makam Chahid, mais on passe souvent à côté de l'histoire parce qu'on ne sait pas quoi chercher.

QuestLog, c'est le Strava du voyage. On transforme l'exploration d'un pays en un RPG (Role Playing Game) réel. On ne se contente pas de "visiter" Alger ou Paris, on vient y "compléter" des quêtes culturelles, gastronomiques et historiques.

Chaque photo postée n'est plus juste une story éphémère : c'est une preuve de quête validée par notre IA, qui alimente un score d'immersion global. On rend l'authenticité addictive, et le voyageur devient l'ambassadeur d'un patrimoine qu'il apprend enfin à regarder.

## Objectifs

- **Pédagogiques :** mener un projet logiciel complet en équipe (2 CDP + 3 devs) sur 18 mois (un vendredi par semaine, méthodologie agile inspirée Scrum, sprints de 4 semaines).
- **Produit :** livrer un MVP fonctionnel et démontrable sur une ville pilote (Paris), validé par des tests utilisateurs, avec une architecture évolutive.

## Cibles et personas

Cible principale : 18-35 ans, touristes ou locaux, sensibles à la gamification et au partage social.
- **Léa** (26 ans) : touriste exploratrice, active sur Instagram, frustrée de se sentir "touriste basique".
- **Karim** (31 ans) : local parisien, fan de jeux mobiles, cherche une motivation pour explorer le week-end.

## Périmètre fonctionnel — MVP

Le MVP couvre strictement ce qui est nécessaire à démontrer la proposition de valeur : un utilisateur télécharge l'app, découvre des quêtes autour de lui, en valide, et suit sa progression sur la ville pilote.

| Module | Fonctionnalités | Priorité |
|---|---|---|
| Auth & onboarding | Création compte email/mdp, connexion, reset mdp, onboarding 3-4 écrans, demande des autorisations (géoloc, notifs, caméra) | Must |
| Quêtes (cœur) | Carte avec quêtes géolocalisées, liste par distance, fiche détaillée (titre, photo, description, lieu, type), géoloc temps réel, validation par photo + vérification GPS, notifs push à proximité | Must |
| Progression | Profil (pseudo, photo, stats), mur des quêtes complétées, barre de progression ville en %, badges simples (1 par quartier/thématique) | Must |
| Favoris | Mise en favori d'une quête pour la retrouver plus tard | Should |
| Back-office | Interface admin minimale pour créer/modifier/supprimer les quêtes (équipe), modération photos | Must |
| Légal | CGU, mentions légales, politique de confidentialité accessibles depuis l'app | Must |

**Backlog post-MVP (non priorisé pour l'instant) :** social (amis, FYP, partage), UGC (quêtes créées par les utilisateurs, validation IA des photos), gamification avancée (XP/niveaux, avatar, quêtes duo/groupe, leaderboards), enrichissement (suggestion d'itinéraire IA, traduction, audio-guides, souvenirs), extension à de nouvelles villes et partenariats locaux.

### Hors périmètre
Exclus du projet : réservation de billets/transports/hébergements, paiements in-app, marketplace de guides, version web complète.

## Pourquoi ça va marcher (argumentaire PM)

- **Rétention :** Gamification (barres de progression, badges, niveaux) → addiction saine, envie de finir la ville à 100%.
- **Viralité sociale :** Chaque quête réussie génère un visuel "shareable" optimisé Instagram/TikTok avec le logo de l'app → marketing gratuit.
- **Data-Value :** Base de données unique sur ce que font réellement les gens en voyage, plus précise que TripAdvisor.

## Risques & réponses PM

| Risque | Probabilité | Impact | Mitigation |
|---|---|---|---|
| Périmètre trop ambitieux | Élevée | Élevé | MVP serré, MoSCoW strict, arbitrages en sprint |
| Désengagement d'un membre | Moyenne | Élevé | Doc partagée, code review croisée, pas de SPOF |
| Validation GPS en intérieur | Élevée | Moyen | Rayon large, photo comme preuve, tests terrain |
| Non-conformité RGPD | Moyenne | Élevé | CGU dès le début, consentement explicite, Supabase EU |
| Délais stores | Moyenne | Faible | Anticipation 2 mois, démo via build de test |

- **Business model & écosystème :** partenariats locaux (restaurants/artisans peuvent "sponsoriser" une quête, ex: badge exclusif) et offices de tourisme (paieraient pour orienter les flux touristiques vers des zones moins saturées via des quêtes spécifiques).

## Critères de succès

- **Pédagogiques :** MVP livré à la soutenance, documentation complète, présentation claire des choix techniques.
- **Produit :** app installable iOS et Android, parcours utilisateur complet fonctionnel, ≥ 30 quêtes sur la ville pilote, taux de complétion > 70 % en tests utilisateurs, aucun bug bloquant.
- **Technique :** code versionné Git propre, tests sur fonctions critiques (validation quête, calcul progression), performances conformes (cf. Exigences non fonctionnelles), RGPD démontrable.

## Planning prévisionnel

18 mois, ~60 vendredis effectifs (hors vacances/fériés), sprints agiles de 4 semaines.

| Phase | Période | Livrables |
|---|---|---|
| Cadrage | M1-M2 | CDC validé, choix techniques arrêtés, wireframes, planning détaillé |
| Design | M2-M3 | Charte graphique, maquettes haute-fi, prototype cliquable |
| Dev MVP | M3-M9 | Auth, carte, quêtes, validation, profil, back-office. 30-50 quêtes créées |
| Tests | M9-M10 | Tests internes + utilisateurs (10-15 personnes), corrections critiques |
| Itérations | M10-M15 | Ajout fonctionnalités post-MVP selon retours utilisateurs |
| Finalisation | M16-M18 | Polish UX, doc finale, vidéo démo, soutenance, déploiement stores |

Jalons clés : M2 CDC/maquettes validés · M3 prototype cliquable · M6 première version installable · M9 MVP complet · M10 MVP validé tests utilisateurs · M18 version finale + soutenance.

## Stack technique

### Version Mobile

**Front mobile**
- Flutter
- Flutter_map (carte)
- Zustand (gestion d'état)

**Backend (BaaS)**
- NodeJS
- Supabase — préférable pour le RGPD (hébergement EU)
- Infrastructure: Render

### Version Web

**Front**
- Flutter
- Flutter_map

**Backend**
- NodeJS
- Supabase
- Render (hosting)

### Architecture
App mobile ↔ BaaS (auth + DB + storage + push) + back-office web minimal pour gérer les quêtes. API externes : Google/Apple Maps.

### Outils
Git/GitHub · GitHub Actions (CI) · Figma · Notion/Jira · Discord/Slack

### Exigences non fonctionnelles (MVP)
- **Compatibilité :** iOS 14+, Android 8+ (API 26+), portrait uniquement.
- **Performance :** démarrage < 3s · carte < 2s · validation quête < 5s.
- **Sécurité & RGPD :** consentement explicite, droit à l'oubli, export des données, mots de passe hashés, géoloc non revendue.
- **Accessibilité :** contrastes WCAG AA, tailles de police adaptables, compatibilité VoiceOver/TalkBack sur les écrans principaux.
- **Maintenabilité :** code documenté, linting, tests sur fonctions critiques (validation quête, calcul progression), versionnement sémantique.