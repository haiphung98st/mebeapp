import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import 'widget_data.dart';

const _appGroupId = 'group.com.mebe.mebetracker';
const _iOSWidgetName = 'MeBeWidget';
const _androidWidget = 'com.mebe.mebe_tracker.widget.MeBeWidget';
const _bgTaskName = 'mebe_widget_refresh';

class WidgetService {
  WidgetService._();

  static Future<void> init(void Function() dispatcher) async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await Workmanager().initialize(dispatcher, isInDebugMode: false);
  }

  static Future<void> scheduleBackgroundRefresh() async {
    try {
      await Workmanager().registerPeriodicTask(
        _bgTaskName,
        _bgTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.not_required),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
    } catch (_) {}
  }

  static Future<void> save(WidgetData data) async {
    final json = data.toJson();
    await Future.wait([
      for (final entry in json.entries)
        HomeWidget.saveWidgetData<dynamic>(entry.key, entry.value),
    ]);
  }

  static Future<void> update(WidgetData data) async {
    await save(data);
    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidget,
    );
  }

  static Future<void> triggerNativeRefresh() async {
    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidget,
    );
  }

  static void listenForWidgetLaunch(void Function(Uri?) handler) {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(handler);
    HomeWidget.widgetClicked.listen(handler);
  }
}

// Called from the Workmanager background dispatcher.
void widgetBackgroundTask() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidget,
      );
    } catch (_) {}
    return true;
  });
}
