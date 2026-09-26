
import 'local_store.dart';

/// Android production persistence boundary.
///
/// The first production Android implementation can use
/// SharedPreferences/SQLite/another durable store without
/// changing application features.
///
/// This keeps the rest of SmritiAI independent of the
/// storage package.
abstract class DurableStoreAdapter
    implements LocalStore {
  const DurableStoreAdapter();
}
