import { ID } from './common';

export type Currency = 'BRL' | 'USD' | string;

export interface Transaction {
  id: ID;
  merchantId: ID;
  terminalId?: ID;
  amount: number;
  currency: Currency;
  status: 'PENDING' | 'AUTHORIZED' | 'CAPTURED' | 'DECLINED' | 'REFUNDED' | 'FAILED';
  createdAt: string;
}

export interface TransactionFilter {
  merchantId?: ID;
  status?: Transaction['status'];
  from?: string;
  to?: string;
  minAmount?: number;
  maxAmount?: number;
  page?: number;
  pageSize?: number;
}
