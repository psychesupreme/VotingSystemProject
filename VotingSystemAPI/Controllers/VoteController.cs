using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

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
        using (SqlConnection conn = new SqlConnection(_connectionString))
        {
            using (SqlCommand cmd = new SqlCommand("sp_CastVote", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // Safely mapping the parameters to prevent SQL Injection
                cmd.Parameters.AddWithValue("@p_VoterID", request.VoterId);
                cmd.Parameters.AddWithValue("@p_CandidateID", request.CandidateId);
                cmd.Parameters.AddWithValue("@p_PositionID", request.PositionId);

                try
                {
                    conn.Open();
                    // Using ExecuteScalar because our Stored Procedure returns a ResultMessage string
                    string resultMessage = (string)cmd.ExecuteScalar();

                    if (resultMessage.StartsWith("Error"))
                    {
                        return BadRequest(new { message = resultMessage });
                    }

                    return Ok(new { message = resultMessage });
                }
                catch (Exception ex)
                {
                    // Catching any unexpected system errors
                    return StatusCode(500, new { message = "An internal error occurred.", details = ex.Message });
                }
            }
        }
    }

    [HttpGet("leaderboard")]
    public IActionResult GetLeaderboard()
    {
        // This list will hold the rows we get from MSSQL
        var results = new List<object>();

        using (SqlConnection conn = new SqlConnection(_connectionString))
        {
            // We are querying the exact View you created earlier!
            string query = @"
                SELECT Position, [Candidate Name] AS CandidateName, [Total Votes] AS TotalVotes 
                FROM vw_UniversityElectionResults 
                ORDER BY Position, [Total Votes] DESC";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                try
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            // Add each row to our list
                            results.Add(new {
                                position = reader["Position"].ToString(),
                                candidateName = reader["CandidateName"].ToString(),
                                totalVotes = Convert.ToInt32(reader["TotalVotes"])
                            });
                        }
                    }
                    return Ok(results); // Send the list to Angular!
                }
                catch (Exception ex)
                {
                    return StatusCode(500, new { message = "Error loading leaderboard", details = ex.Message });
                }
            }
        }
    }
}

// A simple model to map the incoming JSON from Angular
public class VoteRequest
{
    public int VoterId { get; set; }
    public int CandidateId { get; set; }
    public int PositionId { get; set; }
}