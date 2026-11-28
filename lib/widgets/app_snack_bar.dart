import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.tokens.dangerStrong : null,
      ),
    );
}
