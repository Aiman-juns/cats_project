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

**Status:** Awaiting Phase 1 execution command.
