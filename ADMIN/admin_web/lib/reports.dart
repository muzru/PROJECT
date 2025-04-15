import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final supabase = Supabase.instance.client;
  String _selectedReport = 'User Registrations';
  String _selectedPeriod = 'Last 30 Days';
  bool _isLoading = false;

  final List<String> _reportTypes = [
    'User Registrations',
    'Completed Works',
    'Active Users',
    'Disputes',
  ];

  final List<String> _timePeriods = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last Year',
  ];

  // Store fetched data
  List<Map<String, dynamic>> _registrationData = [];
  List<Map<String, dynamic>> _completedWorksData = [];
  Map<String, int> _userTypeData = {};
  Map<String, int> _disputeStatusData = {};

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      DateTime startDate = _getStartDate(_selectedPeriod, now);

      // Fetch User Registrations (Freelancers + Clients)
      final freelancers = await supabase
          .from('tbl_freelancer')
          .select('freelancer_id, created_at')
          .gte('created_at', startDate.toIso8601String());
      final clients = await supabase
          .from('tbl_client')
          .select('client_id, created_at')
          .gte('created_at', startDate.toIso8601String());
      _registrationData = [
        ...freelancers.map((f) {
          final date = DateTime.parse(f['created_at'] as String);
          return {'date': date, 'count': 1};
        }),
        ...clients.map((c) {
          final date = DateTime.parse(c['created_at'] as String);
          return {'date': date, 'count': 1};
        }),
      ];
      _registrationData.sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      debugPrint('Registration Data: $_registrationData');

      // Fetch Completed Works (Using work_status or workrequest_status as proxy)
      _completedWorksData = await supabase
          .from('tbl_work')
          .select('work_id, created_at, work_status')
          .gte('created_at', startDate.toIso8601String())
          .eq('work_status', 1); // Assuming 1 means completed
      _completedWorksData = _completedWorksData.map((w) {
        final date = DateTime.parse(w['created_at'] as String);
        return {'date': date, 'count': 1};
      }).toList();
      _completedWorksData.sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      debugPrint('Completed Works Data: $_completedWorksData');

      // Alternative: Use workrequest if work_status is not reliable
      if (_completedWorksData.isEmpty) {
        final workRequests = await supabase
            .from('tbl_workrequest')
            .select('workrequest_id, created_at, work_id, workrequest_status')
            .gte('created_at', startDate.toIso8601String())
            .eq('workrequest_status', 4); // Assuming 4 means completed
        _completedWorksData = workRequests.map((wr) {
          final date = DateTime.parse(wr['created_at'] as String);
          return {'date': date, 'count': 1};
        }).toList();
        _completedWorksData.sort(
            (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      }
      debugPrint(
          'Completed Works Data (via workrequest): $_completedWorksData');

      // Fetch Active Users (Using created_at as a proxy for activity)
      final activeFreelancers = await supabase
          .from('tbl_freelancer')
          .select('freelancer_id')
          .gte('created_at', startDate.toIso8601String());
      final activeClients = await supabase
          .from('tbl_client')
          .select('client_id')
          .gte('created_at', startDate.toIso8601String());
      _userTypeData = {
        'Freelancers': activeFreelancers.length,
        'Clients': activeClients.length,
      };
      debugPrint('User Type Data: $_userTypeData');

      // Fetch Disputes (Updated for status 0 = Pending, 1 = Solved)
      final disputes = await supabase
          .from('tbl_complaint')
          .select('id, created_at, complaint_status')
          .gte('created_at', startDate.toIso8601String());
      _disputeStatusData = {
        'Pending': disputes.where((d) => d['complaint_status'] == 0).length,
        'Solved': disputes.where((d) => d['complaint_status'] == 1).length,
      };
      debugPrint('Dispute Status Data: $_disputeStatusData');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching report data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching report data: $e"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DateTime _getStartDate(String period, DateTime now) {
    switch (period) {
      case 'Last 7 Days':
        return now.subtract(const Duration(days: 7));
      case 'Last 30 Days':
        return now.subtract(const Duration(days: 30));
      case 'Last 3 Months':
        return now.subtract(const Duration(days: 90));
      case 'Last Year':
        return now.subtract(const Duration(days: 365));
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  Future<void> _downloadReportAsPDF() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$_selectedReport Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('Period: $_selectedPeriod',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
            pw.SizedBox(height: 20),
            pw.Text('Data Summary:', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            _selectedReport == 'User Registrations' ||
                    _selectedReport == 'Completed Works'
                ? pw.ListView.builder(
                    itemCount: _registrationData.length,
                    itemBuilder: (context, index) {
                      final item = _registrationData[index];
                      return pw.Text(
                          '${DateFormat('MM/dd/yyyy').format(item['date'] as DateTime)}: ${item['count']}');
                    },
                  )
                : _selectedReport == 'Active Users'
                    ? pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: _userTypeData.entries.map((entry) {
                          return pw.Row(
                            children: [
                              pw.Text('${entry.key}: ',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${entry.value}'),
                            ],
                          );
                        }).toList(),
                      )
                    : _selectedReport == 'Disputes'
                        ? pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: _disputeStatusData.entries.map((entry) {
                              return pw.Row(
                                children: [
                                  pw.Text('${entry.key}: ',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                  pw.Text('${entry.value}'),
                                ],
                              );
                            }).toList(),
                          )
                        : pw.Text('No data available'),
          ],
        );
      },
    ));

    final bytes = await pdf.save();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
          'download', 'report_${DateTime.now().millisecondsSinceEpoch}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Report Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedReport,
                      items: _reportTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedReport = newValue;
                            _fetchReportData();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Time Period',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedPeriod,
                      items: _timePeriods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPeriod = newValue;
                            _fetchReportData();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _fetchReportData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_selectedReport Report',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _downloadReportAsPDF,
                                icon: const Icon(Icons.download),
                                label: const Text('Download PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Period: $_selectedPeriod',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _buildReportContent(),
                          ),
                        ],
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReport) {
      case 'User Registrations':
        return _buildLineChart(
          _registrationData,
          'User Registrations',
          'Number of new users',
          'count',
          Colors.blue,
        );
      case 'Completed Works':
        return _buildLineChart(
          _completedWorksData,
          'Completed Works',
          'Number of completed works',
          'count',
          Colors.green,
        );
      case 'Active Users':
        return _buildPieChart(
          _userTypeData,
          'Active Users by Type',
          {
            'Freelancers': Colors.blue,
            'Clients': Colors.green,
          },
        );
      case 'Disputes':
        return _buildPieChart(
          _disputeStatusData,
          'Disputes by Status',
          {
            'Pending': Colors.orange,
            'Solved': Colors.green,
          },
        );
      default:
        return const Center(
          child: Text('No data available for this report'),
        );
    }
  }

  Widget _buildLineChart(
    List<Map<String, dynamic>> data,
    String title,
    String yAxisLabel,
    String valueKey,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          yAxisLabel,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= data.length || value.toInt() < 0) {
                        return const SizedBox();
                      }
                      final date = data[value.toInt()]['date'] as DateTime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('MM/dd').format(date),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              minX: 0,
              maxX: data.length > 0 ? data.length - 1.0 : 0,
              minY: 0,
              maxY: data.isNotEmpty
                  ? data
                          .map((item) => item[valueKey] as num)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2
                  : 10,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return FlSpot(
                      index.toDouble(),
                      (item[valueKey] as num).toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
              'Total',
              data.isNotEmpty
                  ? data
                      .map((item) => item[valueKey] as num)
                      .reduce((a, b) => a + b)
                      .toString()
                  : '0',
              Icons.calculate,
              Colors.blue,
            ),
            _buildStatCard(
              'Average',
              data.isNotEmpty
                  ? (data
                              .map((item) => item[valueKey] as num)
                              .reduce((a, b) => a + b) /
                          data.length)
                      .toStringAsFixed(2)
                  : '0.00',
              Icons.trending_up,
              Colors.green,
            ),
            _buildStatCard(
              'Highest',
              data.isNotEmpty
                  ? data
                      .map((item) => item[valueKey] as num)
                      .reduce((a, b) => a > b ? a : b)
                      .toString()
                  : '0',
              Icons.arrow_upward,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(
    Map<String, int> data,
    String title,
    Map<String, Color> colorMap,
  ) {
    final total = data.values.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: data.entries.map((entry) {
                      final percentage =
                          (entry.value / total * 100).toStringAsFixed(1);
                      return PieChartSectionData(
                        color: colorMap[entry.key] ?? Colors.grey,
                        value: entry.value.toDouble(),
                        title: '$percentage%',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...data.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colorMap[entry.key] ?? Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${entry.value})',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Text(
                      'Total: $total',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
