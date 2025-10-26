import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/map_models.dart';

class LocationDetailsBottomSheet extends StatefulWidget {
  final TruckLocation location;
  final List<LocationReview> reviews;
  final ParkingStatusUpdate? latestParkingStatus;
  final bool isFavorite;
  final Function(bool) onFavoriteToggle;
  final Function(ParkingStatus) onParkingStatusUpdate;
  final VoidCallback onAddReview;

  const LocationDetailsBottomSheet({
    super.key,
    required this.location,
    required this.reviews,
    this.latestParkingStatus,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onParkingStatusUpdate,
    required this.onAddReview,
  });

  @override
  State<LocationDetailsBottomSheet> createState() => _LocationDetailsBottomSheetState();
}

class _LocationDetailsBottomSheetState extends State<LocationDetailsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final averageRating = _calculateAverageRating();
    
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header with name and favorite button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.location.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.location.address,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => widget.onFavoriteToggle(!widget.isFavorite),
                          icon: Icon(
                            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: widget.isFavorite ? AppColors.errorRed : AppColors.grey500,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Rating section
                    if (widget.reviews.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.warningYellow,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${widget.reviews.length} reviews)',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Parking status section
                    _buildParkingStatusSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showParkingStatusDialog,
                            icon: const Icon(Icons.update),
                            label: const Text('Update Parking'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onAddReview,
                            icon: const Icon(Icons.rate_review),
                            label: const Text('Add Review'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Reviews section
                    if (widget.reviews.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text(
                            'Recent Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // TODO: Show all reviews
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...widget.reviews.take(3).map((review) => _buildReviewCard(review)),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 48,
                              color: AppColors.grey500,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No reviews yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Be the first to review this location!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParkingStatusSection() {
    final status = widget.latestParkingStatus;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_parking,
                color: AppColors.grey700,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Parking Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (status != null) ...[
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getParkingStatusColor(status.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getParkingStatusText(status.status),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _getParkingStatusColor(status.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Updated ${_formatTimeAgo(status.timestamp)}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
              ),
            ),
          ] else ...[
            Text(
              'No recent parking updates',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewCard(LocationReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryBlue,
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: AppColors.warningYellow,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(review.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showParkingStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Parking Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How is the parking situation at ${widget.location.name}?',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 20),
            ...ParkingStatus.values.map((status) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onParkingStatusUpdate(status);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getParkingStatusColor(status),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getParkingStatusText(status),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  double _calculateAverageRating() {
    if (widget.reviews.isEmpty) return 0.0;
    final sum = widget.reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return sum / widget.reviews.length;
  }

  Color _getParkingStatusColor(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return AppColors.successGreen;
      case ParkingStatus.fewSpotsLeft:
        return AppColors.warningYellow;
      case ParkingStatus.full:
        return AppColors.errorRed;
    }
  }

  String _getParkingStatusText(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return 'Spots Available';
      case ParkingStatus.fewSpotsLeft:
        return 'Few Spots Left';
      case ParkingStatus.full:
        return 'Lot Full';
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}