import 'package:flutter/material.dart';

class BouncingIcon extends StatefulWidget {
  final IconData icon;
  final int delay;

  const BouncingIcon({
    super.key,
    required this.icon,
    required this.delay,
  });

  @override
  State<BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.repeat(reverse: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _animation.value),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
