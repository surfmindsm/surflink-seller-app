import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color? color;
  final Color? borderColor;
  final bool allowHalfRating;
  final bool isReadOnly;
  final Function(double)? onRatingChanged;

  const StarRating({
    Key? key,
    this.rating = 0.0,
    this.starCount = 5,
    this.size = 24.0,
    this.color,
    this.borderColor,
    this.allowHalfRating = true,
    this.isReadOnly = false,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  void didUpdateWidget(StarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      _rating = widget.rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.amber;
    final borderColor = widget.borderColor ?? Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        return GestureDetector(
          onTap: widget.isReadOnly ? null : () => _onStarTapped(index),
          onPanUpdate: widget.isReadOnly ? null : (details) => _onPanUpdate(details, index),
          child: Icon(
            _getStarIcon(index),
            size: widget.size,
            color: _getStarColor(index, color, borderColor),
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int index) {
    final starValue = index + 1;
    if (_rating >= starValue) {
      return Icons.star;
    } else if (widget.allowHalfRating && _rating >= starValue - 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int index, Color filledColor, Color borderColor) {
    final starValue = index + 1;
    if (_rating >= starValue) {
      return filledColor;
    } else if (widget.allowHalfRating && _rating >= starValue - 0.5) {
      return filledColor;
    } else {
      return borderColor;
    }
  }

  void _onStarTapped(int index) {
    if (widget.isReadOnly) return;
    
    final newRating = (index + 1).toDouble();
    setState(() {
      _rating = newRating;
    });
    widget.onRatingChanged?.call(newRating);
  }

  void _onPanUpdate(DragUpdateDetails details, int index) {
    if (widget.isReadOnly || !widget.allowHalfRating) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final starWidth = widget.size;
    final totalWidth = starWidth * widget.starCount;
    
    if (localPosition.dx >= 0 && localPosition.dx <= totalWidth) {
      final newRating = (localPosition.dx / starWidth).clamp(0.0, widget.starCount.toDouble());
      final roundedRating = widget.allowHalfRating 
          ? (newRating * 2).round() / 2
          : newRating.round().toDouble();
      
      setState(() {
        _rating = roundedRating;
      });
      widget.onRatingChanged?.call(roundedRating);
    }
  }
}

// 카테고리별 평점 입력 위젯
class CategoryRatingInput extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double initialRating;
  final Function(double) onRatingChanged;

  const CategoryRatingInput({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.initialRating = 0.0,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  State<CategoryRatingInput> createState() => _CategoryRatingInputState();
}

class _CategoryRatingInputState extends State<CategoryRatingInput> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.subtitle.isNotEmpty)
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StarRating(
                rating: _rating,
                size: 28,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                  widget.onRatingChanged(rating);
                },
              ),
              Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getRatingColor(_rating),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return '매우 만족';
    if (rating >= 3.5) return '만족';
    if (rating >= 2.5) return '보통';
    if (rating >= 1.5) return '불만족';
    if (rating >= 0.5) return '매우 불만족';
    return '평가 안함';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    if (rating >= 1.0) return Colors.red;
    return Colors.grey;
  }
}

// 평점 요약 표시 위젯
class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  final Map<int, int>? scoreDistribution;
  final bool showDistribution;

  const RatingSummary({
    Key? key,
    required this.averageRating,
    required this.reviewCount,
    this.scoreDistribution,
    this.showDistribution = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // 평균 평점
          Row(
            children: [
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StarRating(
                    rating: averageRating,
                    isReadOnly: true,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$reviewCount개 리뷰',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (showDistribution && scoreDistribution != null) ...[
                const SizedBox(width: 24),
                Expanded(child: _buildDistribution()),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistribution() {
    final maxCount = scoreDistribution!.values.fold(0, (max, count) => count > max ? count : max);
    
    return Column(
      children: [5, 4, 3, 2, 1].map((star) {
        final count = scoreDistribution![star] ?? 0;
        final percentage = maxCount > 0 ? count / maxCount : 0.0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$star',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 20,
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
