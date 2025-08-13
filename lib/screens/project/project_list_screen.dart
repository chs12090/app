import 'package:flutter/material.dart';
import 'package:profocus/models/project.dart';
import 'package:profocus/services/database_service.dart';
import 'package:profocus/screens/project/project_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:animations/animations.dart';
import 'package:profocus/widgets/timer_animation.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> with SingleTickerProviderStateMixin {
  final _projectTitleController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  DateTime? _selectedDeadline;
  String _selectedPriority = 'Medium';
  late AnimationController _animationController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reset();
          setState(() {
            _isSaving = false;
          });
        }
      });
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    _projectDescriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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
          backgroundColor: colorScheme.surfaceContainer,
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
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Project Title',
                    hintText: 'Enter project title',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _projectDescriptionController,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter project description',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    hintText: 'Select priority',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: ['Low', 'Medium', 'High'].map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(
                        priority,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
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
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: colorScheme,
                            textTheme: Theme.of(context).textTheme,
                          ),
                          child: child!,
                        );
                      },
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
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    _selectedDeadline == null
                        ? 'Select Deadline'
                        : 'Deadline: ${_selectedDeadline!.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
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
            OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              closedBuilder: (context, openContainer) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(120, 50),
                ),
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_projectTitleController.text.isNotEmpty) {
                          setState(() {
                            _isSaving = true;
                          });
                          _animationController.forward();
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
                          _projectTitleController.clear();
                          _projectDescriptionController.clear();
                          _selectedDeadline = null;
                          setState(() {
                            _selectedPriority = 'Medium';
                            _isSaving = false;
                          });
                          _animationController.reset();
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  ProjectDetailScreen(project: newProject),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  )),
                                  child: child,
                                );
                              },
                              transitionDuration: Duration(milliseconds: 300),
                            ),
                          );
                        }
                      },
                child: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: TimerAnimation(controller: _animationController),
                      )
                    : Text(
                        'Create Project',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
              openBuilder: (context, _) => Container(),
              closedElevation: 0,
              closedColor: Colors.transparent,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        elevation: 0,
        title: Text(
          'Projects',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Your Projects',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: StreamBuilder<List<Project>>(
                  stream: databaseService.getProjectsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading projects',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.error,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No projects found. Create one to get started!',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final projects = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: colorScheme.surfaceContainer,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            title: Text(
                              project.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  'Progress: ${(project.progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (project.deadline != null)
                                  Text(
                                    'Deadline: ${project.deadline!.toString().split(' ')[0]}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    ProjectDetailScreen(project: project),
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    )),
                                    child: child,
                                  );
                                },
                                transitionDuration: Duration(milliseconds: 300),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}