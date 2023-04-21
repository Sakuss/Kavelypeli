import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kavelypeli/models/user_model.dart';

class AppUserSettings {
  bool? darkMode;

  AppUserSettings({
    this.darkMode,
  });

  static Future<AppUserSettings?> createAppUserSettings(AppUser user) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DocumentReference userSettingsDocRef =
      db.collection('user_settings').doc(user.uid);

      final userSettingsDocSnapshot = await userSettingsDocRef.get();

      return AppUserSettings(
        darkMode: userSettingsDocSnapshot["darkMode"],
      );
    } catch (_) {
      return null;
    }
  }
}
