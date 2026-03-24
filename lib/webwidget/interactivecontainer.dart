import 'package:flutter/material.dart';

class InteractiveContainer extends StatefulWidget {
  final Widget Function(bool isHovered) child;
  final double minWidth;
  final double minHeight;

  const InteractiveContainer({
    super.key,
    required this.child,
    this.minWidth = 50,
    this.minHeight = 50,
  });

  @override
  State<InteractiveContainer> createState() => _InteractiveContainerState();
}

class _InteractiveContainerState extends State<InteractiveContainer> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _scheduleHoverChange(true),
      onExit: (_) => _scheduleHoverChange(false),
      child: AnimatedContainer(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
        constraints: BoxConstraints(
          minWidth: widget.minWidth,
          minHeight: widget.minHeight,
        ),
        child: widget.child(_hovering),
      ),
    );
  }

  void _scheduleHoverChange(bool hovered) {
    if (_hovering != hovered) {
      // Schedule safely after the mouse tracker finishes its update phase
      Future.microtask(() {
        if (mounted) {
          setState(() => _hovering = hovered);
        }
      });
    }
  }
}
