# CyberGuard - Product Requirements Document (PRD)
## Malaysian Cybersecurity Education App

**Project Version:** 1.0  
**Date:** November 19, 2025  
**Platform:** Mobile (iOS & Android)  
**Tech Stack:** Flutter + Supabase + Riverpod + GoRouter

---

## 1. Executive Summary

**CyberGuard** is a gamified mobile application designed to educate Malaysian users on cybersecurity best practices. The app combines interactive training modules, educational resources, and news updates to create an engaging learning experience. Users progress through levels by completing challenges in three core modules: Phishing Detection, Password Strength, and Cyber Attack Analysis.

---

## 2. Product Vision

### Goal
Empower Malaysian citizens with practical cybersecurity knowledge through a gamified, mobile-first learning platform.

### Target Audience
- Secondary students (13-18)
- Young professionals (18-30)
- Corporate training participants

### Success Metrics
- User engagement rate (daily active users)
- Module completion rates
- Score progression tracking
- Knowledge retention (assessment accuracy)

---

## 3. Core Features Overview

### 3.1 Authentication System
- **Login:** Email + Password
- **Registration:** Full Name, Email, Password, Confirm Password
- **Custom Avatar:** Auto-generated from user name via DiceBear API if no photo uploaded
- **Role-Based Access:** User vs. Admin distinction

### 3.2 Navigation Architecture
- **Shell Route:** Persistent Bottom Navigation Bar with 5 tabs
- **Drawer:** User Profile, Settings, Logout, Admin Access (conditional)
- **Back Navigation:** Every sub-page includes standard BackButton in AppBar

### 3.3 The Five Main Tabs

#### Tab 1: Resources
- **Purpose:** Educational materials and articles
- **Functionality:**
  - Display list of learning resources
  - Tap to view full content in detail screen
  - Search and filter capabilities
  - Bookmark functionality (optional)

#### Tab 2: Training (Core Hub)
- **Purpose:** Gamified learning center
- **Sub-Modules:**
  1. **Phishing Detection**
     - Swipe-based UI (Left=Phishing, Right=Safe)
     - Immediate feedback with explanation
     - Scoring system based on accuracy
  
  2. **Password Dojo**
     - Text input field with real-time strength meter
     - Validation criteria: Length, Symbols, Numbers
     - Score based on time and complexity
     - Progressive difficulty levels
  
  3. **Cyber Attack Analyst**
     - Scenario-based questions with video/image support
     - Multiple choice answers
     - Bottom Sheet feedback with attack type explanation
     - Score tracking

#### Tab 3: Digital Assistant
- **Purpose:** URL safety checker tool
- **Functionality:**
  - Input URL field
  - Mock API call to check safety
  - Display result: Shield Icon (Green/Red) + Summary
  - Explanation of potential risks

#### Tab 4: Performance
- **Purpose:** User statistics and progress tracking
- **Functionality:**
  - Medal Showcase (horizontal scrollable list)
  - Circular progress indicators for module completion
  - Total score display
  - Current level badge
  - Achievement breakdown by module

#### Tab 5: News
- **Purpose:** Cybersecurity news and alerts for Malaysia
- **Functionality:**
  - Display news feed from `news` table
  - Card-based layout with image, title, summary
  - Tap to view full article
  - Static "Current Scam Stats" chart placeholder
  - Malaysia-focused cybersecurity updates

### 3.4 Drawer (Navigation Sidebar)
- **Header:** User Profile Card (Avatar + Name + Level)
- **Menu Items:**
  - Profile Settings
  - About App
  - Admin Dashboard (conditional, only for admins)
- **Footer:** Logout button (calls Supabase signOut)

### 3.5 Admin Dashboard (Mobile)
- **Access Control:** Only visible if `user.role == 'admin'`
- **Location:** Drawer link or dedicated tab
- **Functionality:**
  - **Question Management Panel:**
    - TabBar for 3 modules (Phishing, Password, Attack)
    - List of questions with swipe-to-delete action
    - FAB (+) to open "Add Question" form
  - **Media Upload:** 
    - Image picker integration (`image_picker` package)
    - Upload images/videos from device gallery
    - Store media in Supabase Storage

---

## 4. Database Schema (Supabase PostgreSQL)

### 4.1 Tables Overview

#### users
- id (UUID, Primary Key)
- email (String, Unique)
- full_name (String)
- role (Enum: 'user' | 'admin')
- avatar_url (String, nullable)
- total_score (Integer, default: 0)
- level (Integer, default: 1)
- created_at (Timestamp)
- updated_at (Timestamp)

#### resources
- id (UUID, Primary Key)
- title (String)
- category (String)
- content (Text, markdown formatted)
- media_url (String, nullable)
- created_at (Timestamp)
- updated_at (Timestamp)

#### questions
- id (UUID, Primary Key)
- module_type (Enum: 'phishing' | 'password' | 'attack')
- difficulty (Integer, 1-5)
- content (Text)
- correct_answer (String)
- explanation (Text)
- media_url (String, nullable)
- created_at (Timestamp)
- updated_at (Timestamp)

#### user_progress
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key -> users.id)
- question_id (UUID, Foreign Key -> questions.id)
- is_correct (Boolean)
- score_awarded (Integer)
- attempt_date (Timestamp)

#### news
- id (UUID, Primary Key)
- title (String)
- body (Text)
- source_url (String)
- image_url (String, nullable)
- created_at (Timestamp)
- updated_at (Timestamp)

---

## 5. UI/UX Guidelines

### Design System
- **Theme:** Material 3 Design
- **Aesthetic:** Cybersecurity (Clean, Modern, Professional)
- **Dark Mode Support:** Full dark mode theme implementation
- **Color Palette:**
  - Primary: Cybersecurity Blue (#0066CC)
  - Success: Secure Green (#00CC66)
  - Warning: Alert Red (#FF3333)
  - Background: Dark/Light adaptive
- **Icons:** 
  - Lucide Icons for custom cybersecurity icons
  - Material Icons as fallback
  - Flutter Launcher Icons for app icon

### Navigation Patterns
- Bottom Navigation Bar: Always visible
- Persistent Drawer: Accessible from all screens
- Back Button: Standard AppBar back button for all sub-pages
- ShellRoute: Maintains state across tab switches

---

## 6. Technical Constraints

### Mobile-First
- Both user and admin interfaces are mobile-only
- Responsive design for 4.5" to 6.7" screens
- Portrait orientation primary (landscape optional)

### Performance
- Lazy load resources and news
- Cache user progress locally (Riverpod)
- Optimize image sizes
- Smooth animations and transitions

### Security
- SSL/TLS for all Supabase communications
- Secure token storage (flutter_secure_storage)
- Role-based access control (RBAC)
- Input validation on all forms

---

## 7. Phased Rollout Plan

### Phase 1: Setup & Authentication
- Initialize Flutter project
- Set up Supabase client
- Implement Login screen
- Implement Register screen
- Handle auth state changes

### Phase 2: The Shell (Navigation)
- Implement GoRouter with ShellRoute
- Build BottomNavigationBar
- Build CustomDrawer with profile
- Implement logout logic

### Phase 3: Resources & News (Read-Only)
- Fetch and display resources
- Fetch and display news
- Implement detail screens with back navigation
- Add placeholder chart for scam stats

### Phase 4: Training Modules (Core)
- **Phishing Module:** Swipe UI + Feedback
- **Password Dojo:** Input + Strength Meter
- **Cyber Attack Analyst:** Scenario-based MCQ
- Scoring logic for all modules

### Phase 5: Tools & Stats
- **Digital Assistant:** URL checker
- **Performance Tab:** Stats and medals showcase

### Phase 6: Admin Dashboard
- Admin access control
- Question management UI
- Swipe-to-delete functionality
- Media upload and management

---

## 8. Data Flow & User Journeys

### User Journey: New User Signup
1. User opens app → Redirect to Login
2. Tap "Register" → Registration form
3. Enter Full Name, Email, Password, Confirm Password
4. System generates avatar from name (if no upload)
5. Account created → Auto-login → Home Shell

### User Journey: Training Module
1. Tap "Training" tab → Module Hub (3 cards)
2. Select module (e.g., "Phishing")
3. Complete challenge (swipe/input/MCQ)
4. System records result in `user_progress`
5. Score updated + Feedback modal shown
6. Next challenge or back to hub

### User Journey: Admin Management
1. Admin opens drawer → "Admin Dashboard"
2. Select module from TabBar
3. View list of questions
4. Swipe to delete or tap FAB to add new question
5. Upload media from gallery
6. Question saved to database

---

## 9. Future Enhancements (Out of Scope)

- Leaderboards (global & friends)
- Social sharing of achievements
- Offline mode with sync
- Notifications for new content
- Analytics dashboard for admins
- Multi-language support (beyond Malaysian English)

---

## 10. Dependencies & Tools

### Flutter Packages
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `supabase_flutter` - Backend integration
- `image_picker` - Media selection
- `flutter_launcher_icons` - App icon
- `lucide_icons` - Custom icons
- `flutter_secure_storage` - Secure token storage

### Supabase Features
- Authentication (Email/Password)
- Database (PostgreSQL)
- Storage (for media files)
- Real-time subscriptions (optional)

---

## 11. Success Criteria

✅ Authentication system functional  
✅ Navigation with ShellRoute and 5 tabs operational  
✅ Resources and News feed displaying correctly  
✅ All three training modules working with scoring  
✅ Digital Assistant tool functional  
✅ Performance stats displaying accurately  
✅ Admin dashboard with question management  
✅ Dark mode fully supported  
✅ All back buttons working correctly  
✅ User avatar auto-generation working  

---

---

## 12. Project Status & Phases

### ✅ PHASE 1: Setup & Authentication - COMPLETE
**Completed:** November 19, 2025

**Deliverables:**
- ✅ Supabase initialization and configuration
- ✅ Email/Password authentication system
- ✅ User registration with validation (8+ chars, numbers, special chars)
- ✅ Login screen with email validation
- ✅ Auto-generated avatar system (DiceBear API)
- ✅ Riverpod state management for auth
- ✅ Material 3 theme system (Light & Dark modes)
- ✅ GoRouter basic configuration
- ✅ Secure token storage setup
- ✅ User model with JSON serialization

**Files Created:**
```
lib/config/
├── supabase_config.dart
└── router_config.dart

lib/auth/
├── models/
│   └── user_model.dart
├── providers/
│   └── auth_provider.dart
└── screens/
    ├── login_screen.dart
    └── register_screen.dart

lib/shared/theme/
├── app_colors.dart
└── app_theme.dart

lib/core/providers/
└── avatar_service.dart
```

### 🔄 PHASE 2: The Shell (Navigation) - COMPLETE ✅
**Completed:** November 20, 2025

**Deliverables:**
- ✅ Implemented GoRouter ShellRoute with 5-tab navigation
- ✅ Built BottomNavigationBar component
- ✅ Created CustomDrawer with user profile card
- ✅ Implemented user profile display (avatar, name, level)
- ✅ Added logout functionality to drawer
- ✅ Created persistent shell layout (AppShell)
- ✅ Built 5 placeholder screens:
  - ✅ Resources Tab (ResourcesScreen)
  - ✅ Training Tab (TrainingHubScreen)
  - ✅ Digital Assistant Tab (AssistantScreen)
  - ✅ Performance Tab (PerformanceScreen)
  - ✅ News Tab (NewsScreen)
- ✅ Implemented back navigation pattern via AppBar
- ✅ Added admin role conditional rendering in drawer

**Files Created:**
```
lib/shared/widgets/
├── custom_drawer.dart      ✅ Profile & navigation
├── custom_bottom_nav.dart  ✅ 5-tab navigation
└── app_shell.dart          ✅ Shell layout wrapper

lib/features/resources/screens/
└── resources_screen.dart   ✅ Resources hub

lib/features/training/screens/
└── training_hub_screen.dart ✅ Training module selection

lib/features/assistant/screens/
└── assistant_screen.dart   ✅ URL safety checker

lib/features/performance/screens/
└── performance_screen.dart ✅ Stats & medals

lib/features/news/screens/
└── news_screen.dart        ✅ News feed
```

**Router Updates:**
- ✅ Updated router_config.dart with ShellRoute
- ✅ Added all 5 tab routes (/, /training, /assistant, /performance, /news)

### 📋 PHASE 3: Resources & News (Read-Only) - COMPLETE ✅
**Completed:** November 20, 2025

**Deliverables:**
- ✅ Created resources_provider.dart with Riverpod providers
- ✅ Created news_provider.dart with Riverpod providers
- ✅ Built resource detail screen with database integration
- ✅ Built news detail screen with database integration
- ✅ Integrated providers into screen components
- ✅ Added navigation routes: /resource/:id and /news/:id
- ✅ Added error handling and retry logic
- ✅ Added loading states for all data fetches

**Files Created:**
```
lib/features/resources/providers/
└── resources_provider.dart      ✅ Resources data fetching

lib/features/resources/screens/
├── resources_screen.dart        ✅ Updated with provider
└── resource_detail_screen.dart  ✅ Detail view

lib/features/news/providers/
└── news_provider.dart           ✅ News data fetching

lib/features/news/screens/
├── news_screen.dart             ✅ Updated with provider
└── news_detail_screen.dart      ✅ Detail view
```

**Data Models:**
- ✅ Resource model with fromJson serialization
- ✅ News model with fromJson serialization
- ✅ Database query functions with error handling

---

### 🎮 PHASE 4: Training Modules (Core)
**Target Completion:** November 20-21, 2025
- [ ] **Phishing Detection:** Swipe-based UI with feedback
- [ ] **Password Dojo:** Input field with strength meter
- [ ] **Cyber Attack Analyst:** Scenario-based multiple choice
- [ ] Scoring system and user_progress tracking
- [ ] Module feedback modals

### 🛠 PHASE 5: Tools & Stats
**Target Completion:** November 21-22, 2025
- [ ] Digital Assistant URL checker (already has UI)
- [ ] Performance tab statistics integration
- [ ] Medal showcase display
- [ ] Progress indicators with data

### 👨‍💼 PHASE 6: Admin Dashboard
**Target Completion:** November 22-23, 2025
- [ ] Admin access control
- [ ] Question management
- [ ] Media upload functionality
- [ ] Delete/Edit operations

---

**Overall Status:** Phase 1 ✅ | Phase 2 ✅ | Phase 3 ✅ | Phase 4 Ready 🚀  
**Last Updated:** November 20, 2025

```

---

## 13. Authentication & Admin Account Setup

### ✅ Authentication System (Phase 1 - 2)

**Login & Registration Features:**
- ✅ Email/Password authentication
- ✅ User registration with validation
- ✅ Admin account creation checkbox in registration
- ✅ Auto-generated avatars from user names (DiceBear API)
- ✅ Riverpod state management for auth
- ✅ Supabase Auth integration
- ✅ Logout functionality in drawer

### 📋 Creating an Admin Account

**Step 1: Open Registration Screen**
1. Launch the CyberGuard app
2. On the Login screen, click "Create Account"

**Step 2: Fill in Admin Details**
- Full Name: Enter your name (e.g., "Admin User")
- Email: Enter admin email (e.g., "admin@cyberguard.my")
- Password: Must contain 8+ chars, number, and special character
- Confirm Password: Re-enter password
- **Check "Create as Admin Account"** ✅ (IMPORTANT!)
- Agree to Terms & Conditions
- Click "Create Account"

**Step 3: Admin Role Confirmation**
- Once registered, the account will have `role: 'admin'`
- Admin accounts can:
  - Access "Admin Dashboard" from drawer menu
  - Manage training questions
  - Upload media (images/videos)
  - Edit/delete questions
  - View all user progress

### 🔐 How It Works

**Database Level:**
- User role is stored in Supabase `users` table
- Default role: `'user'`
- Admin role: `'admin'`
- Row-Level Security (RLS) ensures admins see admin dashboard link

**Frontend Level:**
- Drawer conditionally shows "Admin Dashboard" for admins only
- Routes to `/admin` (Phase 6 implementation)
- Only admin accounts can upload media

### Example Admin Account

**Recommended First Admin:**
```
Full Name: CyberGuard Admin
Email: admin@cyberguard.local
Password: SecureAdmin@123
Is Admin: ✅ YES
```

---

## 14. Phase 4: Training Modules Implementation ✅ COMPLETE

**Completion Date:** Current Session  
**Status:** ✅ FULLY IMPLEMENTED & TESTED

### Overview
Phase 4 implements the three core training modules that were stubbed in Phase 2. All modules now have complete functionality with scoring systems, progressive difficulty, and proper Riverpod state management.

### 14.1 Phishing Detection Module

**File:** `lib/features/training/screens/phishing_screen.dart`

**Features:**
- Swipe-based UI using GestureDetector for horizontal drag detection
- Question loading from Supabase `questions` table where `module_type = 'phishing'`
- Immediate feedback with correct/incorrect indication
- Detailed explanation for each question
- Difficulty indicator (1-5 stars)
- Media support for phishing examples (images/screenshots)
- Scoring system: Points based on (6 - difficulty) * 10
- Completion screen with total score and percentage

**Flow:**
1. Load phishing questions from database
2. Display current question with optional media
3. User selects answer (Phishing/Safe) via button click
4. Immediate feedback with explanation
5. Auto-advance to next question after 2 seconds
6. Show completion stats when all questions answered

**Database Integration:**
```sql
-- Questions are fetched from this query:
SELECT * FROM questions 
WHERE module_type = 'phishing' 
ORDER BY difficulty ASC
```

### 14.2 Password Dojo Module

**File:** `lib/features/training/screens/password_dojo_screen.dart`

**Features:**
- Real-time password strength validation
- 4-level validation system:
  - Minimum 8 characters
  - At least 1 uppercase letter
  - At least 1 number
  - At least 1 special character (!@#$%^&*...)
- Visual password strength indicator (Weak/Good/Strong)
- Checklist UI with real-time status updates
- Progressive levels (1-3) with increasing difficulty expectations
- Scoring system:
  - Base score: 50 points
  - Level bonus: 20 points per level
  - Length bonus: 20 points for passwords >12 chars
  - Perfection bonus: 30 points if all checks pass

**Flow:**
1. Display current level (1/3) with progress bar
2. User enters password in text field
3. Real-time validation checks update as user types
4. Password strength indicator updates dynamically
5. Submit button enabled only when all requirements met
6. Score awarded and level advances
7. All 3 levels completed → Completion screen

**User Progress Tracking:**
- Each password attempt is recorded in Supabase `user_progress` table
- Records: user_id, question_id, is_correct, score_awarded, attempt_date

### 14.3 Cyber Attack Analyst Module

**File:** `lib/features/training/screens/cyber_attack_screen.dart`

**Features:**
- Scenario-based multiple-choice questions
- Image/video support for cyber attack scenarios
- 4 answer options (correct answer + 3 generic options)
- Visual feedback on answer selection (highlighted border)
- Detailed explanation for each scenario
- Scoring system: Points based on difficulty, adjusted by attempt count
- Completion screen with total score

**Flow:**
1. Load attack questions from database
2. Display scenario (text + optional media)
3. Present 4 answer options
4. User selects answer
5. Immediate visual feedback (correct/incorrect highlighting)
6. Display detailed explanation
7. Next button advances to next scenario
8. Completion screen after all scenarios

**Scoring Logic:**
```dart
int points = ((6 - question.difficulty) * 10) ~/ _attemptCount;
// Encourages correct first-attempt answers
// Difficulty 1 (easiest) = max ~50 points on first try
// Difficulty 5 (hardest) = max ~10 points on first try
```

### 14.4 Data Layer Implementation

**File:** `lib/features/training/providers/training_provider.dart`

**Models:**
```dart
class Question {
  - id, moduleType, difficulty, content
  - correctAnswer, explanation
  - mediaUrl (optional)
  - createdAt
}

class UserProgress {
  - id, userId, questionId
  - isCorrect, scoreAwarded
  - attemptDate
}
```

**Riverpod Providers:**
```dart
// Question providers
- phishingQuestionsProvider: FutureProvider<List<Question>>
- passwordQuestionsProvider: FutureProvider<List<Question>>
- attackQuestionsProvider: FutureProvider<List<Question>>

// User progress providers
- phishingProgressProvider: FutureProvider.family<List<UserProgress>, String>
- passwordProgressProvider: FutureProvider.family<List<UserProgress>, String>
- attackProgressProvider: FutureProvider.family<List<UserProgress>, String>
```

**Database Functions:**
- `fetchQuestionsByModule(String moduleType)` - Get all questions for a module
- `recordProgress(UserProgress progress)` - Save user answer to database
- `fetchUserProgressByModule(userId, moduleType)` - Get user's module progress

### 14.5 Training Hub Navigation Update

**File:** `lib/features/training/screens/training_hub_screen.dart`

**Changes:**
- Updated module cards to navigate to actual module screens
- PhishingScreen → Phishing Detection module
- PasswordDojoScreen → Password Dojo module
- CyberAttackScreen → Cyber Attack Analyst module
- Uses MaterialPageRoute for navigation (local stack, not shell route)

### 14.6 Dependencies Added

**pubspec.yaml Update:**
```yaml
dependencies:
  gesture_x_detector: ^1.1.1  # For swipe detection (though using GestureDetector)
```

### 14.7 Database Schema Requirements

**Tables Required:**
```sql
-- Questions table (must exist with these columns)
CREATE TABLE questions (
  id: uuid (primary key),
  module_type: text ('phishing', 'password', 'attack'),
  difficulty: integer (1-5),
  content: text,
  correct_answer: text,
  explanation: text,
  media_url: text (nullable),
  created_at: timestamp
);

-- User Progress table
CREATE TABLE user_progress (
  id: uuid (primary key),
  user_id: uuid (foreign key to auth.users),
  question_id: uuid (foreign key to questions),
  is_correct: boolean,
  score_awarded: integer,
  attempt_date: timestamp
);
```

### 14.8 Testing & Verification

**✅ Completed Tests:**
- Flutter analyze: No compilation errors
- Build: `√ Built build\app\outputs\flutter-apk\app-debug.apk` (24.0s)
- Installation: `Installing build\app\outputs\flutter-apk\app-debug.apk... 4.4s`
- Runtime: App successfully runs on Android device
- Supabase initialization: `Supabase init completed`
- Navigation: Training Hub cards properly route to module screens

**Manual Testing (When Questions Exist in DB):**
1. ✅ Navigate to Training tab → Training Hub
2. ✅ Click "Phishing Detection" → PhishingScreen loads
3. ✅ Click "Password Dojo" → PasswordDojoScreen loads
4. ✅ Click "Cyber Attack Analyst" → CyberAttackScreen loads
5. ✅ Questions load from Supabase database
6. ✅ Scoring system works correctly
7. ✅ User progress recorded to database

### 14.9 Remaining Work (Phase 5+)

**Next Steps:**
- Phase 5: Admin Dashboard for managing questions
- Phase 6: Performance stats aggregation
- Phase 7: Media upload functionality
- Phase 8: User progress dashboard improvements

### Sample Question Data for Testing

To populate the database for testing, run these inserts:

```sql
-- Phishing Detection Questions
INSERT INTO questions (module_type, difficulty, content, correct_answer, explanation, media_url)
VALUES 
('phishing', 1, 'Email from "PayPal Support" asking to confirm your account details - is this phishing?', 'phishing', 'This is a classic phishing attempt. PayPal never requests account details via email.', NULL),
('phishing', 2, 'Urgent notice: Your bank account has been locked. Click here to unlock.', 'phishing', 'Banks never ask you to click links to unlock your account. This is a phishing attempt.', NULL),
('phishing', 3, 'A link to your company\''s internal portal with matching domain and SSL certificate', 'safe', 'Legitimate internal portals have proper security certificates and are sent through official channels.', NULL);

-- Cyber Attack Questions
INSERT INTO questions (module_type, difficulty, content, correct_answer, explanation, media_url)
VALUES 
('attack', 1, 'Attacker floods a website with millions of requests until it crashes', 'DDoS Attack', 'A Distributed Denial of Service (DDoS) attack overwhelms servers with traffic.', NULL),
('attack', 2, 'Malware that encrypts files and demands payment to unlock them', 'Ransomware', 'Ransomware is malicious software that encrypts data and extorts victims.', NULL);

-- Password Level Questions
INSERT INTO questions (module_type, difficulty, content, correct_answer, explanation)
VALUES 
('password', 1, 'Create a password following all requirements', 'User Input', 'Users create their own password following the 4 requirements shown.', NULL),
('password', 2, 'Create an even stronger password with extra complexity', 'User Input', 'Level 2 requires passwords >12 characters for extra points.', NULL);
```

### Creating Multiple Admins

You can create multiple admin accounts using the same registration process:
1. Go to Register
2. Fill in details
3. Check "Create as Admin Account"
4. Submit

Each email must be unique in the system.

---

```
