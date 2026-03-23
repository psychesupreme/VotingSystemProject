import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Vote, VoteRequest } from './services/vote'; // Fixed import to match our new service

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './app.html',
  styleUrls: ['./app.css']
})
export class App implements OnInit {
  title = 'VotingSystemUI';
  message = '';
  leaderboard: any[] = [];

  // We will map this string to our 3NF database voter types
  activeElection: string = '';

  selectedVoterId: number = 0;
  selectedCandidateId: number = 0;
  selectedPositionId: number = 0;

  // Updated to match our SQL database Supertype/Subtype demographics
  allVoters = [
    { id: 1, name: 'Kamau Njoroge', type: 'Staff' },
    { id: 2, name: 'Wanjiku Mwangi', type: 'Staff' },
    { id: 1, name: 'Brian Kipruto', type: 'Student' },
    { id: 2, name: 'Alice Wanjiku', type: 'Student' },
    { id: 1, name: 'John Njuguna', type: 'Resident' },
    { id: 2, name: 'Mary Wambui', type: 'Resident' }
  ];

  allPositions = [
    { id: 1, name: 'Committee Chairperson', type: 'Staff' },
    { id: 2, name: 'Secretary General', type: 'Staff' },
    { id: 3, name: 'Student President', type: 'Student' },
    { id: 4, name: 'Vice President', type: 'Student' },
    { id: 5, name: 'Estate Chairman', type: 'Resident' },
    { id: 6, name: 'Estate Treasurer', type: 'Resident' }
  ];

  allCandidates = [
    { id: 1, name: 'Kamau Njoroge (Chairperson)', type: 'Staff' },
    { id: 2, name: 'Omondi Ochieng (Chairperson)', type: 'Staff' },
    { id: 8, name: 'Brian Kipruto (Student Pres.)', type: 'Student' },
    { id: 9, name: 'Hillary Ochieng (Student Pres.)', type: 'Student' },
    { id: 18, name: 'John Njuguna (Estate Chairman)', type: 'Resident' },
    { id: 19, name: 'Peter Ouko (Estate Chairman)', type: 'Resident' }
  ];

  // Injected the properly named Vote service
  constructor(private voteService: Vote) { }

  ngOnInit() {
    this.loadLeaderboard();
  }

  get filteredVoters() {
    return this.allVoters.filter(v => v.type === this.activeElection);
  }

  get filteredPositions() {
    return this.allPositions.filter(p => p.type === this.activeElection);
  }

  get filteredCandidates() {
    return this.allCandidates.filter(c => c.type === this.activeElection);
  }

  // Helper method to map the UI selection to our SQL Election IDs
  getElectionId(): number {
    if (this.activeElection === 'Staff') return 1;
    if (this.activeElection === 'Student') return 2;
    if (this.activeElection === 'Resident') return 3;
    return 0;
  }

  loadLeaderboard() {
    const currentElectionId = this.getElectionId();
    if (currentElectionId === 0) return;

    // Updated to pass the required Election ID to the API
    // Explicitly typed (data: any) and (err: any) to satisfy strict mode
    this.voteService.getLeaderboard(currentElectionId).subscribe({
      next: (data: any) => { this.leaderboard = data; },
      error: (err: any) => { this.message = 'Failed to load leaderboard.'; }
    });
  }

  submitVote() {
    if (!this.selectedVoterId || !this.selectedCandidateId || !this.selectedPositionId) {
      alert('Please select your Name, Position, and Candidate first!');
      return;
    }

    // Construct the exact JSON payload the .NET API expects for the Exclusive Arc
    const votePayload: VoteRequest = {
      voterId: this.selectedVoterId,
      voterType: this.activeElection, // 'Staff', 'Student', or 'Resident'
      candidateId: this.selectedCandidateId,
      positionId: this.selectedPositionId,
      electionId: this.getElectionId()
    };

    // Explicitly typed (response: any) and (err: any)
    this.voteService.castVote(votePayload).subscribe({
      next: (response: any) => {
        alert('✅ Success! Your vote has been securely recorded in the database.');
        this.message = '✅ Vote Cast Successfully!';
        this.loadLeaderboard();

        // Reset form
        this.selectedVoterId = 0;
        this.selectedCandidateId = 0;
        this.selectedPositionId = 0;
      },
      error: (err: any) => {
        const rawError = err.error?.message || err.message || '';

        // Intercepting the UNIQUE constraint error we built into MS SQL
        if (rawError.includes('UNIQUE') || rawError.includes('duplicate')) {
          const friendlyMessage = 'The database confirms you have already securely cast your vote for this position. No further action is needed.';
          alert('ℹ️ Notice: ' + friendlyMessage);
          this.message = 'ℹ️ ' + friendlyMessage;
        } else {
          this.message = '❌ Error: ' + rawError;
          alert('❌ An error occurred while casting your vote.');
        }
      }
    });
  }
}