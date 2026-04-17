import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/core/services/firebase_services/analytics_services.dart';

import '../providers/courts_notifier.dart';

@RoutePage()
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final AnalyticsService _analyticsService =
      AnalyticsService(FirebaseAnalytics.instance);
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courtsAsync = ref.watch(courtsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: AppStrings.courtSearchHint,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              )
            : const Text(AppStrings.courtListTitle),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: courtsAsync.when(
        data: (data) {
          final filteredCourts = data.where((court) {
            return court.name.toLowerCase().contains(_searchQuery) ||
                court.address.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredCourts.isEmpty) {
            return const Center(child: Text(AppStrings.noCourtFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: filteredCourts.length,
            itemBuilder: (context, index) {
              final court = filteredCourts[index];
              final priceFormatted = NumberFormat.currency(
                locale: 'vi_VN',
                symbol: 'đ',
              ).format(court.pricePerHour);

              return GestureDetector(
                onTap: () {
                  _analyticsService.logDetailCourt(
                    courtId: court.id,
                    courtName: court.name,
                  );
                  context.router.push(
                    CourtDetailRoute(courtId: court.id),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSizes.r20),
                          ),
                          child: Image.network(
                            court.images.isNotEmpty
                                ? court.images.first
                                : 'https://picsum.photos/400/300',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    court.name,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: AppSizes.iconLarge,
                                    ),
                                    const SizedBox(width: AppSizes.p4),
                                    Text(court.rating.toStringAsFixed(1)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p8),
                            Text(
                              court.address,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$priceFormatted${AppStrings.perHour}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSizes.bodyLarge,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.p24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppSizes.r12),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.router.push(
                                      SlotPickerRoute(
                                        courtId: court.id,
                                        courtName: court.name,
                                        courtAddress: court.address,
                                        courtImage: court.images.isNotEmpty
                                            ? court.images.first
                                            : null,
                                      ),
                                    );
                                  },
                                  child: const Text(AppStrings.orderNow),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${AppStrings.errorLoading}$err')),
      ),
    );
  }
}
