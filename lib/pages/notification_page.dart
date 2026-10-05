import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/model/notification_model.dart';
import 'package:hotmul_quran/repositories/notication_repo.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/hafalan_widgets.dart';

/// Daftar pengingat harian, H-2 deadline, dan status terlambat yang dibuat
/// `NotificationService` di hotmul_api (BRD 4.4).
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationRepo().getAll();
  }

  Future<void> _reload() async {
    setState(() => _future = NotificationRepo().getAll());
    await _future;
  }

  ({IconData icon, Color color}) _style(AppNotification n) {
    final t = n.title.toLowerCase();
    if (n.type == 'done') {
      return (icon: Icons.check_circle, color: ThemeConfig.onTrack);
    }
    if (n.type == 'warning' || t.contains('terlambat')) {
      return (icon: Icons.error, color: ThemeConfig.late);
    }
    if (t.contains('deadline')) {
      return (icon: Icons.alarm, color: ThemeConfig.warning);
    }
    return (icon: Icons.notifications, color: ThemeConfig.primaryDark);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy, HH:mm');
    return Scaffold(
      appBar: AppBarCustom(title: 'Notifikasi'),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<AppNotification>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  EmptyState(
                    icon: Icons.cloud_off,
                    message: snap.error.toString(),
                    onRetry: _reload,
                  ),
                ],
              );
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  EmptyState(
                    icon: Icons.notifications_none,
                    message: 'Belum ada notifikasi',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = items[i];
                final st = _style(n);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: st.color.withValues(alpha: 0.12),
                      child: Icon(st.icon, color: st.color),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      n.createdAt == null
                          ? n.message
                          : '${n.message}\n${fmt.format(n.createdAt!.toLocal())}',
                    ),
                    isThreeLine: n.createdAt != null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
