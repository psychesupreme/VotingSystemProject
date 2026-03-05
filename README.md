# 🗳️ Secure Multi-Election Voting System

A robust full-stack application designed for secure voting at both National and University levels. This project demonstrates a production-ready architecture using **Angular**, **ASP.NET Core**, and **SQL Server**.

---

## 🚀 Quick Start (For Contributors)

### 1. Clone the Repository
```bash
git clone [https://github.com/psychesupreme/VotingSystemProject.git](https://github.com/psychesupreme/VotingSystemProject.git)
cd VotingSystemProject
```

### 2. Database Setup
1. Open `Database/Master_Setup.sql` in SQL Server Management Studio.
2. Run the script to create the database, tables, and populate it with 100 test voters.

### 3. Backend API Setup (.NET)
1. Open `VotingSystemAPI` in Visual Studio.
2. **Configure Connection String:**
   - Create an `appsettings.json` file in the `VotingSystemAPI` folder.
   - Add your local SQL Server connection string:
     ```json
     {
       "ConnectionStrings": {
         "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=VotingSystemDB;Trusted_Connection=True;TrustServerCertificate=True;"
       }
     }
     ```
3. Run the API (Ctrl+F5).

### 4. Frontend Setup (Angular)
1. Open `VotingSystemUI` in VS Code.
2. Run `npm install` to install dependencies.
3. Run `ng serve` to start the application.
4. Open [http://localhost:4200](http://localhost:4200) in your browser.

---

## 🏗️ Architecture

### 3-Tier Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     USER INTERFACE (Angular)                │
│  - Zoneless Components, Reactive Forms, Bootstrap Styling   │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     BUSINESS LOGIC (ASP.NET Core)           │
│  - Controllers, Services, DTOs, CORS Configuration        │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     DATA ACCESS (SQL Server)                │
│  - Tables, Views (vw_VotingAudit), Stored Procedures        │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Features

### 1. Double-Vote Prevention
- **Database Constraint:** `UNIQUE KEY (VoterID, PositionID)` ensures a voter can only vote once per position.
- **API Validation:** Backend checks for existing votes before insertion.

### 2. Data Integrity
- **Foreign Keys:** All relationships are strictly enforced at the database level.
- **Timestamps:** `GETDATE()` automatically records vote times with millisecond precision.

### 3. Audit Trail
- **`vw_VotingAudit` View:** Provides a real-time, read-only log of all votes cast.
- **`RegistrationDate`:** Tracks when voters were added to the system.

---

## 📋 Key Features

### Multi-Election Support
- **Dynamic Filtering:** The UI automatically filters voters, positions, and candidates based on the selected election type.
- **Separate Elections:** Supports concurrent elections (e.g., National vs. University).

### User Experience
- **Live Leaderboard:** Real-time results displayed in sortable tables.
- **Clear Feedback:** Immediate success or error messages with browser alerts.
- **Responsive Design:** Clean Bootstrap 5 styling.

---

## 📂 Project Structure

```
VotingSystemProject/
├── VotingSystemAPI/          # ASP.NET Core Backend
│   ├── Controllers/          # API Endpoints
│   ├── Models/               # Data Models
│   ├── Services/             # Business Logic
│   └── appsettings.json      # Configuration
├── VotingSystemUI/           # Angular Frontend
│   ├── src/app/             # Components & Services
│   ├── src/assets/           # Images & Styles
│   └── package.json          # Dependencies
├── Database/                 # SQL Scripts
│   └── Master_Setup.sql      # Complete Database Setup
└── README.md                 # Project Documentation
```

---

## 🔧 Development Guidelines

### Adding a New Election
1. **Database:** Add a new record to the `Election` table.
2. **API:** Update `appsettings.json` with the new election ID if needed.
3. **UI:** The frontend will automatically pick up the new election via the API.

### Adding a New Candidate
1. **Database:** Insert into `Candidate` table with valid `VoterID`, `PositionID`, and `ElectionID`.
2. **API:** No changes needed (uses Dapper to fetch from DB).
3. **UI:** Refresh the page to see the new candidate.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Create a feature branch (`git checkout -b feature/AmazingFeature`).
2. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
3. Push to the branch (`git push origin feature/AmazingFeature`).
4. Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.