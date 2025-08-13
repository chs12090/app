import 'package:flutter/material.dart';
import 'package:profocus/models/project.dart';
import 'package:profocus/models/task.dart';
import 'package:profocus/services/database_service.dart';
import 'package:profocus/widgets/custom_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({required this.project});

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _taskTitleController = TextEditingController();
  final _projectTitleController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  DateTime? _selectedDeadline;
  String _selectedPriority = 'Medium';

  Future<void> _showAddProjectDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'New Project',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _projectTitleController,
                  decoration: InputDecoration(
                    labelText: 'Project Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _projectDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Low', 'Medium', 'High'].map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value ?? 'Medium';
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDeadline = picked;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedDeadline == null
                        ? 'Select Deadline'
                        : 'Deadline: ${_selectedDeadline!.toString().split(' ')[0]}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_projectTitleController.text.isNotEmpty) {
                  final userId = FirebaseAuth.instance.currentUser!.uid;
                  final databaseService = DatabaseService(userId);
                  final newProject = Project(
                    id: Uuid().v4(),
                    title: _projectTitleController.text,
                    description: _projectDescriptionController.text,
                    deadline: _selectedDeadline,
                    priority: _selectedPriority,
                    tasks: [],
                    progress: 0.0,
                  );
                  await databaseService.addProject(newProject);
                  Navigator.of(context).pop();
                  _projectTitleController.clear();
                  _projectDescriptionController.clear();
                  _selectedDeadline = null;
                  setState(() {
                    _selectedPriority = 'Medium';
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailScreen(project: newProject),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Create Project'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final databaseService = DatabaseService(userId);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          widget.project.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurface),
            onPressed: _showAddProjectDialog,
            tooltip: 'Create New Project',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.project.description.isEmpty
                          ? 'No description'
                          : widget.project.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deadline',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.project.deadline?.toString().split(' ')[0] ??
                                  'No deadline',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.project.priority,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              CustomProgressBar(
                progress: widget.project.progress,
                color: colorScheme.primary,
              ),
              SizedBox(height: 24),
              Text(
                'Tasks',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.project.tasks.length,
                  itemBuilder: (context, index) {
                    final task = widget.project.tasks[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        trailing: Checkbox(
                          value: task.isCompleted,
                          activeColor: colorScheme.primary,
                          onChanged: (value) async {
                            final updatedTask = Task(
                              id: task.id,
                              title: task.title,
                              isCompleted: value ?? false,
                              deadline: task.deadline,
                              status: value ?? false ? 'completed' : 'todo',
                            );
                            await databaseService.addTaskToProject(widget.project.id, updatedTask);
                            setState(() {
                              widget.project.tasks[index] = updatedTask;
                              widget.project.progress = widget.project.tasks.isEmpty
                                  ? 0.0
                                  : widget.project.tasks.where((t) => t.isCompleted).length /
                                      widget.project.tasks.length;
                            });
                            await databaseService.updateProject(widget.project);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _taskTitleController,
                decoration: InputDecoration(
                  labelText: 'New Task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  prefixIcon: Icon(Icons.task_alt, color: colorScheme.primary),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_taskTitleController.text.isNotEmpty) {
                    final task = Task(
                      id: Uuid().v4(),
                      title: _taskTitleController.text,
                    );
                    await databaseService.addTaskToProject(widget.project.id, task);
                    setState(() {
                      widget.project.tasks.add(task);
                      widget.project.progress = widget.project.tasks.isEmpty
                          ? 0.0
                          : widget.project.tasks.where((t) => t.isCompleted).length /
                              widget.project.tasks.length;
                    });
                    await databaseService.updateProject(widget.project);
                    _taskTitleController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Task',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _projectTitleController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }
}