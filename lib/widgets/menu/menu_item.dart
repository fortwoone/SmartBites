import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String routeName;
  final bool isSelected;
  final bool isDisconnect;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.routeName = '',
    this.isSelected = false,
    this.isDisconnect = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDisconnect ? Colors.redAccent : (isSelected ? primaryPeach : Colors.black87);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected && !isDisconnect ? primaryPeach.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 26,
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.recursive(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

