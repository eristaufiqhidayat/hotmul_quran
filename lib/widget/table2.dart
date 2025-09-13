import 'package:flutter/material.dart';

class VerticalDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> headers;
  final List<String> fields;

  final int currentPage;
  final int lastPage;
  final int rowsPerPage;

  final VoidCallback? onRefresh;
  final VoidCallback? onNew;
  final Function(int page) onPageChanged;
  final Function(String value)? onSearch;

  final Color headerColor;
  final Color rowColor;
  final Color alternateRowColor;

  final Function(Map<String, dynamic> row)? onEdit;
  final Function(Map<String, dynamic> row)? onDelete;

  const VerticalDataTable({
    super.key,
    required this.data,
    required this.headers,
    required this.fields,
    required this.currentPage,
    required this.lastPage,
    this.rowsPerPage = 10,
    this.onRefresh,
    this.onNew,
    required this.onPageChanged,
    this.onSearch,
    this.headerColor = Colors.blueGrey,
    this.rowColor = Colors.white,
    this.alternateRowColor = const Color(0xFFF7F7F7),
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),

        // Tombol Refresh + Add
        Row(
          children: [
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
            const SizedBox(width: 2),
            ElevatedButton.icon(
              onPressed: onNew,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "New",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 40,
            child: TextField(
              onSubmitted: onSearch,
              decoration: InputDecoration(
                hintText: 'Search....',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
          ),
        ),

        // Daftar data (vertical layout)
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, rowIndex) {
              final row = data[rowIndex];
              final isAlt = rowIndex % 2 == 1;

              return Card(
                color: isAlt ? alternateRowColor : rowColor,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(headers.length, (colIndex) {
                      final header = headers[colIndex];
                      final field = fields[colIndex];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              padding: const EdgeInsets.all(6),
                              color: headerColor.withOpacity(0.1),
                              child: Text(
                                header,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: headerColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: field == "action"
                                  ? Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () => onEdit?.call(row),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => onDelete?.call(row),
                                        ),
                                      ],
                                    )
                                  : Text("${row[field] ?? ''}"),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),

        // Pagination kontrol
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: currentPage > 1
                  ? () => onPageChanged(currentPage - 1)
                  : null,
              icon: const Icon(Icons.arrow_back),
            ),
            Text("Page $currentPage / $lastPage"),
            IconButton(
              onPressed: currentPage < lastPage
                  ? () => onPageChanged(currentPage + 1)
                  : null,
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ],
    );
  }
}
