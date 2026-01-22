import { ID } from './common';

export interface Merchant {
  id: ID;
  name: string;
  mcc?: string;
  active: boolean;
}

export interface Terminal {
  id: ID;
  merchantId: ID;
  label: string;
  status: 'ACTIVE' | 'INACTIVE';
}
