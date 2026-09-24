# StockAI

StockAI is a Flutter mobile prototype that helps photographers review their
photo libraries and prepare promising images for stock photography platforms.
The project explores how local image screening, AI-assisted review, and
editable metadata drafts could reduce repetitive preparation work.

> **Project status:** Personal portfolio prototype in active development. It is
> not a production service and has no public users or commercial results.

## Preview

[Watch the StockAI feature preview on Google Drive](https://drive.google.com/file/d/1ELtqfnkidw0cztCcHjaZrr3HwU5MWTtw/view?usp=sharing)

## Product idea

Preparing photographs for stock platforms can involve reviewing large photo
libraries, checking image suitability, identifying possible licensing issues,
and writing titles, descriptions, and keywords for each submission. StockAI is
a prototype for making that workflow faster while keeping the photographer in
control of the final review and submission.

## Features represented in this prototype

- **Local photo review:** request photo-library access, scan images in batches,
  show scan progress, and display candidate and filtered image counts.
- **First-pass image screening:** score local images by resolution, short-side
  size, and aspect ratio before further review.
- **Manual selection:** choose multiple photos, preview them in a grid, remove
  individual images, and continue to the filter flow.
- **Supabase authentication service layer:** email/password registration,
  sign-in, sign-out, auth-state updates, and consent persistence.
- **Stock-platform connection service layer:** prototype flows for connecting,
  checking, and disconnecting a Shutterstock account through a development
  backend.
- **AI-analysis service boundary:** send a selected image to a configured
  development backend for analysis.
- **Portfolio UI:** a dark mobile interface with a home screen, photo review,
  progress display, and profile entry point.

## Current limitations

- Duplicate-photo detection and screenshot classification are not implemented.
- The Shutterstock connection is a development flow; production API access is
  not available in this project.
- The AI analysis flow depends on a separately configured backend. A full,
  funded, end-to-end AI analysis has not been verified.
- Metadata generation, licensing checks, and commercial/editorial decisions
  are product concepts and service-layer work; do not treat them as completed,
  production-ready capabilities.
- The public repository does not include the backend, production credentials,
  API subscriptions, or release signing configuration.

## Technology

- Flutter and Dart
- Supabase Flutter client for the optional authentication integration
- `photo_manager` and `image_picker` for photo-library and image selection
- HTTP service clients for development backend integrations
- Flutter widget tests and Dart static analysis

## Run the demo

Install Flutter, then run the project from its root directory:

```bash
flutter pub get
flutter run
```

The app starts in local demo mode without Supabase or backend configuration.
Some integration-dependent functions will be unavailable until you configure
your own development services.

### Configure your own development services

Pass values at launch with Dart environment defines:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY \
  --dart-define=BACKEND_BASE_URL=https://YOUR_DEVELOPMENT_BACKEND.example
```

Replace the example values with credentials and endpoints for services you
control. `.env.example` lists the configuration names only; Flutter does not
load that file automatically. For a local backend, provide a device-reachable
address rather than assuming `127.0.0.1` points to the development computer.

### Configuration variables

| Variable | Purpose | Where it is used |
| --- | --- | --- |
| `SUPABASE_URL` | Your Supabase project URL | Flutter client initialization |
| `SUPABASE_PUBLISHABLE_KEY` | Public client key for your Supabase project | Flutter client initialization |
| `BACKEND_BASE_URL` | Base URL for your own development backend | AI and Shutterstock service clients |

## Security and credentials

This repository intentionally contains no real credentials or private service
addresses. Keep these out of source control:

- Supabase secret keys, legacy `service_role` keys, database passwords, and
  other privileged server credentials
- AI provider keys, OAuth client secrets, access tokens, refresh tokens, and
  private signing keys
- `.env` files, signing certificates, keystores, provisioning profiles,
  Firebase service-account files, and local platform configuration
- Private development or production backend URLs

Supabase publishable keys are designed to be used in client applications, but
data access must still be protected with correct Row Level Security policies.
Never put a Supabase secret or `service_role` key into a mobile app. Keep
privileged keys on a trusted server. See the
[Supabase API key guide](https://supabase.com/docs/guides/getting-started/api-keys).

## Repository structure

```text
lib/
  config/       Runtime configuration names and validation
  screens/      Authentication gate and profile screen
  services/     Authentication, photo review, AI, and stock-platform services
  main.dart     App entry point and prototype screens
test/           Widget tests
```

## Development checks

```bash
flutter analyze
flutter test
```

## Contributions and use

This repository is published as a personal portfolio project. Please open an
issue before proposing substantial changes. The project is a prototype, so
integration behavior and product scope may change during development.
