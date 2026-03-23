import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

// The interface matching our updated API 3NF requirements
export interface VoteRequest {
  voterId: number;
  voterType: string;
  candidateId: number;
  positionId: number;
  electionId: number;
}

@Injectable({
  providedIn: 'root'
})
export class Vote {
  // Base URL pointing to our .NET API. 
  // NOTE: Verify this port number matches your .NET terminal output!
  // If your terminal said 5277, change this line to 5277:
  private baseUrl = 'http://localhost:5277/api/vote';

  constructor(private http: HttpClient) { }

  // Method to securely cast the vote
  castVote(voteData: VoteRequest): Observable<any> {
    return this.http.post(`${this.baseUrl}/cast`, voteData);
  }

  // Method to fetch the live leaderboard based on the specific election ID
  getLeaderboard(electionId: number): Observable<any> {
    return this.http.get(`${this.baseUrl}/leaderboard/${electionId}`);
  }
}