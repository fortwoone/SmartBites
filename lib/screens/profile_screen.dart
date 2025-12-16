import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../widgets/side_menu.dart';


const Color primaryPeach = Color(0xFFF6B092);
const Color accentPeach = Color(0xFFF6CF92);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _email = '';
  String _displayName = '';
  String? _avatarUrl;
  bool _isLoadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser ?? client.auth.currentSession?.user;

      if (user == null) {
        throw Exception('no_user');
      }

      final email = user.email;
      final displayName = user.userMetadata?['display_name'] as String? ?? _nameFromEmail(email);
      final avatarUrl = user.userMetadata?['avatar_url'] as String?;

      setState(() {
        _email = email ?? '';
        _displayName = displayName;
        _avatarUrl = avatarUrl;
      });
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(loc.load_user_error),
            content: Text('${loc.generic_error}: ${e.toString()}'),
            actions: [
              TextButton(onPressed: () { Navigator.pop(ctx); }, child: Text(loc.ok)),
              TextButton(onPressed: () {
                Navigator.pop(ctx);
                _loadUserInfo();
              }, child: Text(loc.retry)),
            ],
          ),
        );
      });
    }
  }

  String _nameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'Utilisateur';
    final local = email.split('@').first;
    final parts = local.replaceAll(RegExp(r'[._]+'), ' ').split(' ');
    final titled = parts.map((p) {
      if (p.isEmpty) return '';
      return p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : '');
    }).where((s) => s.isNotEmpty).join(' ');
    return titled.isNotEmpty ? titled : local;
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _showChangePasswordDialog() async {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(colors: [primaryPeach, accentPeach]),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(AppLocalizations.of(context)!.change_password, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: oldCtrl,
                        obscureText: obscureOld,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe actuel',
                          suffixIcon: IconButton(
                            icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setStateDialog(() => obscureOld = !obscureOld),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: newCtrl,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setStateDialog(() => obscureNew = !obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmCtrl,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le nouveau mot de passe',
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setStateDialog(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPeach,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final oldPwd = oldCtrl.text.trim();
                                    final newPwd = newCtrl.text.trim();
                                    final confirm = confirmCtrl.text.trim();
                                    if (oldPwd.isEmpty || newPwd.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.fields_required)));
                                      return;
                                    }
                                    if (newPwd != confirm) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.passwords_mismatch)));
                                      return;
                                    }
                                    setStateDialog(() => isLoading = true);
                                    try {
                                      final client = Supabase.instance.client;
                                      await client.auth.updateUser(UserAttributes(password: newPwd));
                                      if (!mounted) return;
                                      Navigator.of(context).pop();
                                      await client.auth.signOut();
                                      if (!mounted) return;
                                      Navigator.of(this.context).pushNamedAndRemoveUntil(
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
                            child: isLoading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : Text(AppLocalizations.of(context)!.validate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
    return;
  }

  Future<void> _showEditNameDialog() async {
    final ctrl = TextEditingController(text: _displayName);
    bool isLoading = false;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(colors: [primaryPeach, accentPeach]),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(AppLocalizations.of(context)!.edit_name_title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: ctrl,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.edit_name_label),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPeach,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final newName = ctrl.text.trim();
                                    if (newName.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.fields_required)));
                                      return;
                                    }
                                    if (newName == _displayName) {
                                      Navigator.pop(context, false);
                                      return;
                                    }
                                    setStateDialog(() => isLoading = true);
                                    try {
                                      final client = Supabase.instance.client;
                                      await client.auth.updateUser(UserAttributes(data: {'display_name': newName}));
                                      setState(() => _displayName = newName);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.name_updated)));
                                      }
                                      Navigator.pop(context, true);
                                    } catch (e) {
                                      final loc = AppLocalizations.of(context)!;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.name_update_failed}: ${e.toString()}')));
                                    } finally {
                                      setStateDialog(() => isLoading = false);
                                    }
                                  },
                            child: isLoading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : Text(AppLocalizations.of(context)!.validate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.change_photo_title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.take_photo),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text(AppLocalizations.of(context)!.choose_from_gallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      // Sélectionner une image depuis la source choisie
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 60,
      );

      if (image == null) return;

      setState(() => _isLoadingAvatar = true);

      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }final file = File(image.path);
      final bytes = await file.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      await client.auth.updateUser(
        UserAttributes(
          data: {'avatar_url': base64Image},
        ),
      );
      setState(() {
        _avatarUrl = base64Image;
        _isLoadingAvatar = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photo_update_success),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingAvatar = false);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.avatar_upload_failed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAvatar() {
    if (_isLoadingAvatar) {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(),
      );
    }

    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      if (_avatarUrl!.startsWith('data:image')) {
        try {
          final base64String = _avatarUrl!.split(',')[1];
          final bytes = base64Decode(base64String);
          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: MemoryImage(bytes),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          );
        } catch (e) {
          // ignoe
        }
      } else {
        return CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(_avatarUrl!),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        );
      }
    }
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.grey[400],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryPeach, accentPeach],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 8,
                        top: 8,
                        child: SafeArea(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            tooltip: 'Retour',
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _showImageSourceDialog(),
                              child: Stack(
                                children: [
                                  _buildAvatar(),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: primaryPeach,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _showEditNameDialog(),
                              child: Text(
                                _displayName.isNotEmpty ? _displayName : 'Utilisateur',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email.isNotEmpty ? _email : '',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildProfileOption(
                              icon: Icons.history_rounded,
                              title: AppLocalizations.of(context)!.shopping_lists,
                              subtitle: AppLocalizations.of(context)!.history_subtitle,
                              onTap: () {},
                            ),
                            const Divider(height: 20),
                            _buildProfileOption(
                              icon: Icons.edit,
                              title: AppLocalizations.of(context)!.edit_name_tile_title,
                              subtitle: AppLocalizations.of(context)!.edit_name_tile_subtitle,
                              onTap: () async => await _showEditNameDialog(),
                            ),
                            const Divider(height: 20),
                            _buildProfileOption(
                              icon: Icons.lock_outline,
                              title: AppLocalizations.of(context)!.change_password,
                              subtitle: AppLocalizations.of(context)!.change_password_subtitle,
                              onTap: () async => await _showChangePasswordDialog(),
                            ),
                            const Divider(height: 20),
                            _buildProfileOption(
                              icon: Icons.logout_rounded,
                              title: AppLocalizations.of(context)!.disconnect,
                              subtitle: AppLocalizations.of(context)!.logout_subtitle,
                              color: Colors.redAccent,
                              onTap: () async => await _signOut(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SideMenu(currentRoute: '/profile'),
        ],
      ),
    );
  }


  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (color ?? primaryPeach).withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color ?? primaryPeach,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color ?? Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
