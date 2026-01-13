# Team Feature UI Flow & User Stories

## 📱 Screen Flow Diagram

```
Events Screen
    ↓
[Events Tab] ← → [Teams Tab]
                    ↓
            ┌───────────────────┐
            │  Teams List       │
            │  - All school     │
            │    teams shown    │
            │  - Join buttons   │
            └───────────────────┘
                    ↑     ↑
        (click team) │     │ (click "Create Team")
                    │     │
                    │     └─→ Team Questionnaire
                    │              ↓
                    │         Q1: Event Type?
                    │              ↓
                    │         Q2: Specific Event?
                    │              ↓
                    │         Q3: Member Count?
                    │              ↓
                    │         Create Team →
                    │
            Team Detail Dialog
                    ↓
            [Cancel] [Join]
                     ↓
            Team joins user
            (shown in list with "Joined")
```

## 👤 User Story 1: Create a Team

### As a Student
I want to create a team for my event so I can organize my peers for competition.

### Scenario: Creating a Presentation Team
1. **Current State**: User has logged in, on Events screen
2. **User Action**: Taps "Teams" tab
3. **System Response**: Shows "Create a Team" button and empty teams list
4. **User Action**: Taps "Create a Team"
5. **System Response**: Shows questionnaire screen with first question
6. **User Action**: Selects "Presentation" from dropdown
7. **System Response**: Shows second question with presentation events list
8. **User Action**: Selects "Business Plan"
9. **System Response**: Shows third question for member count
10. **User Action**: Enters "3" members
11. **System Response**: "Create Team" button becomes enabled
12. **User Action**: Taps "Create Team"
13. **System Response**: 
    - Loading spinner appears
    - Team created on backend
    - User automatically added as member
    - Returns to teams list
14. **Outcome**: User's team appears in list with "Joined" badge

### Expected Feedback:
- Toast notification: "Team created successfully!"
- Visual: Team appears in list immediately
- Status: Shows "Joined" chip instead of "Join" button

---

## 👥 User Story 2: Join an Existing Team

### As a Student
I want to join a team created by another student in my school so I can participate in the competition.

### Scenario: Joining an Event Team
1. **Current State**: User logged in, on Teams tab, sees multiple teams
2. **User Action**: Taps on a team card to view details
3. **System Response**: Dialog opens showing:
   - Team name
   - Event type and specific event
   - Expected member count
   - Team leader name
4. **User Action**: Taps "Join Team" button in dialog
5. **System Response**:
   - Dialog closes
   - Success toast: "Successfully joined team!"
   - Team list refreshes
6. **Outcome**: 
   - Team now shows "Joined" chip
   - User cannot join any other team
   - Team is highlighted in list

### Expected Feedback:
- Toast: "Successfully joined team!"
- Visual: Team changes from "Join" button to "Joined" chip
- Color change: Team card highlights as current team

---

## 🚫 User Story 3: Attempt to Join While Already in Team

### As a Student
I should not be able to join multiple teams to prevent confusion and maintain fair competition.

### Scenario: Constraint Enforcement
1. **Current State**: User already in "Team A", viewing Teams tab
2. **User Action**: Tries to create new team
3. **System Response**: Button works but API returns error
4. **Outcome**: 
   - Error toast: "User already has a team"
   - Dialog closes
   - List unchanged

**Alternative Path:**
1. **Current State**: User already in "Team A", viewing another team
2. **User Action**: Taps "Join Team" on different team
3. **System Response**: Error message appears
4. **Outcome**:
   - Toast: "Failed to join team. You may already be in a team."
   - User remains in Team A
   - Can see Team A shows "Joined"

### Business Rules Enforced:
- ❌ Cannot create multiple teams (DB UNIQUE constraint)
- ❌ Cannot join while already in team (API validation)
- ❌ Cannot join same team twice (DB UNIQUE constraint)

---

## 🔍 User Story 4: View Teams in My School

### As a Student
I want to see all teams created in my school so I can find one to join.

### Scenario: Team Discovery
1. **Current State**: User from "Jefferson High School", on Events screen
2. **User Action**: Taps "Teams" tab
3. **System Response**: 
   - App fetches teams for user's school
   - Shows loading spinner during fetch
4. **Outcome**: Displays list of all teams at Jefferson High School
   - Team: "Team Business Plan"
     - Event: Presentation - Business Plan
     - Members: 3
     - Leader: john_doe
     - [Join] button
   
   - Team: "Team Digital Citizenship"
     - Event: Presentation - Digital Citizenship
     - Members: 2
     - Leader: sarah_smith
     - [Join] button
   
   - User's Team: "Team Finance"
     - Event: Test - Finance
     - Members: 4
     - Leader: mike_johnson
     - [Joined] (no button, shown as chip)

### Expected Behavior:
- Only shows teams from user's school
- Excludes teams from other schools
- User's team shows "Joined" status
- Other teams show "Join" button
- Teams listed with most recent first

---

## 📊 Team Creation Questionnaire Flow

### Step 1: Event Type Selection
```
┌──────────────────────────────────┐
│ Team Setup                       │
│                                  │
│ Q: What type of event are you    │
│    competing in?                 │
│                                  │
│ ┌────────────────────────────┐  │
│ │ ▼ Select event type        │  │
│ │  - Presentation            │  │
│ │  - Roleplay                │  │
│ │  - Test                    │  │
│ └────────────────────────────┘  │
│                                  │
│           [Create Team] ⊗         │ (disabled)
└──────────────────────────────────┘
```
- Dropdown with three options
- Next question appears after selection

### Step 2: Event Selection (Event Type = "Presentation")
```
┌──────────────────────────────────┐
│ Team Setup                       │
│                                  │
│ ✓ Event type: Presentation       │
│                                  │
│ Q: Which specific event?         │
│                                  │
│ ┌────────────────────────────┐  │
│ │ ▼ Select event             │  │
│ │  - Business Plan           │  │
│ │  - Digital Citizenship     │  │
│ │  - Financial Consulting    │  │
│ │  - Global Business Mgmt    │  │
│ │  - Management Decision Mkng│  │
│ │  - Social Media Marketing  │  │
│ └────────────────────────────┘  │
│                                  │
│           [Create Team] ⊗         │ (disabled)
└──────────────────────────────────┘
```
- Dynamic list based on selected type
- Includes all official FBLA events

### Step 3: Member Count
```
┌──────────────────────────────────┐
│ Team Setup                       │
│                                  │
│ ✓ Event: Presentation            │
│ ✓ Event: Business Plan           │
│                                  │
│ Q: How many members in your      │
│    team?                         │
│                                  │
│ ┌────────────────────────────┐  │
│ │ 3                      ▢   │  │
│ │ Enter number of members    │  │
│ └────────────────────────────┘  │
│                                  │
│         [Create Team] ✓           │ (enabled!)
└──────────────────────────────────┘
```
- Number input field
- Button enables when all fields filled
- Validates positive integer

---

## 🎨 Visual States

### Team Card - Not Joined
```
┌─────────────────────────────────┐
│ 👥 Team Business Plan           │
│                                 │
│ Presentation - Business Plan    │
│ 👥 3 members  👤 Led by john    │
│                     [Join]       │
└─────────────────────────────────┘
```

### Team Card - Joined (Current User)
```
┌─────────────────────────────────┐
│ 👥 Team Finance       [Joined] ✓ │
│                                 │
│ Test - Finance                  │
│ 👥 4 members  👤 Led by mike    │
│                                 │
└─────────────────────────────────┘
```

### Empty State - No Teams Yet
```
┌─────────────────────────────────┐
│                                 │
│           👥                    │
│                                 │
│      No teams yet               │
│                                 │
│  Be the first to create a team  │
│   for your school!              │
│                                 │
│      [Create a Team] →          │
│                                 │
└─────────────────────────────────┘
```

---

## ⏱️ Loading States

### Fetching Teams
- Circular progress spinner appears
- Message: "Loading teams..."
- Prevents user interaction until loaded

### Creating Team
- Loading spinner inside button
- Button text disappears
- Cannot be tapped during loading
- Shows success/error toast after completion

### Joining Team
- Dialog shows action processing
- Button disabled during request
- Returns to list with updated status

---

## 🔔 Notifications & Messages

### Success Messages
- ✅ "Team created successfully!" (toast, 2s)
- ✅ "Successfully joined team!" (toast, 2s)
- ✅ "Successfully left team!" (toast, 2s)

### Error Messages
- ❌ "Failed to create team" (with reason)
- ❌ "User already has a team"
- ❌ "Failed to join team. You may already be in a team."
- ❌ "Error: Not authenticated"

### Validation Messages
- "Missing required fields"
- "Team not found"
- "User is not a member of this team"

---

## 📱 Responsive Design

### Phone (360px - 600px)
- Teams list uses full width
- Cards stack vertically
- Buttons sized for touch (48px minimum)
- Questionnaire uses full screen

### Tablet (600px+)
- Same layout
- Increased padding for readability
- Touch-friendly spacing maintained

---

## ♿ Accessibility

- ✓ Semantic labels on all fields
- ✓ High contrast buttons and text
- ✓ Touch targets ≥48x48 dp
- ✓ Error messages clearly marked
- ✓ Loading states indicated
- ✓ Focus management in dialogs

---

**This flow provides an intuitive, error-resistant experience for team management!**
