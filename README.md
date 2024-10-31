# Food Saver Application

A Flutter-based mobile application designed to connect local businesses with customers seeking affordable meals, reducing food waste and promoting sustainable choices. The app offers a streamlined experience for both consumers and sellers, allowing easy management of unsold items and accessible deals.

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Installation](#installation)
4. [Project Structure](#project-structure)
5. [Usage](#usage)
6. [Contributing](#contributing)
7. [License](#license)

---

### Overview

**Food Saver** bridges the gap between local businesses and consumers by providing a marketplace for discounted food items nearing expiration. With dedicated features for both users and sellers, it encourages budget-friendly and eco-friendly purchases while supporting local businesses.

### Features

- **User Features**:
  - Browse available food deals by location, type, and category.
  - User profile management and order history tracking.
  - Personalized onboarding and login options.

- **Seller Features**:
  - Store registration and profile setup.
  - Manage product listings with details like original price, discounted price, and expiration dates.
  - Order management with a dedicated seller dashboard.

- **General Features**:
  - In-app notifications for new deals and updates.
  - Secure login, signup, and password recovery functionality.
  - Seamless navigation with an intuitive interface.

### Installation

#### Prerequisites
- **Flutter SDK**: Ensure Flutter is installed on your system. [Flutter installation guide](https://flutter.dev/docs/get-started/install)

#### Clone the Repository
```bash
git clone https://github.com/Rany29-coder/my-food-application.git
cd my-food-application
```

#### Install Dependencies
```bash
flutter pub get
```

#### Run the Application
To launch the app on an emulator or physical device:
```bash
flutter run
```

### Project Structure

    ├── lib/
    │   ├── main.dart                        # Application entry point
    │   ├── widget/
    │   │   ├── content_model.dart           # Data models and content structures
    │   │   └── widget_support.dart          # Reusable UI components and helper widgets
    │   ├── pages/
    │   │   ├── login.dart                   # Login screen for users
    │   │   ├── signup.dart                  # Signup screen for new users
    │   │   ├── forgot_password.dart         # Password recovery screen
    │   │   ├── profile.dart                 # User profile management
    │   │   ├── products.dart                # Product listings for users to browse
    │   │   ├── dashboard_page.dart          # Dashboard for user interactions
    │   │   ├── onboard.dart                 # Onboarding screen for first-time users
    │   │   ├── post_product.dart            # Product posting page for sellers
    │   │   └── seller/                      # Dedicated seller module
    │   │       ├── seller_signup.dart       # Signup for seller accounts
    │   │       ├── profile_page.dart        # Seller profile management
    │   │       ├── SellerBottomNav.dart     # Bottom navigation bar for seller module
    │   │       └── dashboard/
    │   │           ├── store_initial_setup.dart # Initial store setup for sellers
    │   │           ├── store_dashboard.dart # Dashboard page for seller interactions
    │   │           └── order_model.dart     # Model and functionality for order management
    ├── pubspec.yaml                         # Dependency and configuration file

### Usage

1. **Register** as a user or seller.
2. **Explore Deals**: Users can browse food deals and make purchases.
3. **Post Products**: Sellers can list unsold products with expiration details and discounts.
4. **Manage Orders**: Sellers can track and manage orders through their dashboard.



1. **Fork** the repository.
2. **Create a new branch** (`git checkout -b feature/your-feature`).
3. **Commit your changes** (`git commit -m 'Add feature'`).
4. **Push to the branch** (`git push origin feature/your-feature`).
5. **Create a Pull Request** for review.

### License

This project is licensed under the MIT License. See `LICENSE` for more details.

---
