import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import 'profile_provider.dart';

final reviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, targetId) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.getReviewsForTarget(targetId);
});
