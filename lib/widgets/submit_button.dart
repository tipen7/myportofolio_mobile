import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isSubmitting ? null : onPressed,
      icon: isSubmitting
          ? const SizedBox.square(
              dimension: AppSpace.s4,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save_rounded),
      label: const Text('Simpan'),
    );
  }
}
