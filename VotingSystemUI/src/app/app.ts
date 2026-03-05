import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { VoteService } from './services/vote';

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
  activeElection: string = '';

  selectedVoterId: number = 0;
  selectedCandidateId: number = 0;
  selectedPositionId: number = 0;

  // A clean mix of the real names we just inserted
  allVoters = [
    { id: 8, name: 'David Mutua', type: 'National' },
    { id: 9, name: 'Faith Nduta', type: 'National' },
    { id: 10, name: 'George Odhiambo', type: 'National' },
    { id: 3, name: 'Brian Kiprotich', type: 'University' },
    { id: 4, name: 'Alice Wanjiru', type: 'University' },
    { id: 5, name: 'Cynthia Akinyi', type: 'University' }
  ];

  allPositions = [
    { id: 1, name: 'President of Kenya', type: 'National' },
    { id: 2, name: 'Governor of Nairobi', type: 'National' },
    { id: 3, name: 'Student Body President', type: 'University' },
    { id: 4, name: 'Secretary General', type: 'University' }
  ];

  allCandidates = [
    { id: 1, name: 'John Ochieng (President)', type: 'National' },
    { id: 2, name: 'Amina Hassan (President)', type: 'National' },
    { id: 3, name: 'Kamau Njoroge (Governor)', type: 'National' },
    { id: 4, name: 'Wanjiku Mwangi (Governor)', type: 'National' },
    { id: 5, name: 'Brian Kiprotich (Student Pres.)', type: 'University' },
    { id: 6, name: 'Alice Wanjiru (Student Pres.)', type: 'University' },
    { id: 7, name: 'Cynthia Akinyi (Sec. Gen.)', type: 'University' }
  ];

  constructor(private voteService: VoteService) { }

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

  // Filters the leaderboard display based on selected election
  get filteredLeaderboard() {
    if (!this.activeElection) return [];

    return this.leaderboard.filter(row => {
      // University shows Student and Secretary positions
      if (this.activeElection === 'University') {
        return row.position.includes('Student') || row.position.includes('Secretary');
      }
      // National shows President, Governor, and Senator positions
      if (this.activeElection === 'National') {
        return row.position.includes('President') || row.position.includes('Governor') || row.position.includes('Senator');
      }
      return true;
    });
  }

  loadLeaderboard() {
    this.voteService.getLeaderboard().subscribe({
      next: (data) => { this.leaderboard = data; },
      error: (err) => { this.message = 'Failed to load leaderboard.'; }
    });
  }

  submitVote() {
    if (!this.selectedVoterId || !this.selectedCandidateId || !this.selectedPositionId) {
      alert('Please select your Name, Position, and Candidate first!');
      return;
    }

    this.voteService.castVote(this.selectedVoterId, this.selectedCandidateId, this.selectedPositionId).subscribe({
      next: (response) => {
        // 1. Trigger the browser alert for immediate, undeniable feedback
        alert('✅ Success! Your vote has been securely recorded in the database.');

        // 2. Update the on-screen text
        this.message = '✅ Vote Cast Successfully!';

        // 3. Refresh the leaderboard and clear the form
        this.loadLeaderboard();
        this.selectedVoterId = 0;
        this.selectedCandidateId = 0;
        this.selectedPositionId = 0;
      },
      error: (err) => {
        // Capture the raw error from MSSQL
        const rawError = err.error?.message || '';

        // Intercept the specific UNIQUE constraint error and translate it
        if (rawError.includes('UNIQUE KEY constraint') || rawError.includes('duplicate key')) {
          const friendlyMessage = 'The database confirms you have already securely cast your vote for this position. No further action is needed.';

          alert('ℹ️ Notice: ' + friendlyMessage);
          this.message = 'ℹ️ ' + friendlyMessage;
        } else {
          // If it's a different kind of error, show it normally
          this.message = '❌ Error: ' + rawError;
          alert('❌ An error occurred while casting your vote.');
        }
      }
    });
  }
}