# Tribe Green — Project Handover

## 1. Project Overview

Tribe Green is a corporate gifting platform that helps businesses discover products, explore gifting options and submit bulk enquiries.

The project consists of three applications:

- **Customer Android App:** Browse products, filter by category, occasion and budget, view product details, submit enquiries and access locally saved enquiry history.
- **Customer Website:** Provides the same product catalogue and enquiry experience through a responsive web interface.
- **Admin Dashboard:** Allows administrators to manage products, review customer enquiries, update enquiry statuses, view statistics and export enquiry data as CSV.

## 2. Technology Stack

| Technology        | Purpose                                                  |
| ----------------- | -------------------------------------------------------- |
| Flutter & Dart    | Android application and responsive web interfaces        |
| GetX              | State management, dependency injection and navigation    |
| Supabase          | Authentication, PostgreSQL database and backend services |
| Hive              | Local storage for customer enquiry history               |
| SharedPreferences | Local application preferences                            |
| Firebase          | Push notification integration, where configured          |

**Why this stack?**

Flutter allows Android and web interfaces to share reusable components. GetX simplifies state management and navigation. Supabase provides authentication and database functionality without requiring a separate backend server. Hive provides local storage for enquiry history.

## 3. How to Run

Prerequisites: Flutter SDK, Dart SDK, Chrome and a configured Supabase project.

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

Configure the Supabase URL and publishable/anon key using the project's environment configuration before running the applications.

Never commit environment files containing real credentials or Supabase service-role keys.

## 4. Git and Deployment

- Source code is maintained using Git and GitHub.
- Flutter Web is built using `flutter build web --release`.
- The generated `build/web` directory is deployed using GitHub Pages and GitHub Actions.
- GitHub Pages requires the correct repository base path (`/gifting/`).
- Supabase authentication redirect URLs and database RLS policies must be configured for production.

## 5. Incomplete Work and Known Limitations

- Enquiry pagination should be moved to Supabase server-side queries for better performance with larger datasets.
- Email and push notification delivery require production configuration and testing.
- Supabase schema, RLS policies and deployment secrets must be maintained securely.

## 6. Improvements with More Time

- Improve application performance and loading states.
- Add automated tests for authentication, catalogue filters and enquiry workflows.
- Improve enquiry search, pagination and reporting.
- Add monitoring, error tracking and automated deployment checks.

## 7. Development Time

**Total development time: 18 hours.**

This is the estimate recorded for the admin dashboard; it is not a separately verified time-tracking report.
