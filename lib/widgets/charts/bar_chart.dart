import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';

class AnimatedBarChart extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?>? onDateSelected;

  const AnimatedBarChart({
    super.key,
    required this.transactions,
    this.selectedDate,
    this.onDateSelected,
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatCompactVnd(double amount) {
    if (amount <= 0) return '0';
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 7 days: from 6 days ago up to today
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day - (6 - i)));

    final dailyTotals = days.map((day) {
      return widget.transactions
          .where((tx) => _isSameDay(tx.date, day))
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);
    }).toList();

    final double maxTotal = dailyTotals.fold(0.0, (max, val) => val > max ? val : max);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            // Chart bars row
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final day = days[index];
                  final total = dailyTotals[index];
                  final isSelected = widget.selectedDate != null && _isSameDay(widget.selectedDate!, day);

                  final double heightFactor = (maxTotal > 0)
                      ? ((total / maxTotal) * _animation.value).clamp(0.0, 1.0)
                      : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (isSelected) {
                            widget.onDateSelected?.call(null); // Deselect
                          } else {
                            widget.onDateSelected?.call(day); // Select day
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Compact amount badge on hover / selection / peak
                            if (isSelected && total > 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _formatCompactVnd(total),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else if (total > 0)
                              Text(
                                _formatCompactVnd(total),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                                ),
                              )
                            else
                              const SizedBox(height: 14),

                            const SizedBox(height: 2),

                            // Animated Bar Container
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: heightFactor > 0.05 ? heightFactor : 0.05,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: isSelected
                                            ? [const Color(0xFF2563EB), const Color(0xFF1E40AF)]
                                            : (total > 0
                                                ? [const Color(0xFF60A5FA), const Color(0xFF2563EB)]
                                                : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)]),
                                      ),
                                      border: isSelected
                                          ? Border.all(color: const Color(0xFF93C5FD), width: 2)
                                          : null,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Base horizontal line
            Container(
              height: 1,
              color: const Color(0xFFE2E8F0),
              margin: const EdgeInsets.only(top: 4, bottom: 6),
            ),

            // Day label row
            Row(
              children: List.generate(7, (index) {
                final day = days[index];
                final isSelected = widget.selectedDate != null && _isSameDay(widget.selectedDate!, day);
                final isToday = _isSameDay(day, now);

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isSelected) {
                        widget.onDateSelected?.call(null);
                      } else {
                        widget.onDateSelected?.call(day);
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          isToday ? 'Today' : DateFormat('dd/MM').format(day),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isToday ? 10.5 : 10,
                            fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : (isToday ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 14,
                            height: 2.5,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
