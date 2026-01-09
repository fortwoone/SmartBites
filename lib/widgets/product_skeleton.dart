import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductSkeletonItem extends StatelessWidget {
    const ProductSkeletonItem({super.key});

    @override
    Widget build(BuildContext context) {
        return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                    children: [
                        Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Container(
                                        width: double.infinity,
                                        height: 16,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                        ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                        width: 120,
                                        height: 12,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                        ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                        width: 80,
                                        height: 14,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class ProductSkeletonList extends StatelessWidget {
    final int itemCount;
    
    const ProductSkeletonList({super.key, this.itemCount = 6});

    @override
    Widget build(BuildContext context) {
        return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: itemCount,
            itemBuilder: (context, index) => const ProductSkeletonItem(),
        );
    }
}
