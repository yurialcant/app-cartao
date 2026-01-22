import { ID } from './common';

export interface TenantConfigKV {
  key: string;
  value: string;
}

export interface Tenant {
  id: ID;
  name: string;
  code: string;
  active: boolean;
  config?: TenantConfigKV[];
  createdAt?: string;
}
