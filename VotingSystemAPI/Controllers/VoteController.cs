using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Collections.Generic;
using System;
using Microsoft.Extensions.Configuration;

namespace VotingSystemAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VoteController : ControllerBase
    {
        private readonly string _connectionString;

        // Injecting the connection string from our appsettings
        public VoteController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        [HttpPost("cast")]
        public IActionResult CastVote([FromBody] VoteRequest request)
        {
            // 1. The Exclusive Arc Logic: Determine which column to insert into
            string voterColumn = "";
            if (request.VoterType == "Staff") voterColumn = "StaffID";
            else if (request.VoterType == "Student") voterColumn = "StudentID";
            else if (request.VoterType == "Resident") voterColumn = "ResidentID";
            else return BadRequest(new { message = "Invalid Voter Type. Must be Staff, Student, or Resident." });

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                // 2. TCL Transaction logic to ensure ACID properties
                string query = $@"
                    BEGIN TRY
                        BEGIN TRANSACTION LiveAPIVote;
                        
                        INSERT INTO Vote ({voterColumn}, CandidateID, PositionID, ElectionID)
                        VALUES (@VoterID, @CandidateID, @PositionID, @ElectionID);
                        
                        COMMIT TRANSACTION LiveAPIVote;
                        SELECT 'Success' as ResultMessage;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION LiveAPIVote;
                        SELECT 'Error: ' + ERROR_MESSAGE() as ResultMessage;
                    END CATCH";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    // Safely mapping parameters to prevent SQL Injection
                    cmd.Parameters.AddWithValue("@VoterID", request.VoterId);
                    cmd.Parameters.AddWithValue("@CandidateID", request.CandidateId);
                    cmd.Parameters.AddWithValue("@PositionID", request.PositionId);
                    cmd.Parameters.AddWithValue("@ElectionID", request.ElectionId);

                    try
                    {
                        conn.Open();
                        // Fetch the "ResultMessage" from our SQL TRY/CATCH block
                        string resultMessage = (string)cmd.ExecuteScalar();

                        // If database CHECK constraints fail (e.g., double voting), catch it here
                        if (resultMessage != null && resultMessage.StartsWith("Error"))
                        {
                            return BadRequest(new { message = resultMessage });
                        }

                        return Ok(new { message = "Vote cast successfully!" });
                    }
                    catch (Exception ex)
                    {
                        return StatusCode(500, new { message = "API Crash", details = ex.Message });
                    }
                }
            }
        }

        [HttpGet("leaderboard/{electionId}")]
        public IActionResult GetLeaderboard(int electionId)
        {
            var results = new List<object>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                // Advanced SQL: Using COALESCE to grab the name from whichever Subtype table is NOT NULL
                string query = @"
                    SELECT 
                        p.PositionName,
                        COALESCE(st.FirstName + ' ' + st.LastName, 
                                 stu.FirstName + ' ' + stu.LastName, 
                                 r.FirstName + ' ' + r.LastName) AS CandidateName,
                        COUNT(v.VoteID) AS TotalVotes
                    FROM Candidate c
                    INNER JOIN Position p ON c.PositionID = p.PositionID
                    LEFT OUTER JOIN Staff st ON c.StaffID = st.StaffID
                    LEFT OUTER JOIN Student stu ON c.StudentID = stu.StudentID
                    LEFT OUTER JOIN Resident r ON c.ResidentID = r.ResidentID
                    LEFT OUTER JOIN Vote v ON c.CandidateID = v.CandidateID
                    WHERE c.ElectionID = @ElectionID
                    GROUP BY p.PositionName, c.CandidateID, st.FirstName, st.LastName, stu.FirstName, stu.LastName, r.FirstName, r.LastName
                    ORDER BY p.PositionName, TotalVotes DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ElectionID", electionId);

                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                results.Add(new {
                                    position = reader["PositionName"].ToString(),
                                    candidateName = reader["CandidateName"].ToString(),
                                    totalVotes = Convert.ToInt32(reader["TotalVotes"])
                                });
                            }
                        }
                        return Ok(results);
                    }
                    catch (Exception ex)
                    {
                        return StatusCode(500, new { message = "Error loading leaderboard", details = ex.Message });
                    }
                }
            }
        }
    }

    // Updated Model matching our 3NF database requirements
    public class VoteRequest
    {
        public int VoterId { get; set; }
        public string VoterType { get; set; } // "Staff", "Student", or "Resident"
        public int CandidateId { get; set; }
        public int PositionId { get; set; }
        public int ElectionId { get; set; }
    }
}