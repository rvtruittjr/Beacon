import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/changelog_repository.dart';
import '../models/changelog_entry_model.dart';

final changelogRepositoryProvider = Provider<ChangelogRepository>((ref) {
  return ChangelogRepository();
});

final changelogEntriesProvider =
    FutureProvider.autoDispose<List<ChangelogEntryModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  return ref.watch(changelogRepositoryProvider).getEntries(brandId);
});
