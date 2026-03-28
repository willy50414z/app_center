import 'package:flutter/material.dart';
import '../../features/placeholder/placeholder_page.dart';
import '../../features/gps_simulator/gps_simulator_page.dart';

class FeatureItem {
  const FeatureItem({
    required this.title,
    required this.icon,
    required this.page,
  });

  final String title;
  final IconData icon;
  final Widget page;
}

class FeatureCategory {
  const FeatureCategory({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<FeatureItem> items;
}

class FeatureRegistry {
  FeatureRegistry._();

  static final List<FeatureCategory> categories = [
    FeatureCategory(
      title: '網路工具',
      icon: Icons.wifi,
      items: [
        FeatureItem(
          title: 'DNS 查詢',
          icon: Icons.dns,
          page: const PlaceholderPage(title: 'DNS 查詢'),
        ),
        FeatureItem(
          title: 'Ping 測試',
          icon: Icons.network_ping,
          page: const PlaceholderPage(title: 'Ping 測試'),
        ),
      ],
    ),
    FeatureCategory(
      title: '位置工具',
      icon: Icons.location_on,
      items: [
        FeatureItem(
          title: 'GPS 路線模擬器',
          icon: Icons.route,
          page: const GpsSimulatorPage(),
        ),
      ],
    ),
    FeatureCategory(
      title: '格式轉換',
      icon: Icons.code,
      items: [
        FeatureItem(
          title: 'JSON 格式化',
          icon: Icons.data_object,
          page: const PlaceholderPage(title: 'JSON 格式化'),
        ),
        FeatureItem(
          title: 'Base64 編解碼',
          icon: Icons.transform,
          page: const PlaceholderPage(title: 'Base64 編解碼'),
        ),
      ],
    ),
  ];

  static List<FeatureCategory> search(String keyword) {
    if (keyword.isEmpty) return categories;

    final lower = keyword.toLowerCase();
    final result = <FeatureCategory>[];

    for (final category in categories) {
      final matched = category.items
          .where((item) => item.title.toLowerCase().contains(lower))
          .toList();
      if (matched.isNotEmpty) {
        result.add(FeatureCategory(
          title: category.title,
          icon: category.icon,
          items: matched,
        ));
      }
    }

    return result;
  }
}
