# Tribe Green — Project Handover

## 1. Project Overview

Tribe Green is a corporate gifting platform that helps businesses discover products, explore gifting options and submit bulk enquiries.

The project consists of three applications:

- **Customer Android App:** Browse products, filter by category, occasion and budget, view product details, submit enquiries and access locally saved enquiry history.
- **Customer Website:** Provides the same product catalogue and enquiry experience through a responsive web interface.
- **Admin Dashboard:** Allows administrators to manage products, review customer enquiries, update enquiry statuses, view statistics and export enquiry data as CSV.

## 2. Technology Stack

| Technology        | Purpose                                                      |
| ----------------- | ------------------------------------------------------------ |
| Flutter & Dart    | Android application and responsive web interfaces            |
| GetX              | State management, dependency injection and navigation        |
| Firebase          | Authentication, Cloud Firestore database and Cloud Messaging |
| Hive              | Local storage for customer enquiry history                   |
| SharedPreferences | Local application preferences                                |

**Why this stack?**

Flutter allows Android and web interfaces to share reusable components. GetX simplifies state management and navigation. Firebase provides authentication, Cloud Firestore database functionality, and push notifications without requiring a separate backend server. Hive provides local storage for enquiry history.

## 3. How to Run

Prerequisites: Flutter SDK, Dart SDK, Chrome and a configured Firebase project.

```bash
# Install dependencies
flutter pub get

# Run the customer application
flutter run

# Run the web application
flutter run -d chrome

# Run tests
flutter test

# Build Android
flutter build apk --release

# Build Web
flutter build web --release
```

Firebase is initialized using FlutterFire configuration in `lib/firebase_options.dart`.

Never commit environment files containing sensitive credentials.

## 4. Git and Deployment

- Source code is maintained using Git and GitHub.
- Flutter Web is built using `flutter build web --release`.
- The generated `build/web` directory is deployed using GitHub Pages and GitHub Actions.
- GitHub Pages requires the correct repository base path (`/gifting/`).
- Firestore security rules should be configured according to your production requirements.

## 5. Incomplete Work and Known Limitations

- Enquiry pagination should be moved to Firestore cursors/server-side queries for better performance with larger datasets.
- Email and push notification delivery require production configuration and testing.
- Firestore security rules and deployment secrets must be maintained securely.

## 6. Improvements with More Time

- Improve application performance and loading states.
- Add automated tests for authentication, catalogue filters and enquiry workflows.
- Improve enquiry search, pagination and reporting.
- Add monitoring, error tracking and automated deployment checks.

## 7. Development Time

**Total development time: 18 hours.**

This is the estimate recorded for the admin dashboard; it is not a separately verified time-tracking report.
