# Fuodz Vendor Application

Welcome to the **Fuodz Vendor** application, the merchant-facing mobile portal of the Fuodz on-demand multi-service delivery, booking, and e-commerce ecosystem.

This application is built with **Flutter** and empowers shop owners, local merchants, service providers, parcel operators, and property managers to manage their entire business operations on the go.

---

## 💡 The Core Concept

The **Fuodz Vendor** application bridges the gap between digital orders and physical fulfillment. In the Fuodz marketplace ecosystem:
1. **Customers** place orders, request services, book properties, or schedule package deliveries via the customer app.
2. **Vendors** receive these requests in real-time, accept/decline them, prepare products, set schedules, or manage booking availability.
3. **Drivers** pick up ready orders and deliver them to customers.

By providing a specialized mobile hub for merchants, Fuodz ensures high efficiency, real-time synchronization, and seamless business-to-customer communication.

---

## 🏬 Supported Vendor Models

The application dynamically adapts its user interface and features based on the vendor type:

*   **🛒 Product Merchants (E-Commerce / Restaurants / Groceries / Pharmacies)**
    *   Manage product catalog (add, update, delete products).
    *   Organize items into categories and menus.
    *   Track inventory, update stock levels, and set options/sizes.
    *   Process orders through various stages (Received, Preparing, Ready, Dispatched).
*   **🛠️ Service Providers (Home Services / Wellness / Repair)**
    *   List services (e.g., cleaning, plumbing, beauty) with pricing and duration.
    *   Manage scheduling and bookings.
    *   Set service availability hours.
*   **📦 Parcel & Delivery Operators (Courier Services)**
    *   Configure custom pricing tiers for package types (e.g., small envelope, box, fragile item).
    *   Manage delivery base rates and per-kilometer charges.
*   **🏨 Property & Venue Bookings (Real Estate / Accommodation)**
    *   List properties, rooms, or venues.
    *   Set custom pricing, booking deposits, and availability calendars.
    *   Approve, reject, or update reservation booking states.

---

## ✨ Key Features

*   **⚡ Real-Time Notifications & WebSockets:** Real-time order alerting using Firebase Cloud Messaging (FCM) and WebSocket channels (via Laravel Echo) to ensure immediate order processing.
*   **🖨️ ESC/POS Thermal Printing:** Built-in integration with Bluetooth thermal receipt printers to automatically or manually print customer receipts and preparation tickets.
*   **📈 Sales & Financial Reports:** View detailed financial breakdowns, generate vendor sales/earnings reports, and request payouts.
*   **💬 In-App Chat:** Multi-user chat support to communicate directly with customers and assigned drivers.
*   **🔄 Multi-Vendor Switcher:** Seamlessly switch between different outlets or storefronts for business owners managing multiple locations.
*   **🌍 Multi-Language & RTL:** Localization support including full Arabic RTL configuration.
*   **⚙️ Shop Operations:** Toggle shop status (open/closed), set operating hours, verify documents, and update profile settings.

---

## 🛠️ Architecture & Tech Stack

This project is built using professional software development standards:

*   **Framework:** [Flutter](https://flutter.dev) (iOS & Android cross-platform development)
*   **State Management:** **MVVM (Model-View-ViewModel)** pattern powered by the [Stacked](https://pub.dev/packages/stacked) framework.
    *   **Views:** UI elements containing only layout and styling.
    *   **ViewModels:** Handles presentation logic and reactive state management.
    *   **Models:** Strict schema representations for API data (e.g., `Vendor`, `Product`, `Order`).
*   **Networking:** [Dio](https://pub.dev/packages/dio) HTTP client with custom interceptors for Bearer Token authorization and request/response logging.
*   **Local Storage:** `shared_preferences` for session caching and app preferences.
*   **Real-time Layer:** Laravel Echo WebSockets/Pusher for direct updates.

---

## 📁 Directory Structure

Here is a high-level overview of the app's file organization:

*   `lib/constants/` - Global strings, colors, styles, themes, and backend API routes.
*   `lib/models/` - Data models for mapping JSON responses.
*   `lib/services/` - Singleton services (Auth, HTTP client, WebSockets, Bluetooth Printing, Geocoding).
*   `lib/view_models/` - Stacked viewmodels managing screen logic and state.
*   `lib/views/pages/` - UI pages structured by domain (Auth, Order management, Products, Finance).
*   `lib/widgets/` - Reusable Custom UI components.

---

## 🚀 Build Environment & Configurations

The API endpoint can be changed at build time using Flutter's `--dart-define` option. If no value is provided, the app defaults to the endpoint configured in `lib/constants/api.dart`.

### Build Commands

```sh
flutter build apk --dart-define=api=https://your-domain.com/api
```

```sh
flutter build ios --dart-define=api=https://your-domain.com/api
```

> [!NOTE]
> The target endpoint URL must include the `/api` suffix. Trailing slashes are automatically normalized.
