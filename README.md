# Job Portal - Recruitment Management System

A comprehensive job portal and recruitment management system built with Flutter (Frontend) and Node.js/Express (Backend).

## Core Features

### Recruiter Features
- **Job Management:** Post, update, and delete job listings.
- **Hiring Analytics:** Visual dashboard for tracking job performance, application trends, and hiring rates.
- **Featured Jobs:** Toggle job featured status to highlight priority roles.
- **Application Tracking:** Manage applicant statuses (Applied, Interview, Hired, Rejected).
- **Interview Scheduling:** Schedule and manage interview dates and locations for candidates.

### Candidate Features
- **Job Discovery:** Search and apply for jobs with real-time status tracking.
- **Featured Opportunities:** Prominent display of prioritized roles.
- **My Applications:** Comprehensive view of applied jobs with a visual status stepper.
- **Interview Tracking:** View upcoming interview details (date, location/link) directly on the dashboard.
- **Application Management:** Withdraw applications if needed.

### General Features
- **Role-Based Access:** Distinct experiences for Recruiters and Candidates.
- **Secure Authentication:** JWT-based login and signup system.
- **Professional UI:** Clean, modern designs with responsive layouts and glassmorphism elements.

## Getting Started

### Backend Setup
1. Navigate to the `backend` directory.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure environment variables in `.env`:
   ```env
   PORT=8000
   MONGODB_URL=your_mongodb_uri
   JWT_SECRET=your_secret
   ```
4. Run the server:
   ```bash
   npm run dev
   ```

### Frontend Setup
1. Navigate to the `frontend` directory.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## API Documentation
The backend exposes several endpoints for:
- `/api/auth`: User registration and login.
- `/api/jobs`: Job CRUD operations and analytics.
- `/api/applications`: Application lifecycle management and interview scheduling.
- `/api/user`: Profile management.