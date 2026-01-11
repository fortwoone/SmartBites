import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../l10n/app_localizations.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_option_tile.dart';
import '../../widgets/profile/profile_dialogs.dart';
import '../../providers/app_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  // Récupérer et téléverser l'avatar
  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, maxWidth: 200, maxHeight: 200, imageQuality: 60,);
     
    if (image == null) {
      return;
    }
    final file = File(image.path);
    await ref.read(authViewModelProvider.notifier).updateAvatar(file);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.value;
    final loc = AppLocalizations.of(context)!;
    if (user == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                 color: primaryPeach.withOpacity(0.3),
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
                 color: accentPeach.withOpacity(0.5),
                 shape: BoxShape.circle,
               ),
             ),
           ),
           
           SafeArea(
             child: Column(
               children: [
                 const SizedBox(height: 40),
                 ProfileHeader(
                    displayName: user.displayName ?? 'Utilisateur',
                    email: user.email,
                    avatarUrl: user.avatarUrl,
                    isLoadingAvatar: authState.isLoading, 
                    onAvatarTap: () => ProfileDialogs.showImageSourceDialog(context, _pickAndUploadAvatar),
                    onEditNameTap: () => ProfileDialogs.showEditNameDialog(
                        context, 
                        user.displayName ?? '',
                        (newName) => ref.read(authViewModelProvider.notifier).updateDisplayName(newName)
                    ),
                 ),
                 
                 const SizedBox(height: 40),
                 
                 Expanded(
                    child: Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(24),
                       margin: const EdgeInsets.symmetric(horizontal: 24),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: const BorderRadius.vertical(top: Radius.circular(30), bottom: Radius.circular(30)), // Floating card effect
                         boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))
                         ]
                       ),
                       child: SingleChildScrollView(
                         child: Column(
                            children: [
                                ProfileOptionTile(
                                   icon: Icons.history_rounded,
                                   title: loc.shopping_lists, 
                                   subtitle: loc.history_subtitle,
                                   onTap: () {
                                      ref.read(dashboardIndexProvider.notifier).state = 2;
                                   },
                                ),
                                const Divider(height: 24),
                                ProfileOptionTile(
                                   icon: Icons.edit_outlined,
                                   title: loc.edit_name_tile_title,
                                   subtitle: loc.edit_name_tile_subtitle,
                                   onTap: () => ProfileDialogs.showEditNameDialog(
                                      context, 
                                      user.displayName ?? '',
                                      (newName) => ref.read(authViewModelProvider.notifier).updateDisplayName(newName)
                                   ),
                                ),
                                const Divider(height: 24),
                                ProfileOptionTile(
                                   icon: Icons.lock_outline_rounded,
                                   title: loc.change_password,
                                   subtitle: loc.change_password_subtitle,
                                   onTap: () => ProfileDialogs.showChangePasswordDialog(
                                      context,
                                      (old, newPwd) async {
                                          await ref.read(authViewModelProvider.notifier).signIn(user.email, old);
                                          await ref.read(authViewModelProvider.notifier).updatePassword(newPwd);
                                      }
                                   ),
                                ),
                            ],
                         ),
                       ),
                    ),
                 ),
                 
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                   child: SizedBox(
                     width: double.infinity,
                     child: TextButton.icon(
                       onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
                       style: TextButton.styleFrom(
                         backgroundColor: Colors.red.shade50,
                         foregroundColor: Colors.redAccent,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       ),
                       icon: const Icon(Icons.logout_rounded),
                       label: Text(
                         loc.disconnect,
                         style: GoogleFonts.recursive(
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                         ),
                       ),
                     ),
                   ),
                 ),
               ],
             ),
           ),
         ],
       ),
    );
  }
}
