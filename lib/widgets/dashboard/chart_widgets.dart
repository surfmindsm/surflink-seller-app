import 'package:flutter/material.dart';
import '../../models/dashboard_model.dart';

// 월별 수익 차트 (간단한 막대 차트)
class MonthlyEarningsChart extends StatelessWidget {
  final List<MonthlyEarning> data;
  final double height;

  const MonthlyEarningsChart({
    Key? key,
    required this.data,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final maxAmount = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '월별 수익 현황',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.map((item) {
                final normalizedHeight = (item.amount / maxAmount) * (height - 80);
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 금액 표시
                        Text(
                          _formatAmount(item.amount),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // 막대 그래프
                        Container(
                          width: double.infinity,
                          height: normalizedHeight,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // 월 표시
                        Text(
                          item.monthName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(0)}천만';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)}백만';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만';
    } else {
      return '${(amount / 1000).toStringAsFixed(0)}천';
    }
  }
}

// 카테고리별 성과 원형 차트
class CategoryPerformanceChart extends StatelessWidget {
  final List<CategoryPerformance> data;
  final double size;

  const CategoryPerformanceChart({
    Key? key,
    required this.data,
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    final totalEarnings = data.fold<int>(0, (sum, item) => sum + item.totalEarnings);

    return Column(
      children: [
        Text(
          '카테고리별 수익 분포',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            // 원형 차트
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: PieChartPainter(
                  data: data,
                  colors: colors,
                  totalEarnings: totalEarnings,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 범례
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final color = colors[index % colors.length];
                  final percentage = totalEarnings > 0 
                      ? (item.totalEarnings / totalEarnings * 100)
                      : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 원형 차트 그리기
class PieChartPainter extends CustomPainter {
  final List<CategoryPerformance> data;
  final List<Color> colors;
  final int totalEarnings;

  PieChartPainter({
    required this.data,
    required this.colors,
    required this.totalEarnings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = -90 * (3.14159 / 180); // -90도에서 시작

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final color = colors[i % colors.length];
      final sweepAngle = totalEarnings > 0 
          ? (item.totalEarnings / totalEarnings) * 2 * 3.14159
          : 0.0;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // 가운데 흰색 원 그리기
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 매칭 성공률 차트 (반원형)
class MatchingSuccessChart extends StatelessWidget {
  final MatchingStats stats;
  final double size;

  const MatchingSuccessChart({
    Key? key,
    required this.stats,
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '매칭 성공률',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          width: size,
          height: size / 2 + 20,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: Size(size, size / 2),
                painter: SemiCircleChartPainter(
                  successRate: stats.successRate,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              Positioned(
                bottom: 10,
                child: Text(
                  '${stats.successRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('성공', stats.successfulMatches, Colors.green),
            _buildStatItem('대기', stats.pendingMatches, Colors.orange),
            _buildStatItem('실패', stats.rejectedMatches, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// 반원형 차트 그리기
class SemiCircleChartPainter extends CustomPainter {
  final double successRate;
  final Color color;

  SemiCircleChartPainter({
    required this.successRate,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // 배경 반원
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      3.14159, // 180도
      3.14159, // 180도
      false,
      backgroundPaint,
    );

    // 성공률 반원
    final successPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (successRate / 100) * 3.14159;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      3.14159, // 180도에서 시작
      sweepAngle,
      false,
      successPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
