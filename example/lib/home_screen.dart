import 'package:example/sample/list_page_widget.dart';
import 'package:example/sample/page_builder.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedBottomNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<_BottomNavigationItem> bottomNavigationItems = [
      _BottomNavigationItem(
        label: 'Page list widget',
        iconData: Icons.list,
        widgetBuilder: (context) => const ListPageWidgetScreen(),
      ),
      _BottomNavigationItem(
        label: 'Page builder',
        iconData: Icons.view_quilt,
        widgetBuilder: (context) => const PageBuilderScreen(),
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavigationIndex,
        type: BottomNavigationBarType.fixed,
        items: bottomNavigationItems
            .map(
              (item) => BottomNavigationBarItem(
            icon: Icon(item.iconData),
            label: item.label,
          ),
        )
            .toList(),
        onTap: (newIndex) => setState(
              () => _selectedBottomNavigationIndex = newIndex,
        ),
      ),
      body: ScaffoldMessenger(
        child: IndexedStack(
          index: _selectedBottomNavigationIndex,
          children: bottomNavigationItems
              .map((item) => item.widgetBuilder(context))
              .toList(),
        ),
      ),
    );
  }
}

class _BottomNavigationItem {
  const _BottomNavigationItem({
    required this.label,
    required this.iconData,
    required this.widgetBuilder,
  });

  final String label;
  final IconData iconData;
  final WidgetBuilder widgetBuilder;
}