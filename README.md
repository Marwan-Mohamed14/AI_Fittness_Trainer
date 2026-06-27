# AI Fitness Trainer

![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-2.10-3ECF8E?style=flat&logo=supabase&logoColor=white)
![Groq AI](https://img.shields.io/badge/Groq_AI-LLaMA_3.3_70B-F55036?style=flat)

A cross-platform mobile application that acts as a personal AI fitness coach. Users complete a short onboarding questionnaire about their fitness goals, body metrics, and dietary preferences, and the app uses the **Groq AI API (LLaMA 3.3 70B)** to generate a fully customized weekly workout and diet plan. The app supports daily check-ins, progress dashboards, nearby gym discovery, and a social community feed — all backed by a **Supabase** real-time database.

---

## Features

- **AI Plan Generation** — Personalized weekly workout splits (Full Body, PPL, Upper/Lower, etc.) and meal plans generated via Groq LLaMA 3.3 70B using Mifflin-St Jeor BMR calculations and gender-specific macro adjustments
- **Daily Tracking** — Log daily meal and workout completion; view monthly adherence stats on a visual dashboard
- **Nearby Gym Discovery** — Find gyms within a 5 km radius using Google Places API and interactive maps
- **Community Feed** — Share progress updates, images, and engage with other users through posts, comments, and likes
- **Onboarding Flow** — Multi-step questionnaire covering age, height, weight, gender, workout style, diet type, and budget
- **Dark / Light Theme** — Persistent theme preference with full Material Design 3 support
- **Cross-Platform** — Runs on Android, iOS, Web, macOS, Windows, and Linux

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.8+ (Dart) |
| State Management | GetX |
| Backend & Auth | Supabase (PostgreSQL, Auth, Realtime) |
| AI | Groq API — LLaMA 3.3 70B |
| Maps & Location | Google Places API, flutter_map, geolocator |
| Local Storage | sqflite, shared_preferences |
| Charts | fl_chart |
| Image Handling | image_picker, cached_network_image |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.8.1`
- A [Supabase](https://supabase.com) project with the following tables: `profiles`, `posts`, `comments`, `daily_logs`
- A [Groq API](https://console.groq.com) key
- A [Google Places API](https://developers.google.com/maps/documentation/places/web-service) key

### Installation

```bash
git clone https://github.com/Marwan-Mohamed14/AI_Fittness_Trainer.git
cd AI_Fittness_Trainer
flutter pub get
```

Create a `.env` file in the project root:

```env
GROQ_API_KEY=your_groq_api_key
GOOGLE_PLACES_API_KEY=your_google_places_api_key
```

Update `lib/supabase_config.dart` with your Supabase project URL and anon key.

```bash
flutter run
```

---

## Usage

1. **Sign up** with your email and complete the onboarding questionnaire
2. The app generates your personalized **weekly workout and diet plan** using AI
3. Each day, check in your **meals and workouts** completed
4. View your **monthly progress** on the dashboard
5. Explore **nearby gyms** on the map
6. Connect with others in the **community feed**
