import 'package:mess_prototype/database/app_database.dart';
import 'package:mess_prototype/database/database_provider.dart';
import 'package:mess_prototype/models/app_settings.dart';

class SettingsRepository {
  Future<Settings> getAppSettings() async {
    AppSetting? data = await database.getSettings();

    if (data == null) {
      await database.createSettings();

      data = await database.getSettings();
    }

    return Settings(
      theme: data!.theme,
      language: data.language,
      notifications: data.notifications,
    );
  }
}