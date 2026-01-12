# Team Management Feature

## Overview
The team management system allows students to create and join teams for FBLA events. Each student can be part of only one team at a time, and teams are scoped to schools so students can only see teams from their own school.

## Features

### 1. Team Creation
- Students can create a team by filling out a questionnaire
- Questionnaire fields:
  - **Event Type**: Presentation, Roleplay, or Test
  - **Specific Event**: Different events based on the selected type
  - **Member Count**: Expected number of team members
- The creator automatically becomes a team member

### 2. Team Discovery
- Teams tab shows all teams in the student's school
- Displays team information:
  - Team name
  - Event type and specific event
  - Expected member count
  - Team leader name
- Students can see their membership status (Joined chip or Join button)

### 3. Team Joining
- Click on any team card to view more details
- Click "Join Team" button to request membership
- Single-team-per-profile enforcement:
  - Students can only be in one team
  - Cannot join a team if already in another team
  - Error message if attempting to join while already in a team

### 4. Team Management
- Students in a team see "Joined" status
- Only team creators can delete teams (by leaving)
- Non-creators can leave a team anytime

## Frontend Implementation

### Models
**Team** (`lib/models/team.dart`)
- Fields: id, name, school, eventType, eventName, memberCount, createdById, createdByUsername, createdAt
- Serialization: toJson() and fromJson() for API communication

### Services
**TeamService** (`lib/services/team_service.dart`)
- `fetchTeamsBySchool(school, token)` - Get all teams in a school
- `createTeam({name, school, eventType, eventName, memberCount, token})` - Create a new team
- `joinTeam(teamId, token)` - Join an existing team
- `leaveTeam(teamId, token)` - Leave a team (deletes team if creator, removes member otherwise)
- `getUserTeam(token)` - Get current user's team

### Screens
**EventsScreen** (`lib/screens/events_screen.dart`)
- Tab interface: Events tab and Teams tab
- Teams tab shows:
  - "Create a Team" button
  - List of all teams in user's school
  - Join functionality with single-team enforcement
  - Current user's team highlighted with "Joined" chip

**TeamQuestionnaireScreen** (`lib/screens/team_questionnaire_screen.dart`)
- Multi-step questionnaire:
  1. Select event type (Presentation/Roleplay/Test)
  2. Select specific event (conditional on type)
  3. Enter expected member count
- Form validation ensures all fields are filled
- Submit creates team and returns to events screen

## Backend Implementation

### Database Schema

#### teams table
```sql
CREATE TABLE teams (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  school VARCHAR(128) NOT NULL,
  event_type VARCHAR(64) NOT NULL,
  event_name VARCHAR(255) NOT NULL,
  member_count INT NOT NULL,
  created_by INT NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT now(),
  UNIQUE(created_by)  -- Only one team per creator
);
```

#### team_members table
```sql
CREATE TABLE team_members (
  id SERIAL PRIMARY KEY,
  team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT now(),
  UNIQUE(team_id, user_id)  -- Prevent duplicate members
);
```

### API Endpoints

#### GET /api/teams/school?school={school}
Fetch all teams in a school with member counts

**Response:**
```json
[
  {
    "id": 1,
    "name": "Team Business Plan",
    "school": "Test High School",
    "event_type": "presentation",
    "event_name": "Business Plan",
    "member_count": 3,
    "created_by": 12,
    "created_by_username": "john_doe",
    "created_at": "2026-01-12T11:32:33.659Z",
    "actual_member_count": 2
  }
]
```

#### GET /api/teams/user/current
Get the current user's team (requires authentication)

**Response:**
```json
{
  "id": 1,
  "name": "Team Business Plan",
  "school": "Test High School",
  "event_type": "presentation",
  "event_name": "Business Plan",
  "member_count": 3,
  "created_by": 12,
  "created_by_username": "john_doe",
  "created_at": "2026-01-12T11:32:33.659Z"
}
```
Or `null` if user is not in any team.

#### POST /api/teams
Create a new team (requires authentication)

**Request:**
```json
{
  "name": "Team Business Plan",
  "school": "Test High School",
  "event_type": "presentation",
  "event_name": "Business Plan",
  "member_count": 3
}
```

**Response:** (201 Created)
```json
{
  "id": 1,
  "name": "Team Business Plan",
  "school": "Test High School",
  "event_type": "presentation",
  "event_name": "Business Plan",
  "member_count": 3,
  "created_by": 12,
  "created_by_username": "john_doe",
  "created_at": "2026-01-12T11:32:33.659Z"
}
```

#### POST /api/teams/:id/join
Join a team (requires authentication)

**Response:**
```json
{
  "success": true,
  "message": "Successfully joined team"
}
```

**Errors:**
- 400: User already has a team
- 404: Team not found

#### POST /api/teams/:id/leave
Leave a team (requires authentication)

**Response:**
```json
{
  "success": true,
  "message": "Successfully left team"
}
```

**Behavior:**
- If user is the creator, deletes the entire team
- Otherwise, removes user from team

## Business Logic

### Single Team Per User
- Each user can only create one team (`UNIQUE(created_by)` in teams table)
- Each user can only be in one team (enforced at endpoint level)
- Backend checks before allowing join operations

### Team Deletion
- Teams are deleted when the creator leaves the team
- Teams cascade delete all team_members records
- Non-creators can leave without affecting the team

### Event Type Mapping
Frontend supports three event types:
- **Presentation**: Business Plan, Digital Citizenship, Financial Consulting, Global Business Management, Management Decision Making, Social Media Marketing
- **Roleplay**: Client Service, Coding & Programming, Network Design, Sales Presentation
- **Test**: Accounting, Business Calculation, Entrepreneurship, Finance, Hospitality Management, Management Information Systems

## Testing

Run the team functionality test:
```bash
cd backend
node test_teams.js
```

This will:
1. Create test users if needed
2. Create a team
3. Add team members
4. Verify team queries work correctly

## Future Enhancements
- Team invitations instead of open joining
- Member role assignments (leader, member, etc.)
- Team chat/collaboration features
- Event registration linking teams to official FBLA events
- Member limit validation
- Team member removal by creator
