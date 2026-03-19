import Service from '@ember/service';
import { createClient } from '@supabase/supabase-js';

export default class SupabaseService extends Service {
  client = null;

  constructor() {
    super(...arguments);

    const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
    const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

    if (!supabaseUrl || !supabaseKey) {
      console.error('Supabase environment variables are missing!');
      console.error('VITE_SUPABASE_URL:', supabaseUrl);
      console.error('VITE_SUPABASE_ANON_KEY:', supabaseKey ? 'exists' : 'missing');
      return;
    }

    try {
      this.client = createClient(supabaseUrl, supabaseKey, {
        auth: {
          autoRefreshToken: true,
          persistSession: true,
          detectSessionInUrl: true,
        },
      });
    } catch (error) {
      console.error('Failed to initialize Supabase client:', error);
    }
  }

  get auth() {
    if (!this.client) {
      console.error('Supabase client not initialized');
      return null;
    }
    return this.client.auth;
  }

  get from() {
    if (!this.client) {
      console.error('Supabase client not initialized');
      return () => null;
    }
    return this.client.from.bind(this.client);
  }
}
