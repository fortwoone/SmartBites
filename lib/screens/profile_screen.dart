import 'package:flutter/material.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/side_menu.dart';
import '../utils/color_constants.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_option_tile.dart';
import '../widgets/profile/profile_dialogs.dart';
import '../widgets/profile/profile_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    try {
      final userInfo = await ProfileService.loadUserInfo();
      setState(() {
        _email = userInfo['email'];
        _displayName = userInfo['displayName'];
        _avatarUrl = userInfo['avatarUrl'];
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


  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    setState(() => _isLoadingAvatar = true);
    try {
      final avatarUrl = await ProfileService.pickAndUploadAvatar(context, source);
      setState(() {
        _avatarUrl = avatarUrl;
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
      if (e.toString().contains('No image selected')) return;

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: primaryPeach.withAlpha(100),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: accentPeach.withAlpha(150),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                         const SizedBox(height: 10),
                         ProfileHeader(
                           displayName: _displayName,
                           email: _email,
                           avatarUrl: _avatarUrl,
                           isLoadingAvatar: _isLoadingAvatar,
                           onAvatarTap: () => ProfileDialogs.showImageSourceDialog(
                             context,
                             _pickAndUploadAvatar,
                           ),
                           onEditNameTap: () => ProfileDialogs.showEditNameDialog(
                             context,
                             _displayName,
                             (newName) => setState(() => _displayName = newName),
                           ),
                         ),
                         
                         const SizedBox(height: 40),
                         Container(
                          width: double.infinity,
                           padding: const EdgeInsets.all(24),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(24),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.grey.withAlpha(26),
                                 blurRadius: 20,
                                 offset: const Offset(0, 5),
                               ),
                             ],
                           ),
                           child: Column(
                             children: [
                               ProfileOptionTile(
                                 icon: Icons.history_rounded,
                                 title: AppLocalizations.of(context)!.shopping_lists,
                                 subtitle: AppLocalizations.of(context)!.history_subtitle,
                                 onTap: () {},
                               ),
                               const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 12),
                                 child: Divider(height: 1),
                               ),
                               ProfileOptionTile(
                                 icon: Icons.edit_outlined,
                                 title: AppLocalizations.of(context)!.edit_name_tile_title,
                                 subtitle: AppLocalizations.of(context)!.edit_name_tile_subtitle,
                                 onTap: () => ProfileDialogs.showEditNameDialog(
                                   context,
                                   _displayName,
                                   (newName) => setState(() => _displayName = newName),
                                 ),
                               ),
                               const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 12),
                                 child: Divider(height: 1),
                               ),
                               ProfileOptionTile(
                                 icon: Icons.lock_outline_rounded,
                                 title: AppLocalizations.of(context)!.change_password,
                                 subtitle: AppLocalizations.of(context)!.change_password_subtitle,
                                 onTap: () => ProfileDialogs.showChangePasswordDialog(context),
                               ),
                             ],
                           ),
                         ),
                         
                         const SizedBox(height: 24),
                         SizedBox(
                           width: double.infinity,
                           child: TextButton.icon(
                             onPressed: () => ProfileService.signOut(context),
                             style: TextButton.styleFrom(
                               backgroundColor: Colors.red.shade50,
                               foregroundColor: Colors.redAccent,
                               padding: const EdgeInsets.symmetric(vertical: 16),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                             ),
                             icon: const Icon(Icons.logout_rounded),
                             label: Text(
                               AppLocalizations.of(context)!.disconnect,
                               style: GoogleFonts.recursive(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 16,
                               ),
                             ),
                           ),
                         ),
                         const SizedBox(height: 40),
                      ],
                    ),
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

}
