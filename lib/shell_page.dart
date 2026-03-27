import 'package:flutter/material.dart';
import 'core/navigation/app_drawer.dart';
import 'core/navigation/feature_registry.dart';
import 'features/home/home_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  Widget _currentPage = const HomePage();
  String _currentTitle = 'App Center';

  void _onFeatureSelected(FeatureItem item) {
    setState(() {
      _currentPage = item.page;
      _currentTitle = item.title;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: AppDrawer(
        selectedTitle: _currentTitle,
        onFeatureSelected: _onFeatureSelected,
      ),
      body: _currentPage,
    );
  }
}
