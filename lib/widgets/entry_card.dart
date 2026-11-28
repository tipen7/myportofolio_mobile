import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/net_image.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({
    required this.imageUrl,
    required this.icon,
    required this.title,
    required this.caption,
    required this.description,
    required this.onTap,
    this.badges = const [],
    super.key,
  });

  final String imageUrl;
  final IconData icon;
  final String title;
  final String caption;
  final String description;
  final List<Widget> badges;
  final VoidCallback onTap;

  static const double _imageSize = 88;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppRadius.lgAll,
                child: NetImage(
                  url: imageUrl,
                  icon: icon,
                  width: _imageSize,
                  height: _imageSize,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: AppSpace.s1),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: t.actionText),
                    ),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: t.textMuted),
                    ),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.s2),
                      Wrap(
                        spacing: AppSpace.s1,
                        runSpacing: AppSpace.s1,
                        children: badges,
                      ),
                    ],
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
