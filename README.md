# Loop Expense Tracker

Loop is a Flutter expense tracker app with Firebase authentication, local expense storage, category-based analysis, and multi-currency support. Users can sign up, log in, add income or expense entries, filter transactions, and review spending patterns through charts.

## Features

- Firebase email/password authentication
- Splash screen with automatic login check
- Add, edit, and delete transactions
- Credit and debit transaction support
- Category picker with grouped expense categories
- Date, amount, and category-based filtering
- Expense summary cards for credit, debit, and balance
- Pie chart analytics using `fl_chart`
- Currency selection saved with `SharedPreferences`
- Local transaction storage with SQLite (`sqflite`)
- Profile/settings screen with logout, FAQ, and support options

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- SQLite via `sqflite`
- `SharedPreferences`
- `fl_chart`
- `google_fonts`

## Project Structure

```text
lib/
  main.dart                   App entry point and route setup
  splash_screen.dart          Startup screen and auth redirect
  login_page.dart             Login UI and Firebase sign-in
  signup_page.dart            Registration UI and Firestore user creation
  forgot_password_page.dart   Password reset flow
  home_page.dart              Dashboard, summary cards, recent transactions
  add_expense_page.dart       Add/edit expense form
  view_all_expenses_page.dart Full transaction list with edit/delete
  filter_expense_page.dart    Date/category/amount filters
  expense_chart.dart          Pie chart analytics
  settings_page.dart          Settings, FAQ, support, logout
  expense_database.dart       SQLite database helper
  expense_model.dart          Expense data model
  expense_category.dart       Expense category definitions
```

## How It Works

- User accounts are handled with Firebase Authentication.
- User profile details such as username are stored in Cloud Firestore.
- Expense records are stored locally in SQLite and linked to the logged-in user's `uid`.
- The selected currency is stored locally with `SharedPreferences`.
- Charts are generated from the locally stored expense data.

## Prerequisites

Make sure you have:

- Flutter SDK installed
- Dart SDK compatible with Flutter
- Android Studio or VS Code with Flutter extensions
- An emulator or physical device
- A Firebase project for authentication and Firestore

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Firebase setup:

- Android Firebase config is already present in `android/app/google-services.json`.
- This app initializes Firebase with `Firebase.initializeApp()`, so the native Firebase platform setup must be valid for each platform you run.
- If you want to run on iOS, add the missing `GoogleService-Info.plist` to `ios/Runner/`.

3. Run the app:

```bash
flutter run
```

## Main Screens

- `SplashScreen`: checks whether the user is already signed in
- `LoginPage`: email/password login
- `SignupPage`: account creation with username
- `HomePage`: recent transactions, balance summary, and navigation drawer
- `AddExpensePage`: create or update a transaction
- `ViewAllExpensesPage`: browse all transactions and delete entries
- `ExpenseChart`: category breakdown and totals
- `FilterExpensePage`: refine results by date, category, and amount
- `SettingsPage`: FAQ, support, statistics, and logout

## Data Notes

- Expenses include `title`, `amount`, `category`, `date`, `isCredit`, `userId`, and `currency`.
- The local database file is `expenses.db`.
- Transactions are ordered by date in descending order.

## Assets

The project currently includes image assets in `assets/` that are used for branding and launcher icons.

## Useful Commands

```bash
flutter pub get
flutter analyze
flutter run
flutter build apk
```

## Current Repository Notes

- The app description in `pubspec.yaml` is still the default Flutter placeholder and can be updated later.
- Android Firebase is configured in the repo, while iOS Firebase setup appears incomplete.

## License

This project does not currently include a license file.
# Expense_Tracker
