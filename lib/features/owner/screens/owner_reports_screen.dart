import 'package:flutter/material.dart';

class OwnerReportsScreen extends StatefulWidget {
  const OwnerReportsScreen({super.key});

  @override
  State<OwnerReportsScreen> createState() => _OwnerReportsScreenState();
}

class _OwnerReportsScreenState extends State<OwnerReportsScreen> {
  bool _isGenerating = false;

  void _generateReport(String reportName) async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isGenerating = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$reportName report has been exported to PDF.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Generate detailed PDF reports for your rental business.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildReportTile('Revenue Report', 'Detailed breakdown of your earnings, platform fees, and payouts over the last 30 days.'),
          const SizedBox(height: 12),
          _buildReportTile('Rental Performance', 'Analysis of your most requested items, utilization rates, and booking durations.'),
          const SizedBox(height: 12),
          _buildReportTile('Customer Activity', 'Overview of your top renters, average ratings, and review summaries.'),
        ],
      ),
    );
  }

  Widget _buildReportTile(String title, String subtitle) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Colors.blue),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _isGenerating ? null : () => _generateReport(title),
                icon: const Icon(Icons.download),
                label: const Text('Export to PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
