import 'package:photo_manager/photo_manager.dart';

class PhotoLibraryService {
  /// Запрашивает доступ к фотогалерее.
  static Future<bool> requestPermission() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    return permission.isAuth;
  }

  /// Возвращает количество фотографий в основной библиотеке.
  static Future<int> getPhotoCount() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      return 0;
    }

    return albums.first.assetCountAsync;
  }

  /// Получает фотографии партиями.
  ///
  /// Например:
  /// page = 0, pageSize = 50
  /// вернёт первые 50 фотографий.
  static Future<List<AssetEntity>> getPhotos({
    int page = 0,
    int pageSize = 50,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      return [];
    }

    final recentAlbum = albums.first;

    final start = page * pageSize;
    final end = start + pageSize;

    return recentAlbum.getAssetListRange(
      start: start,
      end: end,
    );
  }

  /// Получает thumbnail.
  ///
  /// Используем маленькое изображение для предварительного просмотра,
  /// чтобы не загружать оригиналы 20–50 МП в память.
  static Future<List<int>?> getThumbnail(
    AssetEntity asset, {
    int width = 500,
    int height = 500,
  }) async {
    final data = await asset.thumbnailDataWithSize(
      ThumbnailSize(
        width,
        height,
      ),
      quality: 80,
    );

    return data;
  }

  /// Получаем оригинальный файл только тогда,
  /// когда он действительно понадобится.
  static Future<String?> getOriginalFilePath(
    AssetEntity asset,
  ) async {
    final file = await asset.originFile;

    return file?.path;
  }
}