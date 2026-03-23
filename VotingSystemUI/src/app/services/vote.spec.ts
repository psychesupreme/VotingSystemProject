import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { Vote } from './vote';

describe('Vote', () => {
  let service: Vote;

  beforeEach(() => {
    TestBed.configureTestingModule({
      // Imported testing module to handle the HTTP requests
      imports: [HttpClientTestingModule],
      providers: [Vote]
    });
    service = TestBed.inject(Vote);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});