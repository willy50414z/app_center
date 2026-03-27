import 'package:flutter/material.dart';
import 'feature_registry.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
    required this.selectedTitle,
    required this.onFeatureSelected,
  });

  final String selectedTitle;
  final void Function(FeatureItem item) onFeatureSelected;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = FeatureRegistry.search(_searchQuery);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜尋功能...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        '找不到相關功能',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: filtered
                          .map((category) => _buildCategory(category, theme))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(FeatureCategory category, ThemeData theme) {
    return ExpansionTile(
      leading: Icon(category.icon),
      title: Text(category.title),
      initiallyExpanded: true,
      children: category.items
          .map((item) => _buildItem(item, theme))
          .toList(),
    );
  }

  Widget _buildItem(FeatureItem item, ThemeData theme) {
    final isSelected = item.title == widget.selectedTitle;
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.secondaryContainer,
      selectedColor: theme.colorScheme.onSecondaryContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      onTap: () => widget.onFeatureSelected(item),
    );
  }
}
