# Loop Expense Tracker

Loop Expense Tracker is a Flutter mobile app for tracking daily income and expenses. It includes Firebase authentication, local SQLite storage, category-based transaction management, analytics charts, filters, and multi-currency support.

## Overview

This project helps users:

- Create an account and log in securely
- Add credit and debit transactions
- Organize expenses by category
- Filter transactions by date, category, and amount
- View balance summaries
- Analyze spending with charts
- Store preferred currency locally

## Features

- Firebase email/password authentication
- Splash screen with auto-login check
- Sign up, login, and forgot password flow
- Add, edit, and delete transactions
- Credit and debit support
- Category picker for transactions
- Multi-currency selection
- Expense filtering by:
  - Date range
  - Category
  - Minimum and maximum amount
- Transaction history screen
- Pie chart analytics using `fl_chart`
- Expense chart with category breakdown
- Settings page with FAQ, support, and logout

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
  main.dart
  splash_screen.dart
  login_page.dart
  signup_page.dart
  forgot_password_page.dart
  home_page.dart
  add_expense_page.dart
  view_all_expenses_page.dart
  filter_expense_page.dart
  expense_chart.dart
  settings_page.dart
  expense_database.dart
  expense_model.dart
  expense_category.dart
  category_picker_page.dart
  CurrencySelectorPage.dart
  SelectCategoriesPage.dart
```

## Screenshots

Add your app screenshots inside `docs/screenshots/` with the exact filenames below:

- `splash-screen.png`
- `login-screen.png`
- `signup-screen.png`
- `home-screen.png`
- `add-expense-screen.png`
- `all-expenses-screen.png`
- `filter-screen.png`
- `chart-screen.png`
- `settings-screen.png`

After you add them, this section will show correctly on GitHub:

| Splash | Login | Signup |
|---|---|---|
| !Splash Screen | !Login Screen | !Signup Screen |

| Home | Add Expense | All Expenses |
|---|---|---|
| !Home Screen | !Add Expense Screen | !All Expenses Screen |

| Filter | Chart | Settings |
|---|---|---|
| !Filter Screen | !Chart Screen | !Settings Screen |

## Prerequisites

Before running this project, make sure you have:

- Flutter SDK installed
- Android Studio or VS Code
- Flutter and Dart extensions
- A running Android emulator or physical device
- A Firebase project

## Installation

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd loop
```

### 2. Install dependencies

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
