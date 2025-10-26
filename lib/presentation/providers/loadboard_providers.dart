import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/load_models.dart';
import '../../data/repositories/load_repository.dart';
import 'app_providers.dart';

final loadRepositoryProvider = Provider<LoadRepository>((ref) => LoadRepository());

/// Loads assigned to the current driver
final driverLoadsProvider = FutureProvider<List<Load>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(loadRepositoryProvider);
  return repo.getLoadsForDriver(user.id);
});