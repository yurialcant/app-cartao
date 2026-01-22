import { ID } from './common';

export interface Role {
  id: ID;
  name: 'ADMIN' | 'EMPLOYER' | 'MERCHANT' | 'OPERATOR' | 'USER' | string;
}

export interface User {
  id: ID;
  email: string;
  name: string;
  roles: Role[];
  tenantId?: ID;
  active: boolean;
}
