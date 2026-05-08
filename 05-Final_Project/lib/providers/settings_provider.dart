/// Settings Provider
///
/// Persists user preferences for AI behavior and notifications.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kAutoCategorize = 'auto_categorize';
  static const _kAutoPriority = 'auto_priority';
  static const _kDailyReview = 'daily_review';
  static const _kDeadlineAlerts = 'deadline_alerts';
  static const _kWeeklyInsights = 'weekly_insights';

  bool _autoCategorize = true;
  bool _autoPriority = true;
  bool _dailyReview = true;
  bool _deadlineAlerts = true;
  bool _weeklyInsights = true;

  bool get autoCategorize => _autoCategorize;
  bool get autoPriority => _autoPriority;
  bool get dailyReview => _dailyReview;
  bool get deadlineAlerts => _deadlineAlerts;
  bool get weeklyInsights => _weeklyInsights;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _autoCategorize = prefs.getBool(_kAutoCategorize) ?? true;
    _autoPriority = prefs.getBool(_kAutoPriority) ?? true;
    _dailyReview = prefs.getBool(_kDailyReview) ?? true;
    _deadlineAlerts = prefs.getBool(_kDeadlineAlerts) ?? true;
    _weeklyInsights = prefs.getBool(_kWeeklyInsights) ?? true;
    notifyListeners();
  }

  Future<void> setAutoCategorize(bool v) async {
    _autoCategorize = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoCategorize, v);
  }

  Future<void> setAutoPriority(bool v) async {
    _autoPriority = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoPriority, v);
  }

  Future<void> setDailyReview(bool v) async {
    _dailyReview = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDailyReview, v);

    if (v) {
      await NotificationService.instance.scheduleDailyReview();
    } else {
      await NotificationService.instance.cancelDailyReview();
    }
  }

  Future<void> setDeadlineAlerts(bool v) async {
    _deadlineAlerts = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDeadlineAlerts, v);
  }

  Future<void> setWeeklyInsights(bool v) async {
    _weeklyInsights = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWeeklyInsights, v);
  }
}
