import { ID } from './common';

export interface Role {
  id: ID;
  name: 'EMPLOYER' | 'ADMIN' | string;
}

export interface User {
  id: ID;
  email: string;
  name: string;
  roles: Role[];
  employerId?: ID;
  active: boolean;
}
