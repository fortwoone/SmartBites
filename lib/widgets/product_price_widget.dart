import 'package:flutter/material.dart';
import '../models/product_price.dart';
import '../repositories/openfoodfacts_repository.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class ProductPriceWidget extends StatelessWidget {
  final String barcode;
  final OpenFoodFactsRepository repository;
  final bool compact;

  ProductPriceWidget({
    super.key,
    required this.barcode,
    OpenFoodFactsRepository? repository,
    this.compact = false,
  }) : repository = repository ?? OpenFoodFactsRepository();

  String _formatDate(DateTime dt) {
    if (dt.millisecondsSinceEpoch == 0) return '-';
    try {
      final location = tz.getLocation('Europe/Paris');
      final tzDate = tz.TZDateTime.from(dt.toUtc(), location);
      return DateFormat('dd/MM/yyyy').format(tzDate);
    } catch (e) {
      final local = dt.toLocal();
      return DateFormat('dd/MM/yyyy').format(local);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductPrice?>(
      future: repository.getLatestPrice(barcode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return compact
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const CircularProgressIndicator();
        }

        if (snapshot.hasData && snapshot.data != null) {
          final price = snapshot.data!;

          if (compact) {
            return Text(
              '${price.price.toStringAsFixed(2)} ${price.currency}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 14,
              ),
            );
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prix',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${price.price.toStringAsFixed(2)} ${price.currency}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (price.storeName != null && price.storeName!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.store, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            price.storeName!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (price.location.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            price.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(price.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return compact
            ? const Text(
                '-',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
