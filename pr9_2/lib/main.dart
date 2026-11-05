import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database/database_helper.dart';
import 'screens/course_details_screen.dart';
import 'utils/database_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite initialization for macOS.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialize database and insert demo data.
  await DatabaseHelper.instance.database;
  await DatabaseSeeder.seedDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Grade Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grade Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getSemesters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Database error: ${snapshot.error}'));
          }

          final semesters = snapshot.data ?? [];

          if (semesters.isEmpty) {
            return const Center(child: Text('No semesters found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'My Semesters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ...semesters.map((semester) {
                final semesterId = semester['id'] as int;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const Icon(Icons.school),
                    title: Text(semester['name'].toString()),
                    subtitle: Text(
                      '${semester['start_date']} — '
                      '${semester['end_date']}',
                    ),
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseHelper.instance.getCourses(semesterId),
                        builder: (context, courseSnapshot) {
                          if (courseSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (courseSnapshot.hasError) {
                            return const ListTile(
                              title: Text('Error loading courses'),
                            );
                          }

                          final courses = courseSnapshot.data ?? [];

                          if (courses.isEmpty) {
                            return const ListTile(
                              title: Text('No courses found'),
                            );
                          }

                          return Column(
                            children: courses.map((course) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.menu_book,
                                  color: Colors.indigo,
                                ),
                                title: Text(course['name'].toString()),
                                subtitle: Text(
                                  '${course['code']} • '
                                  '${course['credits']} credits',
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CourseDetailsScreen(course: course),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
