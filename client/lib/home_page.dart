import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.username});
  final String username;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes().then((fetchedNotes) {
      setState(() {
        notes = fetchedNotes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('${widget.username}\'s Notes'),
        ),
        body: Center(
            child: RefreshIndicator(
          child: notes.isEmpty
              ? Column(children: [
                  const Text('No notes found.'),
                  ElevatedButton(
                      onPressed: () {
                        _fetchNotes().then((fetchedNotes) {
                          setState(() {
                            notes = fetchedNotes;
                          });
                        });
                      },
                      child: const Text('Refresh'))
                ])
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: notes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Center(child: Text(notes[index].title)),
                      subtitle: Center(child: Text(notes[index].body)),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  physics: const AlwaysScrollableScrollPhysics(),
                ),
          onRefresh: () {
            return Future.delayed(
              const Duration(seconds: 1),
              () {
                _fetchNotes().then((fetchedNotes) {
                  setState(() {
                    notes = fetchedNotes;
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yay! A SnackBar!')));
              },
            );
          },
        )));
  }
}

class Note {
  final String title;
  final String body;

  const Note({
    required this.title,
    required this.body,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'title': String title,
        'body': String body,
      } =>
        Note(title: title, body: body),
      _ => throw const FormatException('Failed to load note.'),
    };
  }
}

Future<List<Note>> _fetchNotes() async {
  final response = await http.get(Uri.parse('http://localhost:8080/api/notes'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final List notesJson = json.decode(response.body);
    final List<Note> notes =
        notesJson.map((item) => Note.fromJson(item)).toList();
    return notes;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load note.');
  }
}
