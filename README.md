# Product Catalog App

A Flutter mobile application that displays products using the DummyJSON API.

## Features

- Product listing with title, thumbnail and price
- Pagination / load more when scrolling
- Product detail screen
- Product description, price, rating and images
- Product search with debounce
- Loading, error and empty states
- Retry button for failed requests
- Image error handling with placeholder icon
- Pull-to-refresh

## Tech Stack

- Flutter
- Dart
- DummyJSON REST API
- HTTP package

## Architecture

The application uses a simple two-layer structure:

```text
lib/
├── models/
│   └── product.dart
├── services/
│   └── product_service.dart
├── main.dart
└── product_detail_screen.dart