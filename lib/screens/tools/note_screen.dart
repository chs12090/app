import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:profocus/models/note.dart';
import 'package:profocus/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animations/animations.dart';
import 'package:profocus/screens/tools/timer_animation.dart';
import 'dart:convert';

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> with SingleTickerProviderStateMixin {
  final quill.QuillController _controller = quill.QuillController.basic();
  final _titleController = TextEditingController();
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
    _titleController.dispose();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
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
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        title: Text(
          'Create Note',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              closedBuilder: (context, openContainer) => IconButton(
                icon: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: TimerAnimation(controller: _animationController),
                      )
                    : Icon(Icons.save, color: colorScheme.onPrimaryContainer),
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() {
                          _isSaving = true;
                        });
                        _animationController.forward();
                        final note = Note(
                          id: Uuid().v4(),
                          title: _titleController.text.isEmpty
                              ? 'Untitled Note'
                              : _titleController.text,
                          content: jsonEncode(_controller.document.toDelta().toJson()),
                          createdAt: DateTime.now(),
                        );
                        await databaseService.createNote(note);
                        Navigator.pop(context);
                      },
              ),
              openBuilder: (context, _) => Container(),
              closedElevation: 0,
              closedColor: Colors.transparent,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.surfaceContainer,
              child: TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Note Title',
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
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: quill.QuillEditor.basic(
                  configurations: quill.QuillEditorConfigurations(
                    controller: _controller,
                    padding: EdgeInsets.all(16),
                    placeholder: 'Start writing your note...',
                    customStyles: quill.DefaultStyles(
                      paragraph: quill.DefaultTextBlockStyle(
                        TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                        quill.VerticalSpacing(8, 0),
                        quill.VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.surfaceContainer,
              child: quill.QuillToolbar(
                configurations: quill.QuillToolbarConfigurations(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      quill.QuillToolbarHistoryButton(
                        isUndo: true,
                        controller: _controller,
                      ),
                      SizedBox(width: 8),
                      quill.QuillToolbarHistoryButton(
                        isUndo: false,
                        controller: _controller,
                      ),
                      SizedBox(width: 8),
                      quill.QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: quill.Attribute.bold,
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: quill.Attribute.italic,
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: quill.Attribute.underline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}