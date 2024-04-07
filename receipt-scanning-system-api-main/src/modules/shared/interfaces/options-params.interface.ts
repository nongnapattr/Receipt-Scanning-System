export interface OptionParams {
  page?: number;
  offset?: number;
  limit?: number;
  fields?: string;
  text?: string;
  filter?: string;
  s?: string;
  sort?: string;
  from?: string;
  to?: string;
  views?: 'date' | 'month' | 'year';
  is_full_text?: string;
  year?: string;
  month?: string;
}
