import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/profile.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/pill.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: AppRadius.xlAll,
        boxShadow: t.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.badge_rounded, color: t.actionText),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: Text(
                  'Profil',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Pill(
                isLoggedIn ? 'Sudah login' : 'Tamu',
                icon: isLoggedIn
                    ? Icons.verified_user_rounded
                    : Icons.visibility_rounded,
                isNeutral: !isLoggedIn,
              ),
            ],
          ),
          const Divider(height: AppSpace.s6),
          const IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: InfoCard(title: 'NPM', content: ownerNpm),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: InfoCard(title: 'Name', content: ownerName),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: InfoCard(title: 'Class', content: ownerClass),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({required this.title, required this.content, super.key});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: text.labelSmall?.copyWith(color: t.textSubtle),
          ),
          const SizedBox(height: AppSpace.s1),
          Text(
            content,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall,
          ),
        ],
      ),
    );
  }
}
