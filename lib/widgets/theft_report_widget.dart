import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/theft_report_model.dart';
import '../services/user_feedback_service.dart';

class TheftReportWidget extends StatefulWidget {
  final String shelterId;

  const TheftReportWidget({
    super.key,
    required this.shelterId,
  });

  @override
  State<TheftReportWidget> createState() =>
      _TheftReportWidgetState();
}

class _TheftReportWidgetState
    extends State<TheftReportWidget> {
  late final UserFeedbackService _service;

  final TextEditingController _controller =
      TextEditingController();

  List<TheftReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _service = UserFeedbackService(
      DatabaseHelper(),
    );

    _loadReports();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final reports = await _service.getTheftReports(
      widget.shelterId,
    );

    if (!mounted) return;

    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  Future<void> _submitReport() async {
    await _service.addTheftReport(
      shelterId: widget.shelterId,
      description: _controller.text,
    );

    _controller.clear();

    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Segnala problema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Descrivi furto o problema di sicurezza...',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _submitReport,
              icon: const Icon(Icons.warning),
              label: const Text('Invia segnalazione'),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_reports.isEmpty)
              const Text('Nessuna segnalazione.')
            else
              ..._reports.map(
                (report) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning),
                  title: Text(
                    report.description ??
                        'Segnalazione di sicurezza',
                  ),
                  subtitle: Text(
                    report.createdAt.toLocal().toString(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
