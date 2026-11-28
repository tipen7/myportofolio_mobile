import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/chip_selector.dart';
import 'package:myportofolio_mobile/widgets/page_body.dart';

/// Search pill and filter chips above a list. A `null` option means "all".
class FilterHeader<T extends Object> extends StatelessWidget {
  const FilterHeader({
    required this.searchHint,
    required this.onQueryChanged,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.autofocus = false,
    super.key,
  });

  final String searchHint;
  final ValueChanged<String> onQueryChanged;
  final List<T> options;
  final T? selected;
  final String Function(T option) labelOf;
  final ValueChanged<T?> onSelected;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      borderSide: BorderSide(color: t.border),
    );

    return ColoredBox(
      color: t.surface,
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
              child: TextField(
                autofocus: autofocus,
                onChanged: onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  fillColor: t.surface2,
                  isDense: true,
                  border: pill,
                  enabledBorder: pill,
                  focusedBorder: pill.copyWith(
                    borderSide: BorderSide(color: t.action, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.s2),
            ChipSelector<T?>(
              scrollable: true,
              options: [null, ...options],
              selected: selected,
              labelOf: (option) => option == null ? 'Semua' : labelOf(option),
              onSelected: onSelected,
            ),
            const SizedBox(height: AppSpace.s2),
          ],
        ),
      ),
    );
  }
}
