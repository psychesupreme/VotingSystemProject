import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class VoteService {
  // We use the base URL for both endpoints now
  private apiUrl = 'http://localhost:5277/api/Vote';

  constructor(private http: HttpClient) { }

  // POST request to cast a vote
  castVote(voterId: number, candidateId: number, positionId: number): Observable<any> {
    const payload = {
      voterId: voterId,
      candidateId: candidateId,
      positionId: positionId
    };
    return this.http.post(`${this.apiUrl}/cast`, payload);
  }

  // GET request to fetch the live leaderboard
  getLeaderboard(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/leaderboard`);
  }
}