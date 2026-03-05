# 🗳️ Secure Multi-Election Voting System

A robust, full-stack enterprise voting application built to handle multiple concurrent elections (e.g., National and University levels). This project demonstrates a secure 3-tier architecture with a focus on database integrity, fraud prevention, and real-time data visualization.

## 🛠️ Technology Stack
* **Frontend:** Angular (Modern Zoneless Architecture), TypeScript, HTML/CSS
* **Backend API:** ASP.NET Core Web API (C#)
* **Database:** Microsoft SQL Server (MSSQL)

## ✨ Key Features
* **Multi-Election Support:** Dynamically filters voters, positions, and candidates based on the active election.
* **Fraud Prevention:** Enforces strict `UNIQUE KEY` database constraints to completely prevent double-voting.
* **Live Leaderboard:** Real-time results fetched via secure API endpoints connected to an optimized SQL View.
* **Security Auditing:** Automated millisecond-precision timestamps (`VoteTime` and `RegistrationDate`) for all transactions.
* **Data Integrity:** Fully normalized relational database with strict Foreign Key constraints.

## 🚀 Setup Instructions for Contributors

### 1. Database Setup
1. Run the provided SQL scripts (located in `/SQL_Scripts`) in SQL Server Management Studio to generate the schema, insert the initial test data, and create the `vw_VotingAudit` and `vw_UniversityElectionResults` views.

### 2. Backend API Setup (.NET)
1. Navigate to the `VotingSystemAPI` folder.
2. Create an `appsettings.json` file and add your local MSSQL connection string:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=VotingSystemDB;Trusted_Connection=True;TrustServerCertificate=True;"
     }
   }