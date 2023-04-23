import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kavelypeli/models/user_model.dart';

class AppUserSettings {
  bool darkMode;

  AppUserSettings({
    required this.darkMode,
  });

  static Future<AppUserSettings?> createAppUserSettings(String uid) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DocumentReference userSettingsDocRef =
      db.collection('user_settings').doc(uid);

      final userSettingsDocSnapshot = await userSettingsDocRef.get();

      return AppUserSettings(
        darkMode: userSettingsDocSnapshot["darkMode"],
      );
    } catch (_) {
      return null;
    }
  }
}
