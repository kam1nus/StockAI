import 'package:photo_manager/photo_manager.dart';

class LocalPhotoFilterResult {
  final AssetEntity asset;
  final bool accepted;
  final int score;
  final List<String> reasons;

  const LocalPhotoFilterResult({
    required this.asset,
    required this.accepted,
    required this.score,
    required this.reasons,
  });
}

class PhotoFilterService {
  static Future<LocalPhotoFilterResult> analyze(
    AssetEntity asset,
  ) async {
    int score = 100;
    final reasons = <String>[];

    final width = asset.width;
    final height = asset.height;

    // Разрешение в мегапикселях
    final megapixels = (width * height) / 1000000;

    if (megapixels < 4) {
      score -= 55;
      reasons.add('Слишком низкое разрешение');
    } else if (megapixels < 8) {
      score -= 12;
      reasons.add('Невысокое разрешение');
    }

    // Проверяем короткую сторону
    final shortSide = width < height ? width : height;

    if (shortSide < 1500) {
      score -= 30;
      reasons.add('Слишком маленькая сторона изображения');
    }

    // Проверяем необычное соотношение сторон
    if (width > 0 && height > 0) {
      final ratio = width / height;

      if (ratio > 4 || ratio < 0.25) {
        score -= 25;
        reasons.add('Необычное соотношение сторон');
      }
    }

    score = score.clamp(0, 100);

    final accepted = score >= 60;

    if (accepted && reasons.isEmpty) {
      reasons.add('Подходит для следующего этапа');
    }

    return LocalPhotoFilterResult(
      asset: asset,
      accepted: accepted,
      score: score,
      reasons: reasons,
    );
  }

  static Future<List<LocalPhotoFilterResult>> analyzeBatch(
    List<AssetEntity> assets,
  ) async {
    final results = <LocalPhotoFilterResult>[];

    for (final asset in assets) {
      final result = await analyze(asset);
      results.add(result);
    }

    return results;
  }
}