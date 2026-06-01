# Techia ATS — Flutter App

A full-featured Applicant Tracking System built with Flutter, matching the Techia ATS dark design.

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # Root widget + MultiProvider setup
├── app_router.dart                    # Route generation + splash/auth guard
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            # All color tokens (dark palette)
│   │   ├── app_text_styles.dart       # Typography scale
│   │   ├── app_theme.dart             # ThemeData configuration
│   │   └── theme.dart                 # Barrel export
│   ├── constants/
│   │   ├── app_constants.dart         # API paths, stage names, filter options
│   │   └── app_routes.dart            # Route name constants
│   └── utils/
│       └── app_utils.dart             # DateUtils, String/Context extensions
│
├── data/
│   ├── models/
│   │   ├── candidate_model.dart       # Candidate data class + fromJson/toJson
│   │   ├── auth_model.dart            # AuthModel data class
│   │   ├── candidate_filter_model.dart # Filter + pagination models
│   │   └── models.dart                # Barrel export
│   ├── services/
│   │   └── api_service.dart           # HTTP client (get/post/patch + auth headers)
│   └── repositories/
│       ├── auth_repository.dart       # Login, logout, session persistence
│       └── candidates_repository.dart # Fetch candidates, advance stage, stats
│
├── providers/
│   ├── auth_provider.dart             # AuthStatus state, login/logout
│   └── candidates_provider.dart       # Candidates list, filter, pagination, selection
│
└── presentation/
    ├── screens/
    │   ├── auth/
    │   │   └── login_screen.dart      # Sign in page (email/password + demo)
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart  # Main dashboard (responsive layout)
    │   └── candidates/                # (reserved for future candidate detail screen)
    │
    └── widgets/
        ├── common/
        │   └── common_widgets.dart    # StatusBadge, SectionChip, CandidateAvatar,
        │                              # StatCard, AppPrimaryButton, AppOutlinedButton,
        │                              # InfoRow, LabeledDivider
        ├── candidates/
        │   ├── candidates_table.dart  # Full candidates table with pagination
        │   ├── candidate_detail_panel.dart  # Right panel: candidate details + actions
        │   └── pipeline_stage_indicator.dart # Applied → Interview → Hired indicator
        └── dashboard/
            └── dashboard_widgets.dart # DashboardHeader, SearchAndFilterBar, dropdowns
```

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| `bgPrimary` | `#0A0F1A` |
| `bgCard` | `#111827` |
| `accentCyan` | `#38BDF8` |
| `textPrimary` | `#FFFFFF` |
| `textSecondary` | `#94A3B8` |
| `border` | `#1E293B` |
| `stageActive` | `#F59E0B` (amber dot) |

Font: **Inter** (weights 400–800)

---

## 📦 Dependencies

```yaml
provider: ^6.1.2         # State management
http: ^1.2.1             # API calls
shared_preferences: ^2.3.2  # Token persistence
intl: ^0.19.0            # Date formatting
```

---

## 🚀 Getting Started

1. Add Inter font files to `assets/fonts/`  
   Download from: https://fonts.google.com/specimen/Inter

2. Update `AppConstants.baseUrl` in `lib/core/constants/app_constants.dart`

3. Run:
```bash
flutter pub get
flutter run
```

---

## 📱 Responsive Behavior

| Breakpoint | Layout |
|-----------|--------|
| `< 600px` (Mobile) | Stacked: Table → Detail below |
| `600–1023px` (Tablet) | 2-col grid for stats, stacked content |
| `≥ 1024px` (Desktop) | Side-by-side: Table (3fr) + Detail (2fr) |

---

## 🔐 Auth Flow

1. App starts → `SplashScreen` checks `SharedPreferences` for stored token  
2. Token found → navigate to `DashboardScreen`  
3. No token → navigate to `LoginScreen`  
4. Login success → token stored → navigate to `DashboardScreen`  
5. Logout → token cleared → navigate to `LoginScreen`
