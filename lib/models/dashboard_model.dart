import 'package:flutter/material.dart';

// 대시보드 통계 데이터
class DashboardStats {
  final int totalCampaigns;
  final int activeCampaigns;
  final int completedCampaigns;
  final int totalApplications;
  final int acceptedApplications;
  final double averageRating;
  final int totalEarnings;
  final int thisMonthEarnings;

  DashboardStats({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.completedCampaigns,
    required this.totalApplications,
    required this.acceptedApplications,
    required this.averageRating,
    required this.totalEarnings,
    required this.thisMonthEarnings,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalCampaigns: json['total_campaigns'] ?? 0,
        activeCampaigns: json['active_campaigns'] ?? 0,
        completedCampaigns: json['completed_campaigns'] ?? 0,
        totalApplications: json['total_applications'] ?? 0,
        acceptedApplications: json['accepted_applications'] ?? 0,
        averageRating: (json['average_rating'] ?? 0.0).toDouble(),
        totalEarnings: json['total_earnings'] ?? 0,
        thisMonthEarnings: json['this_month_earnings'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'total_campaigns': totalCampaigns,
        'active_campaigns': activeCampaigns,
        'completed_campaigns': completedCampaigns,
        'total_applications': totalApplications,
        'accepted_applications': acceptedApplications,
        'average_rating': averageRating,
        'total_earnings': totalEarnings,
        'this_month_earnings': thisMonthEarnings,
      };
}

// 차트 데이터
class ChartData {
  final String label;
  final double value;
  final Color? color;

  ChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

// 시계열 차트 데이터
class TimeSeriesData {
  final DateTime date;
  final double value;

  TimeSeriesData({
    required this.date,
    required this.value,
  });
}

// 월별 수익 데이터
class MonthlyEarning {
  final int month;
  final int year;
  final int amount;
  final int campaignCount;

  MonthlyEarning({
    required this.month,
    required this.year,
    required this.amount,
    required this.campaignCount,
  });

  String get monthName {
    const months = [
      '', '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return months[month];
  }

  factory MonthlyEarning.fromJson(Map<String, dynamic> json) => MonthlyEarning(
        month: json['month'],
        year: json['year'],
        amount: json['amount'],
        campaignCount: json['campaign_count'],
      );

  Map<String, dynamic> toJson() => {
        'month': month,
        'year': year,
        'amount': amount,
        'campaign_count': campaignCount,
      };
}

// 카테고리별 성과 데이터
class CategoryPerformance {
  final String category;
  final int campaignCount;
  final int totalEarnings;
  final double averageRating;
  final int viewCount;
  final int clickCount;

  CategoryPerformance({
    required this.category,
    required this.campaignCount,
    required this.totalEarnings,
    required this.averageRating,
    required this.viewCount,
    required this.clickCount,
  });

  double get clickRate {
    return viewCount > 0 ? (clickCount / viewCount) * 100 : 0.0;
  }

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) =>
      CategoryPerformance(
        category: json['category'],
        campaignCount: json['campaign_count'],
        totalEarnings: json['total_earnings'],
        averageRating: (json['average_rating'] ?? 0.0).toDouble(),
        viewCount: json['view_count'],
        clickCount: json['click_count'],
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'campaign_count': campaignCount,
        'total_earnings': totalEarnings,
        'average_rating': averageRating,
        'view_count': viewCount,
        'click_count': clickCount,
      };
}

// 매칭 통계 데이터
class MatchingStats {
  final int totalMatches;
  final int successfulMatches;
  final int pendingMatches;
  final int rejectedMatches;
  final double successRate;

  MatchingStats({
    required this.totalMatches,
    required this.successfulMatches,
    required this.pendingMatches,
    required this.rejectedMatches,
    required this.successRate,
  });

  factory MatchingStats.fromJson(Map<String, dynamic> json) => MatchingStats(
        totalMatches: json['total_matches'],
        successfulMatches: json['successful_matches'],
        pendingMatches: json['pending_matches'],
        rejectedMatches: json['rejected_matches'],
        successRate: (json['success_rate'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'total_matches': totalMatches,
        'successful_matches': successfulMatches,
        'pending_matches': pendingMatches,
        'rejected_matches': rejectedMatches,
        'success_rate': successRate,
      };
}

// 최근 활동 데이터
class RecentActivity {
  final String id;
  final String type; // 'campaign', 'match', 'application', 'review'
  final String title;
  final String description;
  final DateTime createdAt;
  final String? imageUrl;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.imageUrl,
  });

  IconData get icon {
    switch (type) {
      case 'campaign':
        return Icons.campaign;
      case 'match':
        return Icons.people;
      case 'application':
        return Icons.assignment;
      case 'review':
        return Icons.star;
      default:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case 'campaign':
        return Colors.blue;
      case 'match':
        return Colors.green;
      case 'application':
        return Colors.orange;
      case 'review':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
        id: json['id'],
        type: json['type'],
        title: json['title'],
        description: json['description'],
        createdAt: DateTime.parse(json['created_at']),
        imageUrl: json['image_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'image_url': imageUrl,
      };
}
