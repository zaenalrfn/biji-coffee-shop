# Biji Coffee Shop Mobile App

A complete mobile application for a coffee shop built with Flutter. This app allows users to browse products, manage their cart, place orders, and track their delivery.

## ✨ Features

- **Authentication**: Secure Login and Registration system.
- **Home & Discovery**: Browse featured beverages, promotions, and categories.
- **Product Details**: View detailed product information and add them to your cart.
- **Cart Management**: Easy-to-use shopping cart to review and manage items.
- **Checkout Process**:
  - Shipping Address selection.
  - Payment Method selection.
  - Coupon application.
- **Order Management**: Review orders and track delivery status.
- **Wishlist**: Save your favorite items for later.
- **Store Locator**: Find the nearest store using an interactive map.
- **Profile Management**: Update user profile and view personal details.
- **Rewards System**: Earn and view rewards.
- **Notifications**: Stay updated with the latest offers and order updates.
- **Chat/Messages**: Support or communication feature.

## 🛠 Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Networking**: http
- **Maps**: flutter_map, latlong2
- **Environment Management**: flutter_dotenv
- **Local Storage**: shared_preferences

## 🚀 Getting Started

Follow these steps to set up the project locally.

### Prerequisites

- Flutter SDK (Recommended version: 3.5.x or higher)
- Dart SDK
- Android Emulator or Physical Device

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/zaenalrfn/biji-coffee-shop.git
    cd biji-coffee-shop
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configuration**
    This project uses `flutter_dotenv` for environment variables.
    
    - Duplicate the `.env.example` file and rename it to `.env`:
      ```bash
      cp .env.example .env
      ```
      *(Or manually create a `.env` file in the root directory)*

    - Open `.env` and configure your API URL:
      ```env
      API_BASE_URL=http://your-ip-address:8000/api
      ```
      > **Note**: 
      > - For Android Emulator, use `ip-address` instead of `localhost`.
      > - For Physical Device, use your machine's local IP address (e.g., `ip-address`).

4.  **Run the App**
    ```bash
    flutter run
    ```
