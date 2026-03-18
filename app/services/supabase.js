import Service from '@ember/service';
import { createClient } from '@supabase/supabase-js';

export default class SupabaseService extends Service {
  client = createClient(
    import.meta.env.VITE_SUPABASE_URL,
    import.meta.env.VITE_SUPABASE_ANON_KEY
  );
}
