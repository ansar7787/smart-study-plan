import 'package:flutter/material.dart';

class KnowledgeTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const KnowledgeTabs({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'Notes'),
        Tab(text: 'Summaries'),
        Tab(text: 'Ideas'),
      ],
    );
  }
}
