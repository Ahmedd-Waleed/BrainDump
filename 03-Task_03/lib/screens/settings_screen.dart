import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoCategorize = true;
  bool _autoPriority = true;
  bool _dailyReview = true;
  bool _deadlineAlerts = true;
  bool _weeklyInsights = true;
  String _theme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  const Text('⚙️ ', style: TextStyle(fontSize: 24)),
                  Text('Settings', style: AppTextStyles.title),
                ],
              ),

              const SizedBox(height: 24),

              // AI Settings
              Text('🤖 AI Settings', style: AppTextStyles.headerSmall),
              const SizedBox(height: 8),
              _buildCard([
                _buildSwitch('Auto-categorize',
                    'AI sorts your thoughts automatically',
                    _autoCategorize, (v) {
                  setState(() => _autoCategorize = v);
                }),
                const Divider(height: 1, color: AppColors.neutralBorder),
                _buildSwitch('Auto-priority',
                    'AI assigns priority levels',
                    _autoPriority, (v) {
                  setState(() => _autoPriority = v);
                }),
              ]),

              const SizedBox(height: 20),

              // Notifications
              Text('🔔 Notifications', style: AppTextStyles.headerSmall),
              const SizedBox(height: 8),
              _buildCard([
                _buildSwitch('Daily review',
                    'Remind to review captures',
                    _dailyReview, (v) {
                  setState(() => _dailyReview = v);
                }),
                const Divider(height: 1, color: AppColors.neutralBorder),
                _buildSwitch('Deadline alerts',
                    'Notify before deadlines',
                    _deadlineAlerts, (v) {
                  setState(() => _deadlineAlerts = v);
                }),
                const Divider(height: 1, color: AppColors.neutralBorder),
                _buildSwitch('Weekly insights',
                    'Weekly AI summary notification',
                    _weeklyInsights, (v) {
                  setState(() => _weeklyInsights = v);
                }),
              ]),

              const SizedBox(height: 20),

              // Appearance
              Text('🎨 Appearance', style: AppTextStyles.headerSmall),
              const SizedBox(height: 8),
              _buildCard([
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('Theme', style: AppTextStyles.bold)),
                      DropdownButton<String>(
                        value: _theme,
                        onChanged: (v) => setState(() => _theme = v!),
                        underline: const SizedBox(),
                        items: ['Light', 'Dark', 'System']
                            .map((o) => DropdownMenuItem(
                                value: o, child: Text(o)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 20),

              // Data
              Text('💾 Data', style: AppTextStyles.headerSmall),
              const SizedBox(height: 8),
              _buildCard([
                _buildAction('Export data', 'Download as JSON',
                    Icons.download_outlined, false),
                const Divider(height: 1, color: AppColors.neutralBorder),
                _buildAction('Clear all data', 'Delete everything',
                    Icons.delete_outline, true),
              ]),

              const SizedBox(height: 20),

              // About
              Center(
                child: Column(
                  children: [
                    Text(
                      'BrainDump AI',
                      style: AppTextStyles.bold.copyWith(
                          color: AppColors.primary),
                    ),
                    Text('Version 1.0.0', style: AppTextStyles.caption),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bold),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAction(String title, String subtitle, IconData icon,
      bool isDestructive) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.neutralDark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bold.copyWith(
                    color: isDestructive
                        ? AppColors.error
                        : AppColors.neutralBlack,
                  )),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.neutralGray),
          ],
        ),
      ),
    );
  }
}