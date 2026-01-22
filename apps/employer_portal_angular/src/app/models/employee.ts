import { ID } from './common';

export interface Employee {
  id: ID;
  employerId: ID;
  name: string;
  document?: string;
  email?: string;
  status: 'PENDING' | 'ACTIVE' | 'SUSPENDED' | 'REMOVED';
}

export interface ApprovalRequest {
  id: ID;
  employeeId: ID;
  type: 'ONBOARD' | 'LIMIT_CHANGE' | 'SUSPEND';
  createdAt: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  reason?: string;
}
