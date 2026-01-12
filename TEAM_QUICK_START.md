# Team Feature - Quick Start Guide for Developers

## 🚀 Getting Started (5 Minutes)

### 1. Database Setup
```bash
cd backend
# Create/update database schema
node -e "const db = require('./db'); db.query(require('fs').readFileSync('./sql/schema.sql', 'utf8')).then(() => console.log('✅ Schema initialized')).catch(e => console.error('❌ Error:', e.message))"
```

Expected output: `✅ Schema initialized`

### 2. Start Backend
```bash
cd backend
npm start
# Expected: "NEXORA backend listening on 3000"
```

### 3. Run Tests (Optional)
```bash
# In new terminal, from backend directory
node test_teams.js
# Expected: "=== All tests completed successfully! ==="
```

### 4. Launch Flutter App
```bash
# Hot reload should work automatically if backend is running
flutter run
```

---

## 📁 Project Structure

```
lib/
├── models/
│   └── team.dart                      # Team data model
├── services/
│   └── team_service.dart              # API integration
├── screens/
│   ├── events_screen.dart             # Events + Teams tabs
│   └── team_questionnaire_screen.dart # Team creation form

backend/
├── routes/
│   └── teams.js                       # All 5 team endpoints
├── sql/
│   └── schema.sql                     # Database schema
├── test_teams.js                      # Integration tests
├── index.js                           # App entry (includes teams route)
└── db.js                              # PostgreSQL connection
```

---

## 🔌 API Endpoints Reference

### List Teams by School
```
GET /api/teams/school?school=Jefferson%20High%20School
Authorization: Bearer <jwt_token>

Response (200):
[
  {
    "id": 1,
    "name": "Team Business Plan",
    "school": "Jefferson High School",
    "event_type": "presentation",
    "event_name": "Business Plan",
    "member_count": 3,
    "created_by": 12,
    "created_by_username": "john_doe",
    "created_at": "2026-01-12T11:32:33.659Z"
  }
]
```

### Get User's Current Team
```
GET /api/teams/user/current
Authorization: Bearer <jwt_token>

Response (200):
{
  "id": 1,
  "name": "Team Business Plan",
  "school": "Jefferson High School",
  ...
}
OR null if not in a team
```

### Create Team
```
POST /api/teams
Content-Type: application/json
Authorization: Bearer <jwt_token>

Body:
{
  "name": "Team Business Plan",
  "school": "Jefferson High School",
  "event_type": "presentation",
  "event_name": "Business Plan",
  "member_count": 3
}

Response (201):
{
  "id": 1,
  "name": "Team Business Plan",
  ...
}

Error (400):
{
  "error": "User already has a team"
}
```

### Join Team
```
POST /api/teams/1/join
Authorization: Bearer <jwt_token>

Response (200):
{
  "success": true,
  "message": "Successfully joined team"
}

Errors:
- 400: "User already has a team"
- 404: "Team not found"
```

### Leave Team
```
POST /api/teams/1/leave
Authorization: Bearer <jwt_token>

Response (200):
{
  "success": true,
  "message": "Successfully left team"
}

Note: If user is creator, entire team is deleted
```

---

## 🧪 Testing Checklist

### Unit Tests (API)
- [ ] Create team with valid data → Returns 201 with team
- [ ] Create team when user already in team → Returns 400
- [ ] Join team when user not in team → Returns 200
- [ ] Join team when user already in team → Returns 400
- [ ] Fetch teams by school → Returns all teams
- [ ] Get user's current team → Returns team or null
- [ ] Leave team as creator → Team deleted
- [ ] Leave team as member → User removed only

### Integration Tests
Run: `node backend/test_teams.js`
All operations tested end-to-end

### UI Tests (Manual)
1. **Create Team Flow**
   - [ ] Can select event type
   - [ ] Event list changes based on type
   - [ ] Member count validated
   - [ ] Button disabled until all filled
   - [ ] Team appears in list after creation

2. **Team Discovery**
   - [ ] Teams tab shows school teams only
   - [ ] Team cards display all info correctly
   - [ ] "Joined" status shows for user's team
   - [ ] "Join" button shows for others

3. **Team Joining**
   - [ ] Can click team to see details
   - [ ] Can join available team
   - [ ] Cannot join when already in team
   - [ ] Cannot create when already in team

4. **Error Handling**
   - [ ] Network errors show message
   - [ ] Validation errors caught
   - [ ] Loading states appear
   - [ ] Success notifications show

---

## 🐛 Common Issues & Solutions

### Issue: "error: column "created_by_username" does not exist"
**Solution**: Make sure schema is initialized:
```bash
node -e "const db = require('./db'); db.query(require('fs').readFileSync('./sql/schema.sql', 'utf8')).then(() => console.log('✅ OK')).catch(e => console.error('❌', e.message))"
```

### Issue: "Failed to join team"
**Check**:
1. User is authenticated (token in SharedPreferences)
2. User is not already in a team
3. Backend is running (on port 3000)
4. Team exists (valid team ID)

### Issue: "App can't find TeamService"
**Solution**: Add import:
```dart
import 'package:nexora_final/services/team_service.dart';
```

### Issue: "Team not showing after creation"
**Check**:
1. User's school is correctly saved in profile
2. Teams list filters by same school
3. Hot reload worked (check console)
4. Network request succeeded (check logs)

---

## 📊 Database Schema

### teams table
```sql
Column          | Type        | Notes
----------------|-------------|----
id              | SERIAL      | Primary key
name            | VARCHAR(255)| Team name
school          | VARCHAR(128)| User's school
event_type      | VARCHAR(64) | presentation|roleplay|test
event_name      | VARCHAR(255)| Specific event name
member_count    | INT         | Expected members
created_by      | INT         | References users.id
created_at      | TIMESTAMP   | Auto-set
UNIQUE(created_by)             | One team per creator
```

### team_members table
```sql
Column          | Type        | Notes
----------------|-------------|----
id              | SERIAL      | Primary key
team_id         | INT         | References teams.id
user_id         | INT         | References users.id
created_at      | TIMESTAMP   | Auto-set
UNIQUE(team_id, user_id)       | One membership per user per team
```

---

## 🔐 Authentication Flow

```
User Action → Flutter App → JWT Token (SharedPreferences)
                                     ↓
                            TeamService.method(token)
                                     ↓
                            Backend validates JWT
                                     ↓
                            Auth middleware extracts userId
                                     ↓
                            Database operation with userId
                                     ↓
                            Response to Flutter
                                     ↓
                            UI updated
```

All team endpoints require valid JWT token.

---

## 📝 Code Examples

### Fetch Teams in Your Screen
```dart
import 'package:nexora_final/services/team_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// In your widget
FutureBuilder<List<Team>>(
  future: () async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('nexora_user');
    final user = NexoraUser.fromJson(jsonDecode(userJson!));
    final token = prefs.getString('nexora_token')!;
    
    return TeamService.fetchTeamsBySchool(user.school!, token: token);
  }(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final teams = snapshot.data!;
      return ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) => TeamCard(team: teams[index]),
      );
    }
    return LoadingWidget();
  },
)
```

### Join a Team
```dart
void _joinTeam(int teamId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('nexora_token')!;
  
  final success = await TeamService.joinTeam(teamId, token: token);
  
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined team successfully!'))
    );
    setState(() {}); // Refresh UI
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to join team'))
    );
  }
}
```

### Create a Team
```dart
final team = await TeamService.createTeam(
  name: 'Team Business Plan',
  school: 'Jefferson High School',
  eventType: 'presentation',
  eventName: 'Business Plan',
  memberCount: 3,
  token: token,
);

if (team != null) {
  print('Created team: ${team.name}');
} else {
  print('Failed to create team');
}
```

---

## 🚨 Error Codes

### API Response Codes
| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Proceed normally |
| 201 | Created | Resource created, use returned data |
| 400 | Bad Request | Check validation, user feedback shown |
| 401 | Unauthorized | Re-authenticate user |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Check backend logs |

---

## 📞 Debugging Tips

### Check Backend Logs
```bash
# Watch logs while testing
npm start
# Look for POST /api/teams or GET /api/teams requests
```

### Check Frontend Logs
```
Debug Console in VS Code → Type: flutter logs
Or: Use print() statements in Dart
```

### Test Endpoints with cURL
```bash
# Get teams
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/teams/school?school=Jefferson%20High%20School

# Create team
curl -X POST http://localhost:3000/api/teams \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Test Team",
    "school": "Jefferson High School",
    "event_type": "presentation",
    "event_name": "Business Plan",
    "member_count": 3
  }'
```

---

## ✅ Pre-Launch Checklist

- [ ] Database schema initialized
- [ ] Backend tests pass (`node test_teams.js`)
- [ ] Backend running on port 3000
- [ ] Flutter app compiles without errors
- [ ] Team creation questionnaire works
- [ ] Teams list shows school teams
- [ ] Join functionality works
- [ ] Single-team constraint enforced
- [ ] Error messages display correctly
- [ ] Navigation returns properly
- [ ] Loading states appear
- [ ] Success notifications show

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| TEAM_FEATURE.md | Comprehensive technical reference |
| TEAM_UI_FLOW.md | User stories and UI flows |
| TEAM_IMPLEMENTATION_CHECKLIST.md | Detailed checklist |
| This file | Quick developer reference |

---

**Ready to develop! Happy coding! 🎉**
