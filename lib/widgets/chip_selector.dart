import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class ChipSelector<T> extends StatelessWidget {
  const ChipSelector({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.scrollable = false,
    super.key,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final option in options)
        ChoiceChip(
          label: Text(labelOf(option)),
          selected: option == selected,
          onSelected: (_) => onSelected(option),
        ),
    ];

    if (!scrollable) {
      return Wrap(
        spacing: AppSpace.s2,
        runSpacing: AppSpace.s1,
        children: chips,
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      child: Row(spacing: AppSpace.s2, children: chips),
    );
  }
}
