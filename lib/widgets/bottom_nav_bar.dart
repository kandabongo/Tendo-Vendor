import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class BottomNavBarItem {
  final List<List<dynamic>> icon;
  final String label;

  const BottomNavBarItem({required this.icon, required this.label});
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final List<BottomNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = Theme.of(context).textTheme.bodyLarge!.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;
            final color = isSelected ? activeColor : inactiveColor;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(icon: item.icon, color: color, size: 22),
                      SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
