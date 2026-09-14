# Product Catalog App

A simple Flutter Product Catalog application built as part of the Junior Mobile Developer technical assessment for Neurogine.

The app uses the DummyJSON Products API to display products, support product search, pagination, and product details.

## Features

* Product listing with thumbnail and price
* Infinite scroll pagination using the `skip` parameter
* Product detail screen
* Product search with debounce
* Loading, error, empty, and success states
* Retry button when an API request fails
* Pull-to-refresh
* Image loading error handling
* Responsive 2-column product grid
* Clean and modern fintech-inspired UI

## Tech Stack

* Flutter
* Dart
* REST API
* DummyJSON Products API

## API Endpoints

### Product List

`GET https://dummyjson.com/products?limit=20&skip=0`

Pagination is handled using the `skip` parameter, with 20 products loaded per request.

### Product Detail

`GET https://dummyjson.com/products/{id}`

### Product Search

`GET https://dummyjson.com/products/search?q={query}`

The app uses the search endpoint instead of filtering the full product list locally.

## Architecture

The project uses a simple two-layer structure separating API/data logic from the UI.

```text
lib/
├── models/
│   └── product.dart
│
├── services/
│   └── product_service.dart
│
├── main.dart
└── product_detail_screen.dart
```

### Data Layer

`product_service.dart` is responsible for communicating with the DummyJSON API.

It handles:

* Fetching products
* Pagination using `skip`
* Searching products
* Retrieving product data

`product.dart` defines the Product model used by the application.

### UI Layer

`main.dart` contains the product listing screen and handles:

* Product display
* Search input
* Debouncing
* Pagination
* Loading/error/empty states
* Pull-to-refresh
* Navigation to the detail screen

`product_detail_screen.dart` displays the selected product's:

* Image
* Title
* Price
* Rating
* Description
* Additional images

I chose this structure to keep API-related logic separate from the UI while keeping the project simple and appropriate for the scope of the assessment.

## Search Approach

The application uses the DummyJSON search endpoint:

`/products/search?q={query}`

Search input is debounced by 500 milliseconds before making the API request. This helps avoid sending an API request for every character typed and provides a smoother search experience.

## Pagination

The product list initially loads 20 products.

When the user scrolls near the bottom of the list, the application requests the next set of products using the `skip` parameter.

Example:

```text
First request:
limit=20&skip=0

Second request:
limit=20&skip=20

Third request:
limit=20&skip=40
```

## States

The application visually handles the following states:

* **Loading** — displays a loading indicator while data is being fetched.
* **Success** — displays the available products.
* **Error** — displays an error message with a Retry button.
* **Empty** — displays a message when no products are found.

## How to Run

### Requirements

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Android emulator, physical Android device, or another supported Flutter platform

### Steps

1. Clone the repository.

```bash
git clone https://github.com/faizatulaziradaud02-arch/product_catalog.git
```

2. Open the project folder.

```bash
cd product_catalog
```

3. Install dependencies.

```bash
flutter pub get
```

4. Run the application.

```bash
flutter run
```

## Testing

The project was checked using:

```bash
flutter analyze
```

Result:

```text
No issues found!
```

The main application flows were also manually tested, including:

* Product loading
* Product search
* Product details
* Pagination
* Pull-to-refresh
* Error handling
* Navigation between screens

## Known Limitations / TODO

The application is intentionally kept small and focused on the assessment requirements.

Possible future improvements include:

* Adding unit tests for the API/data layer
* Adding more advanced product filtering
* Improving offline support and caching
* Adding automated UI testing

These features were not required for the current assessment scope.

## AI Assistance

AI tools were used minimally as a development aid during the project.

AI assistance was mainly used for:

* Understanding Flutter/Dart concepts
* Debugging and resolving development issues
* UI/UX suggestions
* Reviewing and improving code structure

The application was developed, tested, and reviewed by me, and I am able to explain the implementation and architectural decisions presented in this repository.

## Author

Nur Faizatul Azira Daud

Junior Mobile Developer Assessment
Neurogine
