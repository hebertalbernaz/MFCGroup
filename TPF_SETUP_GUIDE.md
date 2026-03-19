# TPF System - Phase 1 Setup Guide

## Overview

Phase 1 of The Pod Factory ERP System has been successfully implemented with:
- Supabase database with profiles, projects, and settings tables
- Role-Based Access Control (RBAC) authentication
- Login screen with email/password authentication
- Role-based sidebar navigation
- Dashboard with test project creation
- Settings page for Admin users

## Database Structure

### Tables Created

1. **profiles** - User profiles with role-based access
   - `id` (uuid) - User ID from auth.users
   - `email` (text) - User email address
   - `full_name` (text) - User's full name
   - `role` (text) - User role: Admin, Designer, Estimator, Purchasing
   - Row Level Security (RLS) enabled

2. **projects** - Project management
   - `tpf_id` (text) - Official project ID (e.g., POD-1024)
   - `client_name` (text) - Client name
   - `status` (text) - Project status
   - `internal_notes` (text) - Staff-only notes
   - RLS enabled with Admin-only write access

3. **app_settings** - System configuration
   - `next_pod_number` - Counter for project IDs

## Creating the Default Admin User

To set up the default Admin user (hebert.albernaz@gmail.com), follow these steps:

### Option 1: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to **Authentication** > **Users**
3. Click **Add user** > **Create new user**
4. Enter:
   - Email: `hebert.albernaz@gmail.com`
   - Password: (choose a secure password)
   - Auto Confirm User: **Yes**
5. Click **Create user**
6. Copy the User ID (UUID) that was created
7. Navigate to **Table Editor** > **profiles**
8. Click **Insert** > **Insert row**
9. Enter:
   - `id`: (paste the User ID from step 6)
   - `email`: `hebert.albernaz@gmail.com`
   - `full_name`: `Hebert Albernaz`
   - `role`: `Admin`
10. Click **Save**

### Option 2: Using SQL Editor

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Create a new query and run:

```sql
-- First, create the auth user
-- Note: You'll need to use the Supabase Auth API or Dashboard to create the auth user first
-- Then use this query to create the profile

-- After creating the auth user, get their ID and run:
INSERT INTO profiles (id, email, full_name, role)
VALUES (
  'USER_ID_FROM_AUTH_USERS',  -- Replace with actual UUID from auth.users
  'hebert.albernaz@gmail.com',
  'Hebert Albernaz',
  'Admin'
);
```

### Option 3: Using Supabase Auth Signup API

You can also use the application's signup functionality (if you add it) or use the Supabase client:

```javascript
// Sign up the user
const { data, error } = await supabase.auth.signUp({
  email: 'hebert.albernaz@gmail.com',
  password: 'your-secure-password',
});

if (data.user) {
  // Create the profile
  await supabase
    .from('profiles')
    .insert({
      id: data.user.id,
      email: 'hebert.albernaz@gmail.com',
      full_name: 'Hebert Albernaz',
      role: 'Admin'
    });
}
```

## User Roles & Permissions

### Admin
- Full access to all features
- Can view Dashboard, Design Desk, Quoting Desk, Surveys
- Can access Reports and Settings
- Can create test projects
- Can modify system settings (POD number counter)

### Designer
- Access to Design Desk only
- Can view and work on design projects

### Estimator
- Access to Quoting Desk only
- Can create and manage quotes

### Purchasing
- Access to Procurement only
- Can manage purchasing and procurement tasks

## Features Implemented

### 1. Authentication
- Email/password authentication via Supabase
- Automatic session management
- Profile loading with role-based permissions
- Secure logout functionality

### 2. Dashboard (Admin)
- Statistics cards showing project counts
- "Test: Create Project" button to test the invisible engine
- Recent projects table
- Automatic POD number generation

### 3. Settings Page (Admin Only)
- POD Number Counter management
- Preview of next project ID
- System information display

### 4. Navigation
- Role-based sidebar showing only relevant menu items
- User profile display with role badge
- Professional industrial design

## Testing the System

1. **Login**
   - Navigate to the login page
   - Enter: `hebert.albernaz@gmail.com`
   - Enter your password
   - Click "Sign In"

2. **Test Project Creation** (Admin only)
   - Navigate to Dashboard
   - Click "Test: Create Project"
   - A new project will be created with ID POD-1000 (or next available number)
   - The counter will automatically increment to 1001

3. **Manage Settings** (Admin only)
   - Navigate to Settings
   - View the current "Next POD Number"
   - Modify if needed
   - Click "Save Settings"

## Next Steps (Future Phases)

Phase 2 and beyond could include:
- Full project management interface
- Design desk functionality
- Quoting system with catalog
- Document management
- Reporting and analytics
- Email notifications
- File uploads and storage

## Technical Details

### Technology Stack
- **Framework**: Ember.js with Embroider
- **Build Tool**: Vite
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Styling**: Custom CSS with design tokens
- **Locale**: English (Ireland) - en-IE
- **Currency**: Euro (€)
- **Date Format**: DD/MM/YYYY

### Environment Variables
The following environment variables are required:
- `VITE_SUPABASE_URL` - Your Supabase project URL
- `VITE_SUPABASE_ANON_KEY` - Your Supabase anonymous key

These are already configured in your `.env` file.

## Support

For issues or questions, please refer to the project documentation or contact the development team.
