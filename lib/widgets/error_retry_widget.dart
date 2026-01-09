import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/color_constants.dart';

class ErrorRetryWidget extends StatelessWidget {
    final String message;
    final VoidCallback onRetry;
    final IconData icon;

    const ErrorRetryWidget({
        super.key,
        required this.message,
        required this.onRetry,
        this.icon = Icons.error_outline_rounded,
    });

    @override
    Widget build(BuildContext context) {
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                            ),
                            child: Icon(
                                icon,
                                size: 48,
                                color: Colors.redAccent,
                            ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                            message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.recursive(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1.5,
                            ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                                'Réessayer',
                                style: GoogleFonts.recursive(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPeach,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class NetworkErrorWidget extends StatelessWidget {
    final VoidCallback onRetry;

    const NetworkErrorWidget({super.key, required this.onRetry});

    @override
    Widget build(BuildContext context) {
        return ErrorRetryWidget(
            message: 'Impossible de se connecter.\nVérifiez votre connexion internet.',
            onRetry: onRetry,
            icon: Icons.wifi_off_rounded,
        );
    }
}

class SearchErrorWidget extends StatelessWidget {
    final VoidCallback onRetry;

    const SearchErrorWidget({super.key, required this.onRetry});

    @override
    Widget build(BuildContext context) {
        return ErrorRetryWidget(
            message: 'La recherche a échoué.\nVeuillez réessayer.',
            onRetry: onRetry,
        );
    }
}
