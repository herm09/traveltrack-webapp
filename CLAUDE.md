# CLAUDE.md

This file gives Claude Code the context and rules it needs to work effectively in this repository.

**Claude must read this file in full before making any edit in this repository, every time — not just at the start of a session.**

## Project Overview

**Pitch:** "QuestLog — Donnez un score à votre curiosité." QuestLog transforme l'exploration d'une ville en un jeu réel : l'utilisateur découvre des quêtes culturelles, gastronomiques et historiques géolocalisées, les valide par photo + vérification GPS, et suit sa progression sur la ville.

- **Architecture:** MVVM (Model-View-ViewModel)
- **Platform/Language:** Flutter/Dart
- **State management:** <!-- TODO: confirm — stack section below lists "Zustand", which is a JS library, not a Flutter/Dart option. Likely leftover from the pre-Flutter React Native version; replace with the actual Dart solution in use (e.g. Provider, Riverpod, Bloc). -->

## Périmètre fonctionnel — MVP

Le MVP couvre strictement ce qui est nécessaire à démontrer la proposition de valeur : un utilisateur télécharge l'app, découvre des quêtes autour de lui, en valide, et suit sa progression sur la ville pilote (Paris).

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

### Architecture système
App mobile ↔ BaaS (auth + DB + storage + push) + back-office web minimal pour gérer les quêtes. API externes : Google/Apple Maps.

*(Pour l'architecture applicative du code, voir [Architecture — MVVM](#architecture--mvvm) plus bas.)*

### Outils
Git/GitHub · GitHub Actions (CI) · Figma · Notion/Jira · Discord/Slack

### Exigences non fonctionnelles (MVP)
- **Compatibilité :** iOS 14+, Android 8+ (API 26+), portrait uniquement.
- **Performance :** démarrage < 3s · carte < 2s · validation quête < 5s.
- **Sécurité & RGPD :** consentement explicite, droit à l'oubli, export des données, mots de passe hashés, géoloc non revendue.
- **Accessibilité :** contrastes WCAG AA, tailles de police adaptables, compatibilité VoiceOver/TalkBack sur les écrans principaux.
- **Maintenabilité :** code documenté, linting, tests sur fonctions critiques (validation quête, calcul progression), versionnement sémantique.

## Architecture — MVVM

The codebase follows strict MVVM separation. When creating or modifying features, respect these boundaries:

- **Model** — Plain data classes and business/domain logic. No UI, no framework widget imports.
- **View** — UI only (widgets/screens). Contains no business logic, no direct data access, no async orchestration. Delegates all actions to a ViewModel.
- **ViewModel** — Owns UI state, exposes it to the View (e.g. via streams/notifiers/state objects), and orchestrates calls to repositories/services. No direct references to widget/UI framework types.

Typical folder layout:
```
lib/
  features/
    <feature_name>/
      model/
      view/
      viewmodel/
  core/
    widgets/        # shared reusable widgets
    theme/           # colors, text styles, spacing
    constants/        # shared strings, config values
    services/
```

Before adding a new file, check whether the feature/layer already exists and put the code in the right place rather than creating a parallel structure.

## Conventions de code

- **Nommage des variables :** chaque nom de variable, paramètre, fonction ou classe doit être explicite et refléter clairement son rôle ou son contenu. Pas d'abréviations obscures ni de noms génériques (`data`, `tmp`, `x`, `val`, `res`) sauf portée triviale et évidente (ex. compteur de boucle `i`). Préférer un nom légèrement plus long mais clair à un nom court mais ambigu.

## Always Do

- **Handle loading, error, and success states explicitly in the UI.** Every screen/view that depends on async data must visibly represent all three states — no silent failures, no infinite spinners.
- **Clear error state on user input.** As soon as the user starts correcting a field/action that previously errored, reset the associated error state so stale error messages don't linger.
- **Wrap async methods in proper error handling.** Every `async`/`Future`/`Stream`-based method must catch and handle failures (try/catch, `.catchError`, Result/Either types, etc.) — never let an unhandled exception surface to the user.
- **Check for existing widgets before creating new ones.** Search `core/widgets/` (or the shared component directory) first. Reuse or extend before duplicating.
- **Extract reusable widgets** whenever the same UI pattern appears more than once. Prefer composition over copy-paste.

## Never Do

- **No hardcoded strings.** All user-facing text goes through the localization/strings system.
- **No hardcoded colors.** All colors come from the shared theme (`core/theme/` or equivalent) — never inline hex/RGB values in widgets.
- **No `print()` / `console.log()` statements.** Use the project's logger utility instead. Strip any debug prints before committing.
- **No relative imports** (e.g. `../../models/user.dart`). Use absolute/package imports per project convention.
- **No `TODO` comments in merge requests.** Resolve the work, file a ticket, or leave the code out of the MR — don't merge unfinished intent as a comment.
- **No duplicated logic across files.** If you're about to paste the same block into a second file, extract it into a shared function/widget/service instead.

## Before Opening a PR / MR

- [ ] No `print`/`console.log` left in the diff
- [ ] No `TODO` comments in the diff
- [ ] No hardcoded strings or colors introduced
- [ ] All new async methods have error handling
- [ ] Loading/error/success states covered in any new/changed UI
- [ ] No relative imports introduced
- [ ] Checked `core/widgets/` for existing components before adding new ones
- [ ] No logic duplicated from another file

## Commands

<!-- TODO: fill in with actual project commands so Claude can run them -->
```bash
# Install dependencies

# Run the app

# Run tests

# Lint / format
```

## Notes for Claude

- When editing a View, don't add business logic — push it to the ViewModel.
- When adding a new screen, scaffold Model/View/ViewModel together, matching the existing feature structure.
- When in doubt about where shared UI belongs, put it in `core/widgets/` and give it a descriptive, reusable name (not tied to one feature).
- Flag any existing violations of these rules encountered while working nearby, rather than silently leaving them.
