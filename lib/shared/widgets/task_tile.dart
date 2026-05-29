import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// One row in the daily checklist. Tap the circle to toggle done.
class TaskTile extends StatelessWidget {
  final String label;
  final String instructions;
  final int minutes;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final IconData icon;

  const TaskTile({
    super.key,
    required this.label,
    required this.instructions,
    required this.minutes,
    required this.done,
    required this.onToggle,
    required this.onOpen,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final strike = done
        ? TextDecoration.lineThrough
        : TextDecoration.none;
    final ink = done ? AppColors.inkSecondary : AppColors.ink;

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onToggle,
              child: _CircleCheck(done: done),
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 20, color: AppColors.inkSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ink,
                      decoration: strike,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    instructions,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkSecondary,
                      decoration: strike,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$minutes د',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleCheck extends StatelessWidget {
  final bool done;
  const _CircleCheck({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: done ? AppColors.primary : AppColors.line,
          width: 1.5,
        ),
      ),
      child: done
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
