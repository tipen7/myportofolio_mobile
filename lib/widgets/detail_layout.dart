import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/net_image.dart';
import 'package:myportofolio_mobile/widgets/page_body.dart';

class DetailLayout extends StatelessWidget {
  const DetailLayout({
    required this.imageUrl,
    required this.icon,
    required this.title,
    required this.badges,
    required this.sections,
    super.key,
  });

  final String imageUrl;
  final IconData icon;
  final String title;
  final List<Widget> badges;
  final List<Widget> sections;

  static const double _imageHeight = 200;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageBody(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: NetImage(
                      url: imageUrl,
                      icon: icon,
                      height: _imageHeight,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.s4,
                      _imageHeight - AppSpace.s8,
                      AppSpace.s4,
                      0,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpace.s4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpace.s3),
                            Wrap(
                              spacing: AppSpace.s2,
                              runSpacing: AppSpace.s2,
                              children: badges,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpace.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpace.s3,
                  children: sections,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
