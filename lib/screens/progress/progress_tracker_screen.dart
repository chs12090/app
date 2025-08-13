import 'package:flutter/material.dart';
import 'package:profocus/models/project.dart';
import 'package:profocus/services/database_service.dart';
import 'package:profocus/widgets/custom_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ProgressTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final databaseService = DatabaseService(userId);
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              final projects = await databaseService.getProjects();
              final pdf = await _generateProgressPdf(projects);
              final dir = await getTemporaryDirectory();
              final file = File('${dir.path}/progress.pdf');
              await file.writeAsBytes(await pdf.save());
              await Share.shareXFiles([XFile(file.path)], text: 'My ProFocus Progress');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream: databaseService.getProjectsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No progress data available.'));
          }
          final projects = snapshot.data!;
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                title: Text(project.title),
                subtitle: CustomProgressBar(progress: project.progress),
              );
            },
          );
        },
      ),
    );
  }

  Future<pw.Document> _generateProgressPdf(List<Project> projects) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('ProFocus Progress Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            for (var project in projects)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(project.title, style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Progress: ${(project.progress * 100).toStringAsFixed(0)}%'),
                  pw.SizedBox(height: 10),
                ],
              ),
          ],
        ),
      ),
    );
    return pdf;
  }
}