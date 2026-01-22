import { ID } from './common';

export interface Role {
  id: ID;
  name: 'MERCHANT' | 'OPERATOR' | 'ADMIN' | string;
}

export interface User {
  id: ID;
  email: string;
  name: string;
  roles: Role[];
  merchantId?: ID;
  active: boolean;
}
