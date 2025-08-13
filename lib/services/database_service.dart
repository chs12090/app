import 'package:firebase_database/firebase_database.dart';
import 'package:profocus/models/project.dart';
import 'package:profocus/models/task.dart';
import 'package:profocus/models/flashcard.dart';
import 'package:profocus/models/note.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String userId;

  DatabaseService(this.userId);

  // Project CRUD
  Future<void> addProject(Project project) async {
    try {
      await _db
          .child('users/$userId/projects/${project.id}')
          .set(project.toJson());
    } catch (e) {
      throw Exception('Failed to add project: $e');
    }
  }

  Stream<List<Project>> getProjectsStream() {
    return _db.child('users/$userId/projects').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        final projectData = Map<String, dynamic>.from(entry.value);
        projectData['id'] = entry.key; // Ensure ID is included
        return Project.fromJson(projectData);
      }).toList();
    });
  }

  Future<List<Project>> getProjects() async {
    try {
      final snapshot = await _db.child('users/$userId/projects').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          final projectData = Map<String, dynamic>.from(entry.value);
          projectData['id'] = entry.key; // Ensure ID is included
          return Project.fromJson(projectData);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _db
          .child('users/$userId/projects/${project.id}')
          .update(project.toJson());
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _db.child('users/$userId/projects/$projectId').remove();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  // Task CRUD
  Future<void> addTaskToProject(String projectId, Task task) async {
    try {
      // Fetch current project to update tasks list
      final snapshot = await _db.child('users/$userId/projects/$projectId').get();
      if (snapshot.exists) {
        final projectData = Map<String, dynamic>.from(snapshot.value as Map);
        List<dynamic> tasks = projectData['tasks'] ?? [];
        // Check if task already exists to update it
        final taskIndex =
            tasks.indexWhere((t) => Map<String, dynamic>.from(t)['id'] == task.id);
        if (taskIndex >= 0) {
          tasks[taskIndex] = task.toJson();
        } else {
          tasks.add(task.toJson());
        }
        await _db.child('users/$userId/projects/$projectId').update({
          'tasks': tasks,
        });
      } else {
        // If project doesn't exist, create it with the task
        await _db.child('users/$userId/projects/$projectId').set({
          'tasks': [task.toJson()],
        });
      }
    } catch (e) {
      throw Exception('Failed to add task to project: $e');
    }
  }

  Future<void> deleteTaskFromProject(String projectId, String taskId) async {
    try {
      final snapshot = await _db.child('users/$userId/projects/$projectId').get();
      if (snapshot.exists) {
        final projectData = Map<String, dynamic>.from(snapshot.value as Map);
        List<dynamic> tasks = projectData['tasks'] ?? [];
        tasks.removeWhere((t) => Map<String, dynamic>.from(t)['id'] == taskId);
        await _db.child('users/$userId/projects/$projectId').update({
          'tasks': tasks,
        });
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Flashcard CRUD
  Future<void> createFlashcard(Flashcard flashcard) async {
    try {
      await _db
          .child('users/$userId/flashcards/${flashcard.id}')
          .set(flashcard.toJson());
    } catch (e) {
      throw Exception('Failed to create flashcard: $e');
    }
  }

  Stream<List<Flashcard>> getFlashcardsStream() {
    return _db.child('users/$userId/flashcards').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        final flashcardData = Map<String, dynamic>.from(entry.value);
        flashcardData['id'] = entry.key; // Ensure ID is included
        return Flashcard.fromJson(flashcardData);
      }).toList();
    });
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    try {
      await _db
          .child('users/$userId/flashcards/${flashcard.id}')
          .update(flashcard.toJson());
    } catch (e) {
      throw Exception('Failed to update flashcard: $e');
    }
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    try {
      await _db.child('users/$userId/flashcards/$flashcardId').remove();
    } catch (e) {
      throw Exception('Failed to delete flashcard: $e');
    }
  }

  // Note CRUD
  Future<void> createNote(Note note) async {
    try {
      await _db
          .child('users/$userId/notes/${note.id}')
          .set(note.toJson());
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Stream<List<Note>> getNotesStream() {
    return _db.child('users/$userId/notes').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        final noteData = Map<String, dynamic>.from(entry.value);
        noteData['id'] = entry.key; // Ensure ID is included
        return Note.fromJson(noteData);
      }).toList();
    });
  }

  Future<void> updateNote(Note note) async {
    try {
      await _db
          .child('users/$userId/notes/${note.id}')
          .update(note.toJson());
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _db.child('users/$userId/notes/$noteId').remove();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}