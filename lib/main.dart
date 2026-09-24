import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'services/ai_service.dart';

import 'package:photo_manager/photo_manager.dart';
import 'services/photo_library_service.dart';
import 'services/photo_filter_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'screens/auth_gate.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.hasSupabaseConfiguration) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }

runApp(const StockAIApp());
}

class StockAIApp extends StatelessWidget {
  const StockAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StockAI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(home: HomeScreen()),
    );
  }
}
// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'StockAI',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 46),

              const Text(
                'Преврати свои фото\nв доход.',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'AI найдёт лучшие фотографии в твоей галерее, '
                'оценит их потенциал и подготовит для фотостоков.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 34),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PhotoPickerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text(
                    'Выбрать фотографии',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF14171D),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Что делает StockAI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16),

                    HomeFeature(
                      icon: Icons.visibility_outlined,
                      text: 'Понимает, что изображено на фото',
                    ),
                    HomeFeature(
                      icon: Icons.person_outline,
                      text: 'Находит людей, лица, логотипы и текст',
                    ),
                    HomeFeature(
                      icon: Icons.analytics_outlined,
                      text: 'Оценивает коммерческий потенциал',
                    ),
                    HomeFeature(
                      icon: Icons.sell_outlined,
                      text: 'Готовит title, description и keywords',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Text(
                    'StockAI MVP v0.3',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PHOTO PICKER SCREEN
// ============================================================

class PhotoPickerScreen extends StatefulWidget {
  const PhotoPickerScreen({super.key});

  @override
  State<PhotoPickerScreen> createState() => _PhotoPickerScreenState();
}

class _PhotoPickerScreenState extends State<PhotoPickerScreen> {
  final ImagePicker _picker = ImagePicker();

  List<XFile> _photos = [];
  bool _loading = false;

  Future<void> _pickPhotos() async {
    try {
      setState(() {
        _loading = true;
      });

      final selected = await _picker.pickMultiImage(
        imageQuality: 90,
      );

      if (!mounted) return;

      setState(() {
        _photos = selected;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка выбора фото: $e'),
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _photos.clear();
    });
  }

  void _goToFilters() {
    if (_photos.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          photos: _photos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  title: const Text('Фотографии'),
  actions: [
    if (_photos.isNotEmpty)
      IconButton(
        tooltip: 'Очистить',
        onPressed: _clearAll,
        icon: const Icon(Icons.delete_outline),
      ),
    IconButton(
      tooltip: 'Профиль',
      icon: const Icon(Icons.person_outline),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
      },
    ),
  ],
),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // AUTO SCAN
SizedBox(
  width: double.infinity,
  height: 58,
  child: FilledButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AutoScanScreen(),
        ),
      );
    },
    icon: const Icon(Icons.auto_awesome),
    label: const Text(
      'Сканировать галерею с AI',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF6C63FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
    ),
  ),
),

const SizedBox(height: 12),

// MANUAL PHOTO PICKER
SizedBox(
  width: double.infinity,
  height: 58,
  child: OutlinedButton.icon(
    onPressed: _loading ? null : _pickPhotos,
    icon: const Icon(Icons.photo_library_outlined),
    label: const Text(
      'Выбрать фотографии вручную',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.15),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
    ),
  ),
),

const SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    'Выбрано: ${_photos.length}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _photos.isEmpty
                    ? const EmptyPhotosView()
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          return PhotoTile(
                            photo: _photos[index],
                            onRemove: () => _removePhoto(index),
                          );
                        },
                      ),
              ),

              if (_photos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    bottom: 10,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: FilledButton.icon(
                      onPressed: _goToFilters,
                      icon: const Icon(Icons.tune),
                      label: const Text(
                        'Настроить анализ',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FILTER SCREEN
// ============================================================

class AutoScanScreen extends StatefulWidget {
  const AutoScanScreen({super.key});

  @override
  State<AutoScanScreen> createState() => _AutoScanScreenState();
}

class _AutoScanScreenState extends State<AutoScanScreen> {
  bool loading = true;
  bool permissionDenied = false;
  bool scanFinished = false;

  int totalPhotos = 0;
  int processedPhotos = 0;
  int acceptedPhotos = 0;
  int rejectedPhotos = 0;

  final List<LocalPhotoFilterResult> candidates = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    final hasPermission =
        await PhotoLibraryService.requestPermission();

    if (!mounted) return;

    if (!hasPermission) {
      setState(() {
        loading = false;
        permissionDenied = true;
      });
      return;
    }

    final count =
        await PhotoLibraryService.getPhotoCount();

    if (!mounted) return;

    setState(() {
      totalPhotos = count;
      processedPhotos = 0;
      acceptedPhotos = 0;
      rejectedPhotos = 0;
      candidates.clear();
      loading = true;
      scanFinished = false;
    });

    const batchSize = 100;
    int page = 0;

    while (processedPhotos < totalPhotos) {
      final batch =
          await PhotoLibraryService.getPhotos(
        page: page,
        pageSize: batchSize,
      );

      if (batch.isEmpty) {
        break;
      }

      final results =
          await PhotoFilterService.analyzeBatch(
        batch,
      );

      for (final result in results) {
        if (result.accepted) {
          candidates.add(result);
          acceptedPhotos++;
        } else {
          rejectedPhotos++;
        }
      }

      processedPhotos += batch.length;
      page++;

      if (!mounted) return;

      setState(() {});

      // Даём UI обновить прогресс.
      await Future.delayed(
        const Duration(milliseconds: 10),
      );
    }

    if (!mounted) return;

    setState(() {
      loading = false;
      scanFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (permissionDenied) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0D10),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Auto Scan'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Color(0xFF8D85FF),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Нет доступа к галерее',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Разреши StockAI доступ к фотографиям '
                  'в настройках iPhone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (loading) {
      final progress = totalPhotos == 0
          ? 0.0
          : processedPhotos / totalPhotos;

      return Scaffold(
         backgroundColor: const Color(0xFF0B0D10),
         appBar: AppBar(
            backgroundColor: Colors.transparent,
           title: const Text('Auto Scan'),
      ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: Color(0xFF8D85FF),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Сканируем всю галерею',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  totalPhotos == 0
                      ? 'Получаем список фотографий...'
                      : '$processedPhotos из $totalPhotos',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: _AutoScanStat(
                        icon: Icons.check_circle_outline,
                        title: 'Кандидаты',
                        value: acceptedPhotos.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AutoScanStat(
                        icon: Icons.filter_alt_off_outlined,
                        title: 'Отсеяно',
                        value: rejectedPhotos.toString(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14171D),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.savings_outlined,
                        size: 20,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'API сейчас не используется — '
                          'локальный этап стоит \$0.00',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Результат сканирования'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '$totalPhotos фото просканировано',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'StockAI локально отобрал '
              '$acceptedPhotos кандидатов и '
              'отсеял $rejectedPhotos фото.',
              style: TextStyle(
                height: 1.4,
                color: Colors.white.withValues(
                  alpha: 0.55,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _AutoScanStat(
                    icon: Icons.check_circle_outline,
                    title: 'Кандидаты',
                    value: acceptedPhotos.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AutoScanStat(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'Отсеяно',
                    value: rejectedPhotos.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Кандидаты',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: candidates.isEmpty
                  ? Center(
                      child: Text(
                        'Подходящих кандидатов пока нет',
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final candidate =
                            candidates[index];

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            LibraryPhotoTile(
                              asset: candidate.asset,
                            ),

                            Positioned(
                              left: 5,
                              bottom: 5,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(
                                    alpha: 0.72,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${candidate.score}/100',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: candidates.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              '${candidates.length} кандидатов '
                              'готовы к AI screening',
                            ),
                          ),
                        );
                      },
                icon: const Icon(
                  Icons.auto_awesome,
                ),
                label: Text(
                  'AI screening: ${candidates.length} фото',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoScanStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AutoScanStat({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14171D),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF8D85FF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class LibraryPhotoTile extends StatelessWidget {
  final AssetEntity asset;

  const LibraryPhotoTile({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: FutureBuilder<List<int>?>(
        future: PhotoLibraryService.getThumbnail(
          asset,
          width: 400,
          height: 400,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: const Color(0xFF171A21),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          }

          return Image.memory(
            Uint8List.fromList(
              snapshot.data!,
            ),
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
class LocalFilterResultsScreen extends StatelessWidget {
  final List<LocalPhotoFilterResult> results;
  final int acceptedCount;
  final int rejectedCount;

  const LocalFilterResultsScreen({
    super.key,
    required this.results,
    required this.acceptedCount,
    required this.rejectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Локальный отбор'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF14171D),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Результат бесплатного фильтра',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterStat(
                          title: 'Подходят',
                          value: acceptedCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterStat(
                          title: 'Отсеяно',
                          value: rejectedCount.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'На этом этапе AI API не используется.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return LocalFilterCard(
                  result: results[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterStat extends StatelessWidget {
  final String title;
  final String value;

  const _FilterStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0D10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class LocalFilterCard extends StatelessWidget {
  final LocalPhotoFilterResult result;

  const LocalFilterCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF14171D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            height: 85,
            child: LibraryPhotoTile(
              asset: result.asset,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      result.accepted
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: result.accepted
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      size: 19,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${result.score}/100',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.asset.width} × ${result.asset.height}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.reasons.join(' • '),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class FilterScreen extends StatefulWidget {
  final List<XFile> photos;

  const FilterScreen({
    super.key,
    required this.photos,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool noPeople = false;
  bool noLogos = true;
  bool commercialOnly = true;
  double minScore = 70;

  Future<void> _startMockAnalysis() async {
  if (widget.photos.isEmpty) return;

  // Показываем загрузку
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(
              child: Text('StockAI анализирует фотографию...'),
            ),
          ],
        ),
      );
    },
  );

  try {
    // Отправляем первое выбранное фото на backend
    final result = await AIService.analyzePhoto(
      widget.photos.first,
    );

    if (!mounted) return;

    // Закрываем окно загрузки
    Navigator.pop(context);

    final technical =
        result['technical'] as Map<String, dynamic>;

    final metadata =
        result['metadata'] as Map<String, dynamic>;

    final detections =
        result['detections'] as Map<String, dynamic>;

    // Показываем результат backend
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Результат StockAI'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Сцена: ${result['scene']}'),
                const SizedBox(height: 8),

                Text('Категория: ${result['category']}'),
                const SizedBox(height: 8),

                Text('Stock Score: ${result['score']}/100'),

                const SizedBox(height: 16),

                Text(
                  'Размер: ${technical['width']} × ${technical['height']}',
                ),

                const SizedBox(height: 16),

                Text('Люди: ${detections['people']}'),
                Text('Логотипы: ${detections['logos']}'),
                Text('Текст: ${detections['text']}'),

                const SizedBox(height: 20),

                const Text(
                  'Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(metadata['title'].toString()),

                const SizedBox(height: 16),

                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(metadata['description'].toString()),

                const SizedBox(height: 16),

                const Text(
                  'Keywords',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  (metadata['keywords'] as List).join(', '),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Готово'),
            ),
          ],
        );
      },
    );
  } catch (error) {
    if (!mounted) return;

    // Закрываем загрузку
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ошибка backend: $error'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Настройки анализа'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Фильтры',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Выбери, какие фотографии StockAI должен искать.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),

          const SizedBox(height: 28),

          SwitchListTile(
            value: noPeople,
            onChanged: (value) {
              setState(() {
                noPeople = value;
              });
            },
            title: const Text('Без людей'),
            subtitle: const Text(
              'Исключить фотографии с людьми',
            ),
          ),

          SwitchListTile(
            value: noLogos,
            onChanged: (value) {
              setState(() {
                noLogos = value;
              });
            },
            title: const Text('Без логотипов'),
            subtitle: const Text(
              'Исключить потенциальные бренды',
            ),
          ),

          SwitchListTile(
            value: commercialOnly,
            onChanged: (value) {
              setState(() {
                commercialOnly = value;
              });
            },
            title: const Text('Только Commercial'),
            subtitle: const Text(
              'Не показывать editorial-кандидатов',
            ),
          ),

          const SizedBox(height: 25),

          Text(
            'Минимальный Stock Score: ${minScore.round()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          Slider(
            value: minScore,
            min: 0,
            max: 100,
            divisions: 20,
            label: minScore.round().toString(),
            onChanged: (value) {
              setState(() {
                minScore = value;
              });
            },
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _startMockAnalysis,
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                'Анализировать ${widget.photos.length} фото',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MOCK ANALYSIS
// ============================================================

class MockAnalysisScreen extends StatefulWidget {
  final List<XFile> photos;
  final double minScore;
  final bool noPeople;
  final bool noLogos;
  final bool commercialOnly;

  const MockAnalysisScreen({
    super.key,
    required this.photos,
    required this.minScore,
    required this.noPeople,
    required this.noLogos,
    required this.commercialOnly,
  });

  @override
  State<MockAnalysisScreen> createState() =>
      _MockAnalysisScreenState();
}

class _MockAnalysisScreenState extends State<MockAnalysisScreen> {
  int processed = 0;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    for (int i = 0; i < widget.photos.length; i++) {
      await Future.delayed(
        const Duration(milliseconds: 450),
      );

      if (!mounted) return;

      setState(() {
        processed++;
      });
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          photos: widget.photos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.photos.isEmpty
        ? 0.0
        : processed / widget.photos.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 64,
                color: Color(0xFF8D85FF),
              ),

              const SizedBox(height: 25),

              const Text(
                'Анализируем фотографии',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '$processed / ${widget.photos.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 28),

              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
              ),

              const SizedBox(height: 25),

              Text(
                processed < widget.photos.length / 3
                    ? 'Проверяем качество...'
                    : processed < widget.photos.length * 0.7
                        ? 'Определяем содержимое...'
                        : 'Оцениваем stock potential...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// RESULTS
// ============================================================

class ResultsScreen extends StatelessWidget {
  final List<XFile> photos;

  const ResultsScreen({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Результаты'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final score = 76 + ((index * 7) % 21);

          return ResultCard(
            photo: photos[index],
            score: score,
            title: index.isEven
                ? 'Natural landscape suitable for stock'
                : 'Authentic lifestyle photography',
          );
        },
      ),
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class HomeFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const HomeFeature({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.white.withValues(alpha: 0.55),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

class PhotoTile extends StatelessWidget {
  final XFile photo;
  final VoidCallback onRemove;

  const PhotoTile({
    super.key,
    required this.photo,
    required this.onRemove,
  });

  Future<Uint8List> _load() {
    return photo.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FutureBuilder<Uint8List>(
            future: _load(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  color: const Color(0xFF171A21),
                );
              }

              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ResultCard extends StatelessWidget {
  final XFile photo;
  final int score;
  final String title;

  const ResultCard({
    super.key,
    required this.photo,
    required this.score,
    required this.title,
  });

  Future<Uint8List> _load() {
    return photo.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF14171D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: FutureBuilder<Uint8List>(
              future: _load(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 230,
                  );
                }

                return Image.memory(
                  snapshot.data!,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '$score/100',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const Spacer(),

                    const Text(
                      'Commercial',
                      style: TextStyle(
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'nature • landscape • travel • outdoors • stock',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyPhotosView extends StatelessWidget {
  const EmptyPhotosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Фотографии пока не выбраны',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
