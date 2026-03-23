import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Vote, VoteRequest } from './services/vote';

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

  // Exact Voters mapped directly to Master_Setup.sql
  allVoters = [
    { id: 1, name: 'Kamau Njoroge', type: 'Staff' },
    { id: 2, name: 'Wanjiku Mwangi', type: 'Staff' },
    { id: 3, name: 'Omondi Ochieng', type: 'Staff' },
    { id: 4, name: 'Akinyi Odhiambo', type: 'Staff' },

    { id: 1, name: 'Brian Kipruto', type: 'Student' },
    { id: 2, name: 'Alice Wanjiru', type: 'Student' },
    { id: 3, name: 'Kevin Otieno', type: 'Student' },
    { id: 4, name: 'Mercy Akinyi', type: 'Student' },

    { id: 1, name: 'John Njuguna', type: 'Resident' },
    { id: 2, name: 'Mary Wambui', type: 'Resident' },
    { id: 3, name: 'Peter Ouko', type: 'Resident' },
    { id: 4, name: 'Jane Anyango', type: 'Resident' },
    { id: 5, name: 'David Kiprono', type: 'Resident' },
    { id: 6, name: 'Sarah Chebet', type: 'Resident' },
    { id: 7, name: 'Daniel Mutisya', type: 'Resident' },
    { id: 8, name: 'Esther Mwikali', type: 'Resident' },
    { id: 9, name: 'Joseph Wekesa', type: 'Resident' },
    { id: 10, name: 'Gladys Nekesa', type: 'Resident' }
  ];

  // Exact Positions mapped to Master_Setup.sql
  allPositions = [
    { id: 1, name: 'Chairperson', type: 'Staff' },
    { id: 2, name: 'Secretary General', type: 'Staff' },

    { id: 3, name: 'Student President', type: 'Student' },
    { id: 4, name: 'Vice President', type: 'Student' },

    { id: 5, name: 'Estate Chairman', type: 'Resident' },
    { id: 6, name: 'Estate Treasurer', type: 'Resident' },
    { id: 7, name: 'Security Secretary', type: 'Resident' },
    { id: 8, name: 'Environment Secretary', type: 'Resident' }
  ];

  // Candidates mapped exactly to the SQL Database IDs
  allCandidates = [
    // --- RESIDENT CANDIDATES (IDs 1-8) ---
    { id: 1, name: 'John Njuguna (Estate Chairman)', type: 'Resident' },
    { id: 2, name: 'Peter Ouko (Estate Chairman)', type: 'Resident' },
    { id: 3, name: 'David Kiprono (Estate Treasurer)', type: 'Resident' },
    { id: 4, name: 'Daniel Mutisya (Estate Treasurer)', type: 'Resident' },
    { id: 5, name: 'Joseph Wekesa (Security Sec.)', type: 'Resident' },
    { id: 6, name: 'Samuel Kamau (Security Sec.)', type: 'Resident' },
    { id: 7, name: 'George Otieno (Environment Sec.)', type: 'Resident' },
    { id: 8, name: 'Evans Cheruiyot (Environment Sec.)', type: 'Resident' },

    // --- STAFF CANDIDATES (IDs 9-12 added via script) ---
    { id: 9, name: 'Kamau Njoroge (Chairperson)', type: 'Staff' },
    { id: 10, name: 'Omondi Ochieng (Chairperson)', type: 'Staff' },
    { id: 11, name: 'Wanjiku Mwangi (Sec Gen)', type: 'Staff' },
    { id: 12, name: 'Akinyi Odhiambo (Sec Gen)', type: 'Staff' },

    // --- STUDENT CANDIDATES (IDs 13-16 added via script) ---
    { id: 13, name: 'Brian Kipruto (Student Pres.)', type: 'Student' },
    { id: 14, name: 'Alice Wanjiru (Student Pres.)', type: 'Student' },
    { id: 15, name: 'Kevin Otieno (Vice Pres.)', type: 'Student' },
    { id: 16, name: 'Mercy Akinyi (Vice Pres.)', type: 'Student' }
  ];

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

  getElectionId(): number {
    if (this.activeElection === 'Staff') return 1;
    if (this.activeElection === 'Student') return 2;
    if (this.activeElection === 'Resident') return 3;
    return 0;
  }

  loadLeaderboard() {
    const currentElectionId = this.getElectionId();
    if (currentElectionId === 0) return;

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

    const votePayload: VoteRequest = {
      voterId: this.selectedVoterId,
      voterType: this.activeElection,
      candidateId: this.selectedCandidateId,
      positionId: this.selectedPositionId,
      electionId: this.getElectionId()
    };

    this.voteService.castVote(votePayload).subscribe({
      next: (response: any) => {
        alert('✅ Success! Your vote has been securely recorded in the database.');
        this.message = '✅ Vote Cast Successfully!';
        this.loadLeaderboard();

        this.selectedVoterId = 0;
        this.selectedCandidateId = 0;
        this.selectedPositionId = 0;
      },
      error: (err: any) => {
        const rawError = err.error?.message || err.message || '';

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