import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomeSearch extends StatefulWidget {
  DateTime? logdate;
  String? filterLogType;

  CustomeSearch({
    super.key,
    required this.logdate,
    required this.filterLogType,
  });

  @override
  State<CustomeSearch> createState() => _CustomeSearchState();
}

class _CustomeSearchState extends State<CustomeSearch> {
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.logdate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        widget.logdate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;

        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF23262F) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                isNarrow
                    ? Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.date_range),
                              onPressed: () {
                                pickDate();
                              },
                              tooltip: 'Select Date Range',
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Filter Category',
                                  prefixIcon: const Icon(
                                    Icons.filter_alt,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor:
                                      isDark
                                          ? const Color(0xFF23262F)
                                          : Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                onChanged:
                                    (val) => setState(() {
                                      widget.filterLogType =
                                          val.trim().toLowerCase();
                                    }),
                              ),
                            ),
                          ],
                        ),
                        if (widget.logdate != null ||
                            (widget.filterLogType != null &&
                                widget.filterLogType!.isNotEmpty))
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              tooltip: 'Clear Filters',
                              splashRadius: 20,
                              onPressed:
                                  () => setState(() {
                                    widget.logdate = null;
                                    widget.filterLogType = null;
                                  }),
                            ),
                          ),
                      ],
                    )
                    : Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            pickDate();
                          },
                          tooltip: 'Select Date Range',
                          splashRadius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Filter Category',
                              prefixIcon: const Icon(
                                Icons.filter_alt,
                                size: 20,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(0xFF23262F)
                                      : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: GoogleFonts.nunito(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            onChanged:
                                (val) => setState(() {
                                  widget.filterLogType =
                                      val.trim().toLowerCase();
                                }),
                          ),
                        ),
                        if (widget.logdate != null ||
                            (widget.filterLogType != null &&
                                widget.filterLogType!.isNotEmpty))
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              tooltip: 'Clear Filters',
                              splashRadius: 20,
                              onPressed:
                                  () => setState(() {
                                    widget.logdate = null;
                                    widget.filterLogType = null;
                                  }),
                            ),
                          ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
