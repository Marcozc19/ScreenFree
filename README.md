# ScreenFree

A native iOS app for phone addiction/screen time management built with SwiftUI.

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## Setup

### 1. Open the Project

```bash
open ScreenFree.xcodeproj
```

### 2. Configure Supabase

Edit `ScreenFree/App/SupabaseClient.swift` and replace the placeholder values:

```swift
static let url = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
static let anonKey = "YOUR_ANON_KEY"
```

### 3. Configure Firebase Analytics

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an iOS app with bundle identifier `com.screenfree.app`
3. Download `GoogleService-Info.plist` and add it to the project

### 4. Set Up FamilyControls Capability

1. In Xcode, select the project target
2. Go to "Signing & Capabilities"
3. Ensure "Family Controls" capability is enabled
4. You need a paid Apple Developer account for this capability

### 5. Install Dependencies

When you open the project in Xcode, it will automatically resolve Swift Package Manager dependencies:
- supabase-swift
- firebase-ios-sdk (Analytics only)

## Project Structure

```
ScreenFree/
├── App/                     # App entry point and global state
├── Core/Design/            # Theme and reusable components
├── Models/                 # Data models
├── Services/               # Auth, Database, ScreenTime, Analytics
├── Onboarding/            # 6-screen onboarding flow
├── Main/                  # Main app after onboarding
├── Utilities/             # Helper functions
└── Resources/             # Assets and preview content
```

## Onboarding Flow

1. **Splash** - Animated intro with phone usage statistics
2. **Account Creation** - Email/password auth with Supabase
3. **Permission Gate** - FamilyControls authorization
4. **Mirror** - Animated screen time counter with category breakdown
5. **First Challenge** - Accept the "Morning Clarity" challenge
6. **Dashboard Entry** - XP toast and welcome to the main app

## Supabase Tables

Create these tables in your Supabase project:

```sql
-- User profiles
create table user_profiles (
  id uuid primary key references auth.users(id),
  display_name text not null,
  age_range text not null,
  xp integer default 0,
  level integer default 1,
  baseline_screen_time double precision,
  onboarding_completed boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- User challenges
create table user_challenges (
  id uuid primary key default uuid_generate_v4(),
  challenge_id text not null,
  user_id uuid references user_profiles(id),
  status text default 'active',
  started_at timestamp with time zone default now(),
  completed_at timestamp with time zone,
  progress integer default 0
);

-- Enable RLS
alter table user_profiles enable row level security;
alter table user_challenges enable row level security;

-- RLS policies
create policy "Users can read own profile"
  on user_profiles for select
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on user_profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on user_profiles for update
  using (auth.uid() = id);

create policy "Users can read own challenges"
  on user_challenges for select
  using (auth.uid() = user_id);

create policy "Users can insert own challenges"
  on user_challenges for insert
  with check (auth.uid() = user_id);

create policy "Users can update own challenges"
  on user_challenges for update
  using (auth.uid() = user_id);
```

## Notes

- FamilyControls requires a physical device for testing
- Screen Time API doesn't provide direct historical data access - the app uses mock data for MVP
- The app uses iOS 17's `@Observable` macro for state management
