import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:food/l10n/app_localizations.dart';

class SideMenu extends StatefulWidget {
    final String currentRoute;

    const SideMenu({super.key, required this.currentRoute});

    @override
    State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> with SingleTickerProviderStateMixin {
    bool _isOpen = false;
    late final AnimationController _controller;
    late final Animation<Offset> _slideAnim;

    @override
    void initState() {
        super.initState();
        _controller = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 250),
        );
        _slideAnim = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }

    void _openMenu() {
        setState(() {
            _isOpen = true;
            _controller.forward();
        });
    }

    void _closeMenu() {
        setState(() {
            _isOpen = false;
            _controller.reverse();
        });
    }

    void _disconnect() async {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
        }
    }

    void _navigateIfNotCurrent(String routeName) {
        if (routeName == widget.currentRoute) {
            _closeMenu();
            return;
        }

        Navigator.pushNamedAndRemoveUntil(
            context,
            routeName,
                (route) => false,
        );

        _closeMenu();
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        final screenWidth = MediaQuery.of(context).size.width;

        return Stack(
            children: [
                if (!_isOpen)
                    Positioned(
                        left: 0,
                        top: MediaQuery.of(context).size.height * 0.4,
                        child: GestureDetector(
                            onTap: _openMenu,
                            onHorizontalDragUpdate: (details) {
                                if (details.delta.dx > 3) {
                                    _openMenu();
                                }
                            },
                            child: Container(
                                width: 28,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                    ),
                                ),
                                child: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 20,
                                ),
                            ),
                        ),
                    ),
                if (!_isOpen)
                    Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 1000,
                        child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                                if (details.delta.dx > 3) {
                                    _openMenu();
                                }
                            },
                            behavior: HitTestBehavior.translucent,
                            child: const SizedBox.expand(),
                        ),
                    ),

                // Dark overlay when menu is open
                if (_isOpen)
                    GestureDetector(
                        onTap: _closeMenu,
                        child: Container(
                            color: Colors.black38,
                            width: screenWidth,
                            height: double.infinity,
                        ),
                    ),

                // Slide-in menu
                SlideTransition(
                    position: _slideAnim,
                    child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                            if (details.delta.dx < -10) {
                                _closeMenu();
                            }
                        },
                        child: Container(
                            width: 220,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                                children: [
                                    IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: _closeMenu,
                                        tooltip: loc.close_menu,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildMenuItem(
                                        icon: Icons.house,
                                        title: loc.homePageTitle,
                                        routeName: '/home',
                                    ),
                                    _buildMenuItem(
                                        icon: Icons.account_circle,
                                        title: loc.profile,
                                        routeName: '/profile',
                                    ),
                                    _buildMenuItem(
                                        icon: Icons.fact_check,
                                        title: loc.list_menu,
                                        routeName: '/shopping',
                                    ),
                                    _buildMenuItem(
                                        icon: Icons.menu_book,
                                        title: loc.recipes,
                                        routeName: '/recipe',
                                    ),
                                    const Spacer(),
                                    _buildMenuItem(
                                        icon: Icons.logout,
                                        title: loc.disconnect,
                                        isDisconnect: true,
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildMenuItem({
        required IconData icon,
        required String title,
        String routeName = '',
        bool isDisconnect = false,
    }) {
        final selected = routeName == widget.currentRoute;

        return InkWell(
            onTap: () {
                if (isDisconnect) {
                    _disconnect();
                } else if (routeName.isNotEmpty) {
                    _navigateIfNotCurrent(routeName);
                }
            },
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Row(
                    children: [
                        Icon(icon, color: selected ? Colors.orangeAccent : Colors.black54),
                        const SizedBox(width: 10),
                        Flexible(
                            child: Text(
                                title,
                                style: TextStyle(
                                    color: selected ? Colors.orangeAccent : Colors.black87,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }
}
