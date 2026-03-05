import { TestBed } from '@angular/core/testing';

import { Vote } from './vote';

describe('Vote', () => {
  let service: Vote;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(Vote);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
