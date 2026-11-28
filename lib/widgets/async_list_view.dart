import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/page_body.dart';
import 'package:myportofolio_mobile/widgets/skeleton.dart';

class AsyncListView<T> extends StatelessWidget {
  const AsyncListView({
    required this.future,
    required this.onRefresh,
    required this.itemBuilder,
    required this.errorMessage,
    required this.emptyMessage,
    this.filter,
    super.key,
  });

  final Future<List<T>> future;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String errorMessage;
  final String emptyMessage;

  final bool Function(T item)? filter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const PageBody(child: Skeleton());
        }

        final Widget child;
        final all = snapshot.data ?? <T>[];
        final items = filter == null ? all : all.where(filter!).toList();
        if (snapshot.hasError) {
          child = _ScrollableMessage(
            icon: Icons.cloud_off_rounded,
            message: '$errorMessage\n${describeError(snapshot.error!)}',
            action: FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          );
        } else if (items.isEmpty) {
          child = _ScrollableMessage(
            icon: all.isEmpty ? Icons.inbox_rounded : Icons.search_off_rounded,
            message: all.isEmpty ? emptyMessage : 'Tidak ada yang cocok.',
          );
        } else {
          child = PageBody(
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s4,
                AppSpace.s4,
                AppSpace.s4,
                AppSpace.s16 + AppSpace.s6,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s3),
              itemBuilder: (context, index) =>
                  itemBuilder(context, items[index]),
            ),
          );
        }

        return RefreshIndicator(onRefresh: onRefresh, child: child);
      },
    );
  }
}

class _ScrollableMessage extends StatelessWidget {
  const _ScrollableMessage({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            minWidth: constraints.maxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: AppSpace.s10,
                  backgroundColor: t.actionSoft,
                  child: Icon(icon, size: AppSpace.s10, color: t.actionText),
                ),
                const SizedBox(height: AppSpace.s4),
                Text(message, textAlign: TextAlign.center),
                if (action != null) ...[
                  const SizedBox(height: AppSpace.s4),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
