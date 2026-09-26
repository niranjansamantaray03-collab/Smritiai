
enum SyncState {
  idle,
  syncing,
  offline,
  error,
}

class SyncStatus {
  final SyncState state;
  final int pendingItems;
  final DateTime? lastSuccessfulSync;
  final String? errorMessage;

  const SyncStatus({
    required this.state,
    required this.pendingItems,
    this.lastSuccessfulSync,
    this.errorMessage,
  });

  bool get isSyncing =>
      state == SyncState.syncing;

  bool get isOffline =>
      state == SyncState.offline;

  bool get hasError =>
      state == SyncState.error;
}
