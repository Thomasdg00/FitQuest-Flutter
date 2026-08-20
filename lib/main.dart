import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/presentation/app/fitquest_app.dart';

export 'src/presentation/app/fitquest_app.dart';

void main() {
  runApp(const ProviderScope(child: FitQuestApp()));
}
