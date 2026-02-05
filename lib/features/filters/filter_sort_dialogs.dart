import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget {
  final String? selectedFilter;
  final Function(String) onFilterSelected;

  FilterDialog({this.selectedFilter, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Фільтр"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Жанр 1"),
            onTap: () {
              onFilterSelected("Жанр 1");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Жанр 2"),
            onTap: () {
              onFilterSelected("Жанр 2");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class SortDialog extends StatelessWidget {
  final String? selectedSort;
  final Function(String?) onSortSelected;

  SortDialog({this.selectedSort, required this.onSortSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Виберіть сортування'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortOption(
              context, 'За популярністю', 'popular', Icons.trending_up),
          _buildSortOption(context, 'За датою', 'date', Icons.calendar_today),
          _buildSortOption(context, 'Без сортування', null, Icons.clear),
        ],
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context, String title, String? value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selectedSort == value ? Icon(Icons.check) : null,
      onTap: () {
        onSortSelected(value);
        Navigator.pop(context);
      },
    );
  }
}
