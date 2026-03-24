import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constant.dart';

class MonthYearSelector extends StatefulWidget {
  final bool showMonths;
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;

  const MonthYearSelector({
    super.key,
    this.showMonths = true,
    this.initialDate,
    this.onDateChanged,
  });

  @override
  State<MonthYearSelector> createState() => _MonthYearSelectorState();
}

class _MonthYearSelectorState extends State<MonthYearSelector> {
  late DateTime selectedMonth;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth();
    });
  }

  void _scrollToSelectedMonth() {
    if (!widget.showMonths) return;
    double offset = (selectedMonth.month - 1) * 80.0; // approx width per item
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _updateSelectedMonth(DateTime newDate) {
    setState(() {
      selectedMonth = newDate;
    });
    _scrollToSelectedMonth();
    widget.onDateChanged?.call(selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> months =
    List.generate(12, (index) => DateTime(selectedMonth.year, index + 1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // 🔹 Year Selector
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2F3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _arrowButton(Icons.arrow_back, () {
                  _updateSelectedMonth(
                      DateTime(selectedMonth.year - 1, selectedMonth.month));
                }),
                Text(
                  DateFormat('yyyy').format(selectedMonth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _arrowButton(Icons.arrow_forward, () {
                  _updateSelectedMonth(
                      DateTime(selectedMonth.year + 1, selectedMonth.month));
                }),
              ],
            ),
          ),

          if (widget.showMonths) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2F3A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: months.map((month) {
                    bool isSelected = month.month == selectedMonth.month;
                    return GestureDetector(
                      onTap: () => _updateSelectedMonth(month),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color:
                          isSelected ? Colors.amber : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat('MMM').format(month),
                          style: TextStyle(
                            color:
                            isSelected ? Colors.black : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6.5),
        decoration: BoxDecoration(
          gradient: Constant.gradientColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15),
      ),
    );
  }
}
