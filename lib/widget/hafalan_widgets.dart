import 'package:flutter/material.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/core/hafalan_rules.dart';

Color colorForLevel(ProgressLevel level) {
  switch (level) {
    case ProgressLevel.onTrack:
      return ThemeConfig.onTrack;
    case ProgressLevel.warning:
      return ThemeConfig.warning;
    case ProgressLevel.late:
      return ThemeConfig.late;
  }
}

String labelForLevel(ProgressLevel level) {
  switch (level) {
    case ProgressLevel.onTrack:
      return 'On-Track';
    case ProgressLevel.warning:
      return 'Perlu Dikejar';
    case ProgressLevel.late:
      return 'Terlambat';
  }
}

/// Label & warna status assignment dari API (`active`, `done`, `late`).
({String label, Color color}) assignmentStatusStyle(String? status) {
  switch (status) {
    case 'done':
      return (label: 'Selesai', color: ThemeConfig.onTrack);
    case 'late':
      return (label: 'Terlambat', color: ThemeConfig.late);
    case 'active':
      return (label: 'Berjalan', color: ThemeConfig.warning);
    default:
      return (label: 'Belum ada juz', color: ThemeConfig.neutral);
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Progress bar berlabel, dipakai di beranda anggota & monitoring admin.
class LabeledProgress extends StatelessWidget {
  final double value;
  final Color color;
  final String? caption;

  const LabeledProgress({
    super.key,
    required this.value,
    required this.color,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 6),
          Text(caption!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

/// Tampilan kosong / error dengan tombol coba lagi.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: ThemeConfig.neutral),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
