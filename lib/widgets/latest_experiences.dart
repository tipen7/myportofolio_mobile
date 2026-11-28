import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/net_image.dart';
import 'package:myportofolio_mobile/widgets/pill.dart';
import 'package:myportofolio_mobile/widgets/skeleton.dart';

class LatestExperiences extends StatelessWidget {
  const LatestExperiences({
    required this.future,
    required this.onTap,
    required this.onRetry,
    super.key,
  });

  final Future<List<Experience>> future;
  final ValueChanged<Experience> onTap;
  final VoidCallback onRetry;

  static const int _limit = 5;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Experience>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_off_rounded),
              title: const Text('Pengalaman belum bisa dimuat.'),
              trailing: TextButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ),
          );
        }
        final items = snapshot.data;
        if (items == null) return const Skeleton(count: 1);
        if (items.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.inbox_rounded),
              title: Text('Belum ada pengalaman untuk ditampilkan.'),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpace.s3,
            children: [
              for (final item in items.take(_limit))
                _FeedCard(experience: item, onTap: () => onTap(item)),
            ],
          ),
        );
      },
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.experience, required this.onTap});

  final Experience experience;
  final VoidCallback onTap;

  static const double _width = 232;
  static const double _imageHeight = 120;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NetImage(
                url: experience.thumbnail,
                icon: Icons.work_rounded,
                height: _imageHeight,
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpace.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpace.s2),
                    Pill(experience.category.label),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
