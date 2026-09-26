
import 'package:flutter/material.dart';

import '../data/sync/sync_manager.dart';

class SyncStatusIndicator
    extends StatelessWidget {
  const SyncStatusIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SyncManager.instance,
      builder: (_, __) {
        final status =
            SyncManager.instance.status;

        IconData icon;
        String label;

        switch (status.state) {
          case SyncState.syncing:
            icon = Icons.sync;
            label = 'Syncing…';
            break;

          case SyncState.offline:
            icon = Icons.cloud_off_outlined;
            label = status.pendingItems > 0
                ? '${status.pendingItems} waiting to sync'
                : 'Offline';
            break;

          case SyncState.error:
            icon = Icons.sync_problem_outlined;
            label = 'Sync needs attention';
            break;

          case SyncState.idle:
            icon = Icons.cloud_done_outlined;
            label = 'Data synced';
            break;
        }

        return Tooltip(
          message: label,
          child: Icon(
            icon,
            size: 22,
          ),
        );
      },
    );
  }
}
