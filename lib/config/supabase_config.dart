class SupabaseConfig {
  // TODO: Replace with your actual Supabase project URL and anonymous key
  // Get these from: https://app.supabase.com/project/_/settings/api

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
