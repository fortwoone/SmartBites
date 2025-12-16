import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDialogs {
  static const Color primaryPeach = Color(0xFFFF8C61);

  static Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.recursive(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.recursive(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPeach, width: 2),
        ),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }

  static Future<void> showChangePasswordDialog(BuildContext context) async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            elevation: 10,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.change_password,
                    style: GoogleFonts.recursive(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDialogTextField(
                    controller: oldCtrl,
                    label: 'Mot de passe actuel',
                    obscureText: obscureOld,
                    onToggleObscure: () => setStateDialog(() => obscureOld = !obscureOld),
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: newCtrl,
                    label: 'Nouveau mot de passe',
                    obscureText: obscureNew,
                    onToggleObscure: () => setStateDialog(() => obscureNew = !obscureNew),
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: confirmCtrl,
                    label: 'Confirmer',
                    obscureText: obscureConfirm,
                    onToggleObscure: () => setStateDialog(() => obscureConfirm = !obscureConfirm),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: GoogleFonts.recursive(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPeach,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                final oldPwd = oldCtrl.text.trim();
                                final newPwd = newCtrl.text.trim();
                                final confirm = confirmCtrl.text.trim();
                                if (oldPwd.isEmpty || newPwd.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.fields_required)),
                                  );
                                  return;
                                }
                                if (newPwd != confirm) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.passwords_mismatch)),
                                  );
                                  return;
                                }
                                setStateDialog(() => isLoading = true);
                                try {
                                  final client = Supabase.instance.client;
                                  await client.auth.updateUser(UserAttributes(password: newPwd));
                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                  await client.auth.signOut();
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    setStateDialog(() => isLoading = false);
                                    final loc = AppLocalizations.of(context)!;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${loc.password_update_failed}: ${e.toString()}')),
                                    );
                                  }
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(AppLocalizations.of(context)!.validate),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  static Future<void> showEditNameDialog(
    BuildContext context,
    String currentName,
    Function(String) onNameUpdated,
  ) async {
    final ctrl = TextEditingController(text: currentName);
    bool isLoading = false;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.edit_name_title,
                    style: GoogleFonts.recursive(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDialogTextField(
                    controller: ctrl,
                    label: AppLocalizations.of(context)!.edit_name_label,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: GoogleFonts.recursive(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPeach,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                final newName = ctrl.text.trim();
                                if (newName.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.fields_required)),
                                  );
                                  return;
                                }
                                if (newName == currentName) {
                                  Navigator.pop(context, false);
                                  return;
                                }
                                setStateDialog(() => isLoading = true);
                                try {
                                  final client = Supabase.instance.client;
                                  await client.auth.updateUser(UserAttributes(data: {'display_name': newName}));
                                  onNameUpdated(newName);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppLocalizations.of(context)!.name_updated)),
                                    );
                                  }
                                  Navigator.pop(context, true);
                                } catch (e) {
                                  final loc = AppLocalizations.of(context)!;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${loc.name_update_failed}: ${e.toString()}')),
                                  );
                                } finally {
                                  setStateDialog(() => isLoading = false);
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(AppLocalizations.of(context)!.validate),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  static Future<void> showImageSourceDialog(
    BuildContext context,
    Function(ImageSource) onSourceSelected,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.change_photo_title,
                  style: GoogleFonts.recursive(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withAlpha(20), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.blue, size: 22),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.take_photo,
                    style: GoogleFonts.recursive(fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.withAlpha(20), shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.green, size: 22),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.choose_from_gallery,
                    style: GoogleFonts.recursive(fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: GoogleFonts.recursive(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

