import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/plots_provider.dart';
import '../models/plot.dart';

/// Главный экран со списком участков (перенос app/index.tsx).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  int _totalApartments(List<Entrance> entrances) => entrances.fold(
      0, (sum, e) => sum + e.floors.fold(0, (s, f) => s + f.apartments.length));

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final plots = context.watch<PlotsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои участки'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: auth.loading ? null : () async {
              await auth.signOut();
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
            },
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Выход'),
          ),
        ],
      ),
      body: _buildBody(context, plots),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 16),
        child: FloatingActionButton(
          onPressed: plots.loading ? null : () => Navigator.of(context).pushNamed('/create-plot'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlotsProvider plots) {
    if (plots.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (plots.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка: ${plots.error}',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => plots.clearError(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    final userPlots = plots.plots;
    if (userPlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.home_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Нет участков', style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text('Нажмите + чтобы создать новый',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: userPlots.length,
      itemBuilder: (context, i) {
        final plot = userPlots[i];
        final total = _totalApartments(plot.entrances);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.account_balance, color: Colors.blue),
            title: Text(plot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${plot.entrances.length} подъезд(ов) • $total квартир',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: plots.loading
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Удалить участок'),
                              content: Text('Удалить "${plot.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await plots.deletePlot(plot.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Участок удалён')),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
            onTap: () => Navigator.of(context).pushNamed('/plot', arguments: plot.id),
          ),
        );
      },
    );
  }
}