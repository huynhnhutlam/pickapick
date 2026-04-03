import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton accessor for the Supabase client.
///
/// Use `supabase.from(...)` to query tables directly.
final SupabaseClient supabase = Supabase.instance.client;

/// Helper: current authenticated user.
///
/// Returns `null` if the user is not authenticated.
final currentUser = supabase.auth.currentUser;
