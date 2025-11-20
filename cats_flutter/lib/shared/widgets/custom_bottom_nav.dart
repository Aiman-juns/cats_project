import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Resources',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Training'),
        BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Assistant'),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Performance',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
      ],
    );
  }
}
