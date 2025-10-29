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
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSectionKeys();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeSectionKeys() {
    final groupedItems = _groupItemsByFirstChar(widget.ids);
    final sectionLetters = groupedItems.keys.toList()..sort(_sortSections);

    for (final letter in sectionLetters) {
      _sectionKeys[letter] = GlobalKey();
    }
  }

  void _scrollToSection(String sectionChar) {
    final key = _sectionKeys[sectionChar];
    if (key != null) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // Группировка элементов по первой букве/цифре
  Map<String, List<MapEntry<String, String>>> _groupItemsByFirstChar(
      Map<String, String> items) {
    final Map<String, List<MapEntry<String, String>>> grouped = {};

    final sortedEntries = items.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sortedEntries) {
      // Получаем первую букву (для английских букв) или первый символ
      String firstChar =
          entry.key.isNotEmpty ? entry.key[0].toUpperCase() : '#';

      // Если это цифра, группируем в секцию "0-9"
      if (firstChar.compareTo('0') >= 0 && firstChar.compareTo('9') <= 0) {
        firstChar = '0-9';
      }
      // Если это не буква и не цифра, группируем в "#"
      else if (firstChar.compareTo('A') < 0 || firstChar.compareTo('Z') > 0) {
        firstChar = '#';
      }

      grouped.putIfAbsent(firstChar, () => []).add(entry);
    }

    return grouped;
  }

  // Сортировка секций (сначала цифры, потом буквы, потом остальное)
  int _sortSections(String a, String b) {
    if (a == '0-9') return -1;
    if (b == '0-9') return 1;
    if (a == '#') return 1;
    if (b == '#') return -1;
    return a.compareTo(b);
  }

  void _showSectionDialog(BuildContext context, String sectionChar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Секция $sectionChar'),
        content: Text(
            'Прокрутите список чтобы найти элементы начинающиеся на "$sectionChar"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByFirstChar(widget.ids);
    final sectionLetters = groupedItems.keys.toList()..sort(_sortSections);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Выберите',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400, minHeight: 200),
              child: Row(
                children: [
                  // Основной список с секциями
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: sectionLetters.length,
                      itemBuilder: (context, sectionIndex) {
                        final sectionChar = sectionLetters[sectionIndex];
                        final sectionItems = groupedItems[sectionChar]!;

                        return Column(
                          key: _sectionKeys[sectionChar],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок секции
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              color: Colors.grey[100],
                              child: Text(
                                sectionChar,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // Элементы секции
                            ...sectionItems.map((item) => ListTile(
                                  title: Text(item.key),
                                  onTap: () =>
                                      _handleIdSelection(context, item.value),
                                )),
                          ],
                        );
                      },
                    ),
                  ),

                  // Алфавитный индекс
                  Container(
                    width: 24,
                    margin: const EdgeInsets.only(right: 8),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sectionLetters.length,
                      itemBuilder: (context, index) {
                        final letter = sectionLetters[index];
                        return GestureDetector(
                          onTap: () => _scrollToSection(letter),
                          child: Container(
                            height: 20,
                            alignment: Alignment.center,
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }
}
