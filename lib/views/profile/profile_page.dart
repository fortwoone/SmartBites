import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../l10n/app_localizations.dart';
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
  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, maxWidth: 300, maxHeight: 300, imageQuality: 80,);
     
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
       backgroundColor: const Color(0xFFFAFAFA),
       body: Stack(
         children: [
           Positioned(
             top: -100,
             right: -50,
             child: Container(
               width: 350,
               height: 350,
               decoration: BoxDecoration(
                 color: const Color(0xFFFF8C61).withOpacity(0.2),
                 shape: BoxShape.circle,
               ),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                 child: Container(color: Colors.transparent),
               ),
             ),
           ),
           Positioned(
             top: 100,
             left: -100,
             child: Container(
               width: 300,
               height: 300,
               decoration: BoxDecoration(
                 color: Colors.blueAccent.withOpacity(0.1),
                 shape: BoxShape.circle,
               ),
                child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                 child: Container(color: Colors.transparent),
               ),
             ),
           ),
           
           SafeArea(
             child: SingleChildScrollView(
               physics: const BouncingScrollPhysics(),
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
                 child: Column(
                   children: [
                     const SizedBox(height: 20),
                     // Header
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
                     Align(
                       alignment: Alignment.centerLeft,
                       child: Text(
                         loc.my_account.toUpperCase(),
                         style: GoogleFonts.inter(
                           fontSize: 12, 
                           fontWeight: FontWeight.bold,
                           letterSpacing: 1.2,
                           color: Colors.grey.shade400
                         ),
                       ),
                     ),
                     const SizedBox(height: 12),
                     ProfileOptionTile(
                        icon: CupertinoIcons.doc_text,
                        title: loc.shopping_lists, 
                        subtitle: loc.history_subtitle,
                        onTap: () {
                           ref.read(dashboardIndexProvider.notifier).state = 1; 
                        },
                     ),
                     ProfileOptionTile(
                        icon: CupertinoIcons.person_crop_circle_badge_exclam,
                        title: loc.edit_name_tile_title,
                        subtitle: loc.edit_name_tile_subtitle,
                        onTap: () => ProfileDialogs.showEditNameDialog(
                           context, 
                           user.displayName ?? '',
                           (newName) => ref.read(authViewModelProvider.notifier).updateDisplayName(newName)
                        ),
                     ),
                     ProfileOptionTile(
                        icon: CupertinoIcons.lock,
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

                     const SizedBox(height: 40),
                      Align(
                       alignment: Alignment.centerLeft,
                       child: Text(
                         "ACTIONS",
                         style: GoogleFonts.inter(
                           fontSize: 12, 
                           fontWeight: FontWeight.bold,
                           letterSpacing: 1.2,
                           color: Colors.grey.shade400
                         ),
                       ),
                     ),
                     const SizedBox(height: 12),
                     ProfileOptionTile(
                       icon: CupertinoIcons.power,
                       title: loc.disconnect,
                       subtitle: "",
                       onTap: () => ref.read(authViewModelProvider.notifier).signOut(),
                       isDestructive: true,
                     ),
                     
                     const SizedBox(height: 100),
                   ],
                 ),
               ),
             ),
           ),
         ],
       ),
    );
  }
}
