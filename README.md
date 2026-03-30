<p align="center">
  <img src="assets/images/precision_banner.png" alt="Precision — A calculator that feels like science" width="100%"/>
</p>

<h1 align="center">Precision</h1>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://github.com/jayshivram/Precision/releases"><img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android"></a>
  <a href="https://github.com/jayshivram/Precision/releases/latest"><img src="https://img.shields.io/github/v/release/jayshivram/Precision?include_prereleases&sort=semver&color=78DC77&label=Latest%20Release" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Custom-lightgrey.svg" alt="License: Custom"></a>
</p>

<p align="center"><strong>A calculator that feels like science.</strong></p>

---

## What is Precision?

Precision is a clean, modern multi-tool calculator app built with Flutter — designed for people who want more than just basic math. Whether you're splitting a bill, converting miles to kilometers, checking today's live exchange rate, looking up a historical rate from a specific date, crunching trig functions, or planning a loan with EMI calculations — Precision handles it all from one sleek dark-themed interface.

No ads. No clutter. Just a beautiful tool that does exactly what you need.

---

## Features

### 🔢 Basic Calculator
- Addition, subtraction, multiplication, and division — the essentials done right
- Percentage calculations and sign toggle (+/−)
- Live expression preview so you can see what you're typing before you hit equals
- Full calculation history — scroll back and pick up where you left off

### 🧪 Scientific Calculator
- **Trigonometry:** sin, cos, tan (and their inverses — asin, acos, atan)
- **Logarithms:** natural log (ln) and base-10 log
- **Powers & Roots:** x², x^y, square root, e^x, 10^x
- **Constants:** π and Euler's number (e) built right in
- Factorials, absolute values, and random number generation
- Switch between **Degrees** and **Radians** with a single tap
- Parentheses for complex nested expressions

### 📏 Unit Converter
- **Length** — mm, cm, m, km, in, ft, yd, mi
- **Area** — mm², cm², m², km², ha, ac, ft², yd², mi²
- **Volume** — mm³, cm³, m³, L, mL, gal, qt, pt, cup, fl oz, in³, ft³
- **Mass** — mg, g, kg, t, oz, lb, st
- **Speed** — m/s, km/h, mph, kn
- **Time** — ns, μs, ms, s, min, h, d, wk, mo, yr
- **Temperature** — °C, °F, K
- Swap units instantly with the swap button
- Quick-reference grid showing related conversions at a glance

### 💱 Currency Converter
- **35+ world currencies** with live exchange rates and historical lookups
- **Live rates** powered by [FreeExchangeRateApi (Haxqer)](https://github.com/haxqer/FreeExchangeRateApi) — no API key required
- **Historical rates** powered by [Frankfurter](https://github.com/lineofflight/frankfurter) — look up any past date, no API key required
- Major currencies: USD, EUR, GBP, JPY, CAD, AUD, CHF
- Asian & Pacific: CNY, INR, KRW, SGD, HKD, THB, IDR, MYR, PHP, PKR, NZD
- Middle East & Africa: AED, SAR, ZAR, NGN, EGP, KES, TZS, UGX, CDF, ZWL, ZMW
- Americas: MXN, BRL
- Europe: NOK, SEK, DKK, TRY, RUB
- Searchable currency picker with country flag emojis
- In-memory rate cache (5-minute TTL) to minimise API calls
- Auto-refreshes on base currency change; manual refresh button available
- Connection status indicator (online / offline / error) with last-updated timestamp
- Graceful offline fallback to stale cache, then to bundled mock rates
- Swap currencies with one tap

### 💰 Finance Calculators
Six dedicated financial tools accessible from the unit converter's **Finance** tab:

| Tool | What It Calculates |
|---|---|
| **Compound Interest** | Final amount, total interest, ROI — with annual / quarterly / monthly / daily compounding |
| **Simple Interest** | Interest earned, final amount, ROI |
| **EMI (Loan)** | Monthly instalment, total payment, total interest |
| **SIP** | Future value of a Systematic Investment Plan, total invested, gains |
| **Lumpsum** | Future value of a one-time investment, returns, ROI |
| **Margin / Markup** | Gross profit, margin on sales, markup on cost, cost ratio — in Cost+Sale or Cost+Markup% mode |

### 🧾 VAT Calculator
- Enter any amount and VAT rate to get net / VAT / gross breakdown instantly (live calculation — no button press needed)
- Toggle between **Exclusive** mode (net → gross) and **Inclusive** mode (gross → net)
- Supports any custom VAT rate

### 🏦 Provisional Tax Calculator (Tanzania)
- **Sole Proprietor** — TRA individual income tax brackets applied to annual profit
- **Corporate** — flat corporate tax rate (30%) applied to annual profit
- Both modes support **forward** (profit → tax) and **reverse** (desired tax → required profit) calculations
- Quarterly instalment breakdown included in all results

### ⚙️ Settings & Preferences
- **Decimal precision** — choose how many decimal places to display (default: 6)
- **Scientific notation** toggle for very large or very small numbers
- **Thousands separator** — commas for readability (on by default)
- **Haptic feedback** — feel every button press (or turn it off)
- **Currency refresh interval** — set how often live rates auto-update

### 🎨 Design & Experience
- Gorgeous **dark theme** with a vibrant green (`#78DC77`) accent palette
- Material Design 3 with smooth rounded corners and subtle gradients
- **Manrope** for display / numeric text, **Inter** for labels — carefully chosen typography
- Animated splash screen on launch
- Responsive layout — adapts between bottom navigation (mobile) and top tabs (wider screens)

---

## Download

Grab the latest signed APK from the **[Releases](https://github.com/jayshivram/Precision/releases/latest)** page — no Play Store needed. Just download, install, and go.

> **Note:** You may need to enable "Install from unknown sources" in your Android settings.

---

## Build It Yourself

Want to tinker with the code or build from source? Here's how:

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x, Dart ≥ 3.11)
- Android SDK (API 21+)
- A code editor (VS Code, Android Studio, etc.)

### Steps

```bash
# Clone the repo
git clone https://github.com/jayshivram/Precision.git
cd Precision

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Or build a release APK
flutter build apk --release
```

### API Keys

Precision uses **two external APIs** for its currency features:

#### API 1 — Live Exchange Rates: FreeExchangeRateApi
> **No API key required.**

Provided by [`haxqer/FreeExchangeRateApi`](https://github.com/haxqer/FreeExchangeRateApi).  
Endpoint used: `https://api.exchangerate.fun/latest?base=<CURRENCY>`  
Used for: fetching the current exchange rates in the currency converter.

#### API 2 — Historical Exchange Rates: Frankfurter
> **No API key required.**

Provided by [`lineofflight/frankfurter`](https://github.com/lineofflight/frankfurter).  
Endpoint used: `https://api.frankfurter.dev/v2/rates?date=<YYYY-MM-DD>&base=<CURRENCY>`  
Used for: looking up historical rates on any specific past date.

#### Optional — FreeCurrencyAPI (Legacy / Fallback)
The file `lib/constants/api_keys.dart` also contains a `kFreeCurrencyApiKey` constant for the [FreeCurrencyAPI](https://freecurrencyapi.com/) service. This was an earlier provider and is kept as a reference. The app currently uses the two no-key APIs above by default.

---

## Architecture

Precision follows a clean, layered architecture using **Riverpod** for state management.

### Provider Pattern for APIs

The currency subsystem uses a provider interface pattern so the data source can be swapped at runtime without touching UI code:

```
IExchangeRateProvider          IHistoricalRateProvider
       │                               │
  HaxqerProvider              FrankfurterProvider
  FreeCurrencyApiProvider      FreeCurrencyApiProvider
  MockProvider (offline fallback)
```

- `ExchangeRateService` wraps a live-rate provider with a **5-minute in-memory cache** and automatic stale-cache / offline fallback.
- `HistoricalRateService` wraps a historical provider and converts dates to `YYYY-MM-DD` format before making requests.
- Both services are exposed as Riverpod `Provider`s and injected into the UI via `StateNotifierProvider`.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart 3.11) |
| State Management | Riverpod 2.x |
| Math Engine | math_expressions |
| HTTP Client | http |
| Persistence | shared_preferences |
| Typography | Google Fonts (Manrope, Inter) |
| Formatting | intl |
| Notifications | flutter_local_notifications |
| App Info | package_info_plus |

---

## Project Structure

```
lib/
├── main.dart                        # Entry point
├── app.dart                         # Root widget, navigation shell, theming
│
├── constants/
│   ├── api_keys.dart                # FreeCurrencyAPI key (legacy/optional)
│   ├── currencies.dart              # CurrencyInfo list with flags (35+ currencies)
│   ├── tax_rates.dart               # Tanzania TRA tax brackets & corporate rate
│   └── units.dart                   # Unit factors, categories, and display names
│
├── models/
│   ├── exchange_rates.dart          # ExchangeRates model + convert() helper
│   ├── history_entry.dart           # Calculator history entry model
│   └── settings_model.dart          # App settings model (precision, separators, etc.)
│
├── providers/
│   ├── app_state_provider.dart      # Global app state
│   ├── calculator_provider.dart     # Basic calculator state & logic
│   ├── currency_provider.dart       # Currency converter state + historical rate query
│   ├── history_provider.dart        # Calculation history persistence
│   ├── settings_provider.dart       # Settings persistence via shared_preferences
│   ├── unit_converter_provider.dart # Unit converter state & conversion logic
│   └── update_provider.dart         # GitHub release update check
│
├── screens/
│   ├── splash_screen.dart           # Animated launch screen
│   ├── basic_calculator_screen.dart # Standard calculator UI
│   ├── scientific_calculator_screen.dart # Scientific mode UI
│   ├── currency_converter_screen.dart    # Live + historical currency converter
│   └── unit_converter_screen.dart       # Unit converter with Finance/VAT/Tax tabs
│
├── services/
│   ├── exchange_rate_service.dart   # Caching wrapper for live rate provider
│   ├── historical_rate_service.dart # Wrapper for historical rate provider
│   ├── notification_service.dart    # Local notification handling
│   ├── update_service.dart          # GitHub releases update checker
│   └── providers/
│       ├── i_exchange_rate_provider.dart    # Interface for live rate providers
│       ├── i_historical_rate_provider.dart  # Interface for historical rate providers
│       ├── haxqer_provider.dart             # Live rates via exchangerate.fun (Haxqer)
│       ├── frankfurter_provider.dart        # Historical rates via Frankfurter
│       ├── free_currency_api_provider.dart  # FreeCurrencyAPI (live + historical)
│       └── mock_provider.dart               # Offline fallback with bundled rates
│
├── theme/
│   └── app_theme.dart               # Color palette, typography, Material 3 theme
│
├── utils/
│   └── formatters.dart              # Number formatters, ThousandsInputFormatter
│
└── widgets/
    ├── calc_button.dart             # Reusable calculator button
    ├── calc_display.dart            # Calculator display widget
    ├── finance_calculator.dart      # Finance tools (Compound, Simple, EMI, SIP, Lumpsum, Margin)
    ├── history_panel.dart           # Slide-up calculation history panel
    ├── provisional_tax_calculator.dart # Tanzania provisional tax (Sole Prop + Corporate)
    ├── settings_panel.dart          # App settings slide-up panel
    └── vat_calculator.dart          # VAT calculator (exclusive/inclusive modes)
```

---

## Contributing

Found a bug? Have an idea? Contributions are welcome.

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-idea`)
3. Commit your changes (`git commit -m "Add my idea"`)
4. Push to the branch (`git push origin feature/my-idea`)
5. Open a Pull Request

---

## License

Copyright (c) 2026 Jay Shivram. All rights reserved.

This software and its source code are proprietary and confidential. Unauthorized copying, distribution, modification, or use of this code, in whole or in part, is strictly prohibited without the prior written permission of the copyright holder.

For permission requests, contact: Jay Shivram.

This project is licensed under the **Custom License** — see the [LICENSE](LICENSE) file for details.

---

**Attribution Required:**  
If you use, copy, modify, or distribute this code, you must provide clear and visible credit to:

Jay Shivram — https://github.com/jayshivram/Precision

---

<p align="center">
  Built with ☕ and Flutter<br/>
  <strong>Precision</strong> — because math deserves good design.
</p>
