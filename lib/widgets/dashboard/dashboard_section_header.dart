import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? seeAllLabel;
  final VoidCallback? onMoreTap;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.seeAllLabel,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (onMoreTap != null && seeAllLabel != null)
            InkWell(
              onTap: onMoreTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Text(
                      seeAllLabel!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
