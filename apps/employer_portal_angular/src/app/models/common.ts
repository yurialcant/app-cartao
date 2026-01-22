export type ID = string;

export interface Paginated<T> {
  items: T[];
  page: number;
  pageSize: number;
  total: number;
}

export interface ApiResponse<T> {
  data: T;
  message?: string;
  success: boolean;
}
