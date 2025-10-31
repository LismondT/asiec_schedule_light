import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestIdDialog extends StatefulWidget {
  final Map<String, String> ids;

  const RequestIdDialog({super.key, required this.ids});

  @override
  State<RequestIdDialog> createState() => _RequestIdDialogState();
}

class _RequestIdDialogState extends State<RequestIdDialog> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, double> _sectionPositions = {};
  String _currentSection = '';
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSectionPositions();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Вычисляем позиции всех секций
  void _calculateSectionPositions() {
    final groupedItems = _groupItemsByFirstChar(widget.ids);
    final sectionChars = groupedItems.keys.toList()..sort(_sortSections);

    double position = 0;

    for (final char in sectionChars) {
      _sectionPositions[char] = position;

      // Вычисляем высоту секции: заголовок + все элементы
      final sectionItems = groupedItems[char]!;
      final headerHeight = 48.0; // Высота заголовка
      final itemHeight = 48.0; // Высота одного элемента
      final sectionHeight = headerHeight + (sectionItems.length * itemHeight);

      position += sectionHeight;
    }
  }

  void _scrollToSection(String sectionChar) {
    final position = _sectionPositions[sectionChar];
    if (position != null) {
      setState(() {
        _currentSection = sectionChar;
        _isScrolling = true;
      });

      _scrollController
          .animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        // Сбрасываем флаг скроллинга после завершения анимации
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _isScrolling = false;
            });
          }
        });
      });
    }
  }

  // Группировка элементов по КАЖДОМУ уникальному первому символу
  Map<String, List<MapEntry<String, String>>> _groupItemsByFirstChar(
      Map<String, String> items) {
    final Map<String, List<MapEntry<String, String>>> grouped = {};

    final sortedEntries = items.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sortedEntries) {
      String firstChar =
          entry.key.isNotEmpty ? entry.key[0].toUpperCase() : '#';
      grouped.putIfAbsent(firstChar, () => []).add(entry);
    }

    return grouped;
  }

  // Сортировка секций
  int _sortSections(String a, String b) {
    final bool aIsDigit = a.compareTo('0') >= 0 && a.compareTo('9') <= 0;
    final bool bIsDigit = b.compareTo('0') >= 0 && b.compareTo('9') <= 0;
    final bool aIsLetter = a.compareTo('A') >= 0 && a.compareTo('Z') <= 0;
    final bool bIsLetter = b.compareTo('A') >= 0 && b.compareTo('Z') <= 0;

    if (aIsDigit && !bIsDigit) return -1;
    if (!aIsDigit && bIsDigit) return 1;
    if (aIsDigit && bIsDigit) return a.compareTo(b);

    if (aIsLetter && !bIsLetter) return -1;
    if (!aIsLetter && bIsLetter) return 1;
    if (aIsLetter && bIsLetter) return a.compareTo(b);

    return a.compareTo(b);
  }

  void _handleIdSelection(BuildContext context, String id) {
    final settingsCubit = context.read<SettingsCubit>();
    final scheduleCubit = context.read<ScheduleCubit>();

    Navigator.of(context).pop();

    Future.microtask(() async {
      await settingsCubit.changeRequestId(id);
      await scheduleCubit.loadDefaultSchedule();
    });
  }

  // Определяем видимую секцию при скролле
  void _onScroll() {
    if (_isScrolling) return; // Не обновляем во время программного скролла

    final scrollPosition = _scrollController.offset;
    final groupedItems = _groupItemsByFirstChar(widget.ids);
    final sectionChars = groupedItems.keys.toList()..sort(_sortSections);

    String? newCurrentSection;

    // Ищем секцию, которая сейчас вверху
    for (final char in sectionChars.reversed) {
      final position = _sectionPositions[char];
      if (position != null && position <= scrollPosition + 50) {
        newCurrentSection = char;
        break;
      }
    }

    if (newCurrentSection != null && newCurrentSection != _currentSection) {
      setState(() {
        _currentSection = newCurrentSection!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByFirstChar(widget.ids);
    final sectionChars = groupedItems.keys.toList()..sort(_sortSections);

    // Добавляем слушатель скролла
    _scrollController.addListener(_onScroll);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Выберите предмет',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500, minHeight: 300),
              child: Row(
                children: [
                  // Основной список с секциями
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: sectionChars.length,
                      itemBuilder: (context, sectionIndex) {
                        final sectionChar = sectionChars[sectionIndex];
                        final sectionItems = groupedItems[sectionChar]!;

                        return Column(
                          key: Key('section_$sectionChar'),
                          // Используем Key вместо GlobalKey
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок секции
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant
                                    .withOpacity(0.5),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.3),
                                  ),
                                ),
                              ),
                              child: Text(
                                sectionChar,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            // Элементы секции
                            ...sectionItems.map((item) => ListTile(
                                  title: Text(
                                    item.key,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  visualDensity:
                                      const VisualDensity(vertical: -2),
                                  onTap: () =>
                                      _handleIdSelection(context, item.value),
                                )),
                          ],
                        );
                      },
                    ),
                  ),

                  // алфавитный индекс
                  Container(
                    width: 36,
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: sectionChars.length,
                            itemBuilder: (context, index) {
                              final char = sectionChars[index];
                              final isActive = _currentSection == char;

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _scrollToSection(char),
                                child: Container(
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: isActive ? 13 : 11,
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isActive
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                    ),
                                    child: Text(char),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрыть'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
