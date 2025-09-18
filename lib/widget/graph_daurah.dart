// screens/daurah_screen.dart
import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/daurah_graph_report.dart';
import 'package:hotmul_quran/service/daurah_service.dart';
import 'package:hotmul_quran/widget/daurah_fl_chart.dart';
import 'package:hotmul_quran/widget/daurah_pie_chart.dart';

class DaurahScreen extends StatefulWidget {
  const DaurahScreen({Key? key}) : super(key: key);

  @override
  _DaurahScreenState createState() => _DaurahScreenState();
}

class _DaurahScreenState extends State<DaurahScreen> {
  final ApiService _apiService = ApiService();
  List<DaurahData> _daurahList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedChartType = 0; // 0: Bar Chart, 1: Pie Chart

  @override
  void initState() {
    super.initState();
    _fetchDaurahData();
  }

  Future<void> _fetchDaurahData() async {
    try {
      final data = await _apiService.getDaurahData();
      //print(data);
      setState(() {
        _daurahList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(_daurahList);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Data Daurah'),
      //   backgroundColor: Colors.blue,
      //   actions: [
      //     IconButton(icon: Icon(Icons.refresh), onPressed: _fetchDaurahData),
      //   ],
      // ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_errorMessage'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchDaurahData,
                    child: Text('Try Again'),
                  ),
                ],
              ),
            )
          : _daurahList.isEmpty
          ? Center(child: Text('No data available'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Chart Type Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('Bar Chart'),
                        selected: _selectedChartType == 0,
                        onSelected: (selected) {
                          setState(() {
                            _selectedChartType = 0;
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('Pie Chart'),
                        selected: _selectedChartType == 1,
                        onSelected: (selected) {
                          setState(() {
                            _selectedChartType = 1;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Selected Chart
                  Container(
                    height: 400,
                    child: _selectedChartType == 0
                        ? DaurahFlChart(daurahList: _daurahList)
                        : DaurahPieChart(daurahList: _daurahList),
                  ),

                  SizedBox(height: 20),
                  _buildDataTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Title')),
        DataColumn(label: Text('Participants')),
        DataColumn(label: Text('Location')),
        DataColumn(label: Text('Date')),
      ],
      rows: _daurahList.map((daurah) {
        //print(daurah.participants.toString());
        return DataRow(
          cells: [
            DataCell(Text(daurah.title)),
            DataCell(Text(daurah.participants.toString())),
            DataCell(Text(daurah.location)),
            DataCell(
              Text(
                '${daurah.startDate.day}/${daurah.startDate.month}/${daurah.startDate.year}',
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
