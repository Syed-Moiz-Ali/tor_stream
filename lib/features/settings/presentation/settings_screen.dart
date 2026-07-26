import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _storageCap = 10.0;
  bool _deleteAfterWatching = false;
  bool _autoEvict = true;
  bool _resumeAfterReboot = false;

  @override
  void initState() {
    super.initState();
    ref.read(settingsProvider.future).then((s) {
      if (mounted) {
        setState(() {
          _storageCap = s.storageCapGb;
          _deleteAfterWatching = s.deleteAfterWatching;
          _autoEvict = s.autoEvictEnabled;
          _resumeAfterReboot = s.resumeAfterReboot;
        });
      }
    });
  }

  Future<void> _persist() async {
    await SettingsState(
      storageCapGb: _storageCap,
      deleteAfterWatching: _deleteAfterWatching,
      autoEvictEnabled: _autoEvict,
      darkMode: true,
      resumeAfterReboot: _resumeAfterReboot,
    ).persist();
  }

  @override
  Widget build(BuildContext context) {
    final healthAsync = ref.watch(healthStatusProvider);
    final storageAsync = ref.watch(storageReportProvider);

    return Scaffold(
      backgroundColor: TorStreamTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _sectionHeader('ENGINE STATUS'),
          healthAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0, color: TorStreamTheme.seedColor))),
            ),
            error: (e, _) => const _InfoTile(
              title: 'Health Check', value: 'Failed',
              icon: Icons.error_outline_rounded, iconColor: TorStreamTheme.accentRed,
            ),
            data: (health) => Column(
              children: [
                _InfoTile(title: 'Status', value: health?.isHealthy == true ? 'Healthy' : 'Warning',
                  icon: Icons.monitor_heart_rounded,
                  iconColor: health?.isHealthy == true ? TorStreamTheme.accentGreen : TorStreamTheme.accentAmber),
                _InfoTile(title: 'Storage', value: _formatBytes(health?.availableStorageBytes ?? 0),
                  icon: Icons.storage_rounded),
                _InfoTile(title: 'Memory', value: '${health?.availableRamMb ?? 0} MB',
                  icon: Icons.memory_rounded),
                _InfoTile(title: 'Network', value: health?.isNetworkConnected == true ? 'Connected' : 'Disconnected',
                  icon: Icons.wifi_rounded,
                  iconColor: health?.isNetworkConnected == true ? TorStreamTheme.accentGreen : TorStreamTheme.accentRed),
                _InfoTile(title: 'Database', value: health?.isDatabaseOk == true ? 'OK' : 'Corrupted',
                  icon: Icons.dns_rounded,
                  iconColor: health?.isDatabaseOk == true ? TorStreamTheme.accentGreen : TorStreamTheme.accentRed),
                _InfoTile(title: 'Active Torrents', value: '${health?.activeTorrentsCount ?? 0}',
                  icon: Icons.download_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader('STORAGE MANAGEMENT'),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  storageAsync.when(
                    loading: () => const _InfoTile(title: 'Checking...', value: ''),
                    error: (e, _) => const _InfoTile(title: 'Storage Check', value: 'Error', icon: Icons.error_outline_rounded, iconColor: TorStreamTheme.accentRed),
                    data: (report) => _InfoTile(title: 'Used / Total', value: '${_formatBytes(((report?.totalSpaceBytes ?? 0) - (report?.freeSpaceBytes ?? 0)).toInt())} / ${_formatBytes((report?.totalSpaceBytes ?? 0).toInt())}',
                      icon: Icons.folder_rounded),
                  ),
                  const SizedBox(height: 12),
                  Text('Storage Cap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85))),
                  const SizedBox(height: 4),
                  Text('${_storageCap.toStringAsFixed(0)} GB', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: TorStreamTheme.seedColor)),
                  Slider(
                    value: _storageCap,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${_storageCap.toStringAsFixed(0)} GB',
                    onChanged: (v) => setState(() => _storageCap = v),
                    onChangeEnd: (_) => _persist(),
                  ),
                ],
              ),
            ),
          ),
          _SettingsSwitch(
            title: 'Delete After Watching',
            subtitle: 'Automatically delete files once playback is complete',
            value: _deleteAfterWatching,
            onChanged: (v) {
              setState(() => _deleteAfterWatching = v);
              _persist();
            },
          ),
          _SettingsSwitch(
            title: 'Auto-Free Up Space',
            subtitle: 'Prompt to remove least-recently-watched files when storage is low',
            value: _autoEvict,
            onChanged: (v) {
              setState(() => _autoEvict = v);
              _persist();
            },
          ),
          const SizedBox(height: 12),
          _sectionHeader('BACKGROUND & RESUME'),
          _SettingsSwitch(
            title: 'Resume After Reboot',
            subtitle: 'Automatically restart downloads after device reboot',
            value: _resumeAfterReboot,
            onChanged: (v) {
              setState(() => _resumeAfterReboot = v);
              _persist();
            },
          ),
          const SizedBox(height: 16),
          _sectionHeader('ABOUT'),
          const _InfoTile(title: 'Version', value: '1.0.0', icon: Icons.info_outline_rounded),
          const _InfoTile(title: 'Engine', value: 'Rust + librqbit', icon: Icons.settings_rounded),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 10, left: 4),
      child: Text(title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: TorStreamTheme.textSecondary.withValues(alpha: 0.8),
        )),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.85))),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
        value: value,
                activeTrackColor: TorStreamTheme.seedColor,
        onChanged: onChanged,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const _InfoTile({required this.title, required this.value, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = iconColor ?? TorStreamTheme.seedColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.85))),
              ),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ),
      ),
    );
  }
}
