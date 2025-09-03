import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/domain/entity/lesson_entity.dart';

class PairTimerScreen extends StatefulWidget {
  final List<LessonEntity> schedule;

  const PairTimerScreen({super.key, required this.schedule});

  @override
  State<PairTimerScreen> createState() => _PairTimerScreenState();
}

class _PairTimerScreenState extends State<PairTimerScreen> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;
  String _status = 'Определение текущего состояния...';
  LessonEntity? _currentPair;
  LessonEntity? _nextPair;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimer());
    _updateTimer();
  }

  void _updateTimer() {
    final now = DateTime.now();
    final nowInSeconds = now.hour * 3600 + now.minute * 60 + now.second;

    LessonEntity? current, next;

    for (var pair in widget.schedule) {
      final startInSeconds =
          pair.startTime.hour * 3600 + pair.startTime.minute * 60;
      final endInSeconds = pair.endTime.hour * 3600 + pair.endTime.minute * 60;

      if (nowInSeconds >= startInSeconds && nowInSeconds < endInSeconds) {
        current = pair;
      } else if (nowInSeconds < startInSeconds && next == null) {
        next = pair;
      }
    }

    setState(() {
      _currentPair = current;
      _nextPair = next;

      if (current != null) {
        final endInSeconds =
            current.endTime.hour * 3600 + current.endTime.minute * 60;
        _remainingTime = Duration(seconds: endInSeconds - nowInSeconds);
        _status = 'Идёт пара:';
      } else if (next != null) {
        final startInSeconds =
            next.startTime.hour * 3600 + next.startTime.minute * 60;
        _remainingTime = Duration(seconds: startInSeconds - nowInSeconds);
        _status = 'До начала пары:';
      } else {
        _remainingTime = Duration.zero;
        _status = 'Пар больше нет';
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  double _calculateProgress() {
    if (_currentPair != null) {
      final totalDuration = Duration(
        hours: _currentPair!.endTime.hour - _currentPair!.startTime.hour,
        minutes: _currentPair!.endTime.minute - _currentPair!.startTime.minute,
      );
      return 1 - (_remainingTime.inSeconds / totalDuration.inSeconds);
    } else if (_nextPair != null) {
      // Для времени между парами - пустой прогресс
      return 0;
    }
    return 0;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Таймер пар'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Информация о текущей/следующей паре
              if (_currentPair != null) ...[
                Text(
                  _status,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentPair!.name ?? 'Без названия',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '${_currentPair!.startTime.format(context)} - ${_currentPair!.endTime.format(context)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ] else if (_nextPair != null) ...[
                Text(
                  _status,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _nextPair!.name ?? 'Без названия',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Начнётся в ${_nextPair!.startTime.format(context)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Круговой индикатор прогресса
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: _currentPair != null ? _calculateProgress() : 0,
                      strokeWidth: 12,
                      backgroundColor: isDark
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(_remainingTime),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (_currentPair != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${(_calculateProgress() * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Дополнительная информация
              if (_currentPair != null) ...[
                _buildInfoRow('Аудитория',
                    _currentPair!.classroom ?? 'Не указана', context),
                _buildInfoRow(
                    'Корпус', _currentPair!.territory ?? 'Не указан', context),
                if (_currentPair!.subgroup > 0)
                  _buildInfoRow(
                      'Подгруппа', _currentPair!.subgroup.toString(), context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
