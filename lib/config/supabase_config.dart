class SupabaseConfig {
  // IMPORTANT: Replace with your actual Supabase credentials
  // Get these from: https://app.supabase.com/project/_/settings/api
  //
  // Steps:
  // 1. Go to your Supabase project dashboard
  // 2. Click Settings > API
  // 3. Copy "Project URL" and paste below as supabaseUrl
  // 4. Copy "anon public" key (starts with 'eyJ...') and paste below as supabaseAnonKey

  static const String supabaseUrl = 'https://imwklqppxecdlqinbgsg.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_QsbX-vSFBpcTvX9l064obQ_Ai2DVHZf';

  // Table names
  static const String usersTable = 'users';
  static const String servicesTable = 'services';
  static const String bookingsTable = 'bookings';
  static const String categoriesTable = 'categories';

  // Storage buckets
  static const String servicesBucket = 'services';
  static const String profilesBucket = 'profiles';

  // User roles
  static const String roleCustomer = 'customer';
  static const String roleServiceProvider = 'service_provider';
}
