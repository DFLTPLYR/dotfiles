export type Todo = {
  id: string;
  title: string;
  description?: string;
  status: string;
  is_completed: number;
  is_sync: number;
  created_at?: string;
  updated_at?: string;
};
