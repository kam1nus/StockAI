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


