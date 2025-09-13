import 'package:flutter/material.dart';

class PaginatedTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String> headers; // Teks header
  final List<String> fields; // Key JSON untuk data
  final int rowsPerPage;
  final int currentPage;
  final void Function(int page) onPageChanged;
  final Color headerColor;
  final Color rowColor;
  final Color? alternateRowColor;

  // Tambahan event untuk action
  final void Function(Map<String, dynamic> rowData)? onEdit;
  final void Function(Map<String, dynamic> rowData)? onDelete;

  const PaginatedTable({
    super.key,
    required this.data,
    required this.headers,
    required this.fields,
    this.rowsPerPage = 10,
    this.currentPage = 1,
    required this.onPageChanged,
    this.headerColor = Colors.blue,
    this.rowColor = Colors.white,
    this.alternateRowColor,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PaginatedTable> createState() => _PaginatedTableState();
}

class _PaginatedTableState extends State<PaginatedTable> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final start = (widget.currentPage - 1) * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage) > widget.data.length
        ? widget.data.length
        : (start + widget.rowsPerPage);
    final visibleData = widget.data.sublist(start, end);

    return Column(
      children: [
        // Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: isTablet ? screenWidth * 0.9 : screenWidth * 0.95,
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: {
                for (int i = 0; i < widget.headers.length; i++)
                  i: const IntrinsicColumnWidth(),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: widget.headerColor),
                  children: widget.headers
                      .map(
                        (h) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            h,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                // Data Rows
                for (int i = 0; i < visibleData.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: i.isEven
                          ? widget.rowColor
                          : (widget.alternateRowColor ?? widget.rowColor),
                    ),
                    children: widget.fields.map((h) {
                      final rowData = visibleData[i];
                      if (h == "action") {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => widget.onEdit?.call(rowData),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => widget.onDelete?.call(rowData),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${rowData[h] ?? ''}",
                            style: TextStyle(fontSize: isTablet ? 16 : 13),
                          ),
                        );
                      }
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Pagination Control
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: widget.currentPage > 1
                  ? () => widget.onPageChanged(widget.currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              "Page ${widget.currentPage} / ${(widget.data.length / widget.rowsPerPage).ceil()}",
            ),
            IconButton(
              onPressed: end < widget.data.length
                  ? () => widget.onPageChanged(widget.currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}
