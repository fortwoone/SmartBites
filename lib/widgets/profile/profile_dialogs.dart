import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';

class ProfileDialogs {
  static const Color primaryPeach = Color(0xFFFF8C61);

  static Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
          floatingLabelStyle: GoogleFonts.inter(color: primaryPeach, fontWeight: FontWeight.bold),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                      obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash, 
                      color: Colors.grey.shade400,
                      size: 20,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
        ),
      ),
    );
  }

  // Popup de dialogue pour changer le mot de passe
  static Future<void> showChangePasswordDialog(
      BuildContext context,
      Future<void> Function(String oldPwd, String newPwd) onConfirm) async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;
    final loc = AppLocalizations.of(context)!;
    
    await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryPeach.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.lock_shield, color: primaryPeach, size: 32),
                    ),
                  ),
                  Text(
                    loc.change_password,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.change_password_subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildDialogTextField(
                    controller: oldCtrl,
                    label: loc.current_password,
                    obscureText: obscureOld,
                    onToggleObscure: () => setStateDialog(() => obscureOld = !obscureOld),
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: newCtrl,
                    label: loc.new_password,
                    obscureText: obscureNew,
                    onToggleObscure: () => setStateDialog(() => obscureNew = !obscureNew),
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: confirmCtrl,
                    label: loc.confirm_new_password,
                    obscureText: obscureConfirm,
                    onToggleObscure: () => setStateDialog(() => obscureConfirm = !obscureConfirm),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            loc.cancel,
                            style: GoogleFonts.inter(
                                color: Colors.grey.shade600, 
                                fontWeight: FontWeight.w600,
                                fontSize: 14
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPeach,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final oldPwd = oldCtrl.text.trim();
                                  final newPwd = newCtrl.text.trim();
                                  final confirm = confirmCtrl.text.trim();
                                  
                                  // Simple validation visual feedback
                                  if (oldPwd.isEmpty || newPwd.isEmpty) return;
                                  
                                  if (newPwd != confirm) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(loc.passwords_mismatch)),
                                    );
                                    return;
                                  }
                                  
                                  setStateDialog(() => isLoading = true);
                                  try {
                                    await onConfirm(oldPwd, newPwd);
                                    if (context.mounted) {
                                      Navigator.pop(context, true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(loc.password_updated),
                                            backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${loc.password_update_failed}: ${e.toString()}')),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setStateDialog(() => isLoading = false);
                                    }
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  loc.validate,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                        ),
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

  // Popup de dialogue pour éditer le nom d'utilisateur
  static Future<void> showEditNameDialog(
    BuildContext context,
    String currentName,
    Future<void> Function(String) onConfirm,
  ) async {
    final ctrl = TextEditingController(text: currentName);
    bool isLoading = false;
    final loc = AppLocalizations.of(context)!;

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.person_solid, color: Colors.blueAccent, size: 32),
                    ),
                  ),
                  Text(
                    loc.edit_name_tile_title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                   const SizedBox(height: 8),
                  Text(
                    loc.edit_name_tile_subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildDialogTextField(
                    controller: ctrl,
                    label: loc.edit_name_label,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context, false),
                           style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            loc.cancel,
                            style: GoogleFonts.inter(
                                color: Colors.grey.shade600, 
                                fontWeight: FontWeight.w600,
                                fontSize: 14
                             ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final newName = ctrl.text.trim();
                                  if (newName.isEmpty) return;
                                  
                                  if (newName == currentName) {
                                    Navigator.pop(context, false);
                                    return;
                                  }
                                  setStateDialog(() => isLoading = true);
                                  try {
                                    await onConfirm(newName);
                                    if (context.mounted) {
                                      Navigator.pop(context, true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(loc.name_updated),
                                            backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${loc.name_update_failed}: ${e.toString()}')),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setStateDialog(() => isLoading = false);
                                    }
                                  }
                                },
                           child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  loc.validate,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                        ),
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

  // Bottom Sheet pour choisir la source de l'image
  static Future<void> showImageSourceDialog(
    BuildContext context,
    Function(ImageSource) onSourceSelected,
  ) async {
    final loc = AppLocalizations.of(context)!;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.change_photo_title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSourceOption(
                    icon: CupertinoIcons.camera_fill,
                    color: Colors.blueAccent,
                    label: loc.take_photo,
                    onTap: () {
                      Navigator.pop(context);
                      onSourceSelected(ImageSource.camera);
                    },
                  ),
                  _buildSourceOption(
                    icon: CupertinoIcons.photo_fill,
                    color: Colors.purpleAccent,
                    label: loc.choose_from_gallery,
                    onTap: () {
                      Navigator.pop(context);
                      onSourceSelected(ImageSource.gallery);
                    },
                  ),
                ],
              ),
               const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
  
  static Widget _buildSourceOption({
      required IconData icon,
      required Color color,
      required String label,
      required VoidCallback onTap,
  }) {
      return GestureDetector(
          onTap: onTap,
          child: Column(
              children: [
                  Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      label,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                      ),
                  ),
              ],
          ),
      );
  }
}
