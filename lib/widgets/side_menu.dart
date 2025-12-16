import 'package:flutter/material.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu/menu_constants.dart';
import 'menu/menu_header.dart';
import 'menu/menu_content.dart';
import 'menu/menu_service.dart';
import 'menu/menu_item.dart';

class SideMenu extends StatefulWidget {
  final String currentRoute;
  final ValueChanged<bool>? onOpenChanged;

  const SideMenu({
    super.key,
    required this.currentRoute,
    this.onOpenChanged,
  });

  @override
  State<SideMenu> createState() => SideMenuState();
}

class SideMenuState extends State<SideMenu> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MenuConstants.animationDuration,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void open() {
    if (_isOpen) return;
    setState(() {
      _isOpen = true;
      _controller.forward();
    });
    widget.onOpenChanged?.call(true);
  }

  void close() {
    if (!_isOpen) return;
    setState(() {
      _isOpen = false;
      _controller.reverse();
    });
    widget.onOpenChanged?.call(false);
  }

  void toggle() {
    _isOpen ? close() : open();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        if (!_isOpen) _buildDragArea(),
        _buildOverlay(screenWidth),
        _buildMenuPanel(loc),
      ],
    );
  }

  Widget _buildDragArea() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: MenuConstants.dragThreshold,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > MenuConstants.dragOpenVelocity) {
            open();
          }
        },
        behavior: HitTestBehavior.translucent,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildOverlay(double screenWidth) {
    return IgnorePointer(
      ignoring: !_isOpen,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTap: close,
          child: Container(
            color: Colors.black54,
            width: screenWidth,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuPanel(AppLocalizations loc) {
    return SlideTransition(
      position: _slideAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < MenuConstants.dragCloseVelocity) {
              close();
            }
          },
          child: Material(
            elevation: 16,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Container(
              width: MenuConstants.menuWidth,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuTitle(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MenuHeader(
                              onTap: () {
                                close();
                                Navigator.pushNamed(context, '/profile');
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildNavigationLabel(),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: MenuContent(
                                currentRoute: widget.currentRoute,
                                onClose: close,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildDisconnectButton(loc),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        'Menu',
        style: GoogleFonts.recursive(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNavigationLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'NAVIGATION',
        style: GoogleFonts.recursive(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildDisconnectButton(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: MenuItem(
        icon: Icons.logout_rounded,
        title: loc.disconnect,
        isDisconnect: true,
        onTap: () => MenuService.disconnect(context),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}