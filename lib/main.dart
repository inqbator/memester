/*
Instructions/Notes (sorry not in order):
Installing flutter/dart: https://flutter.io/docs/get-started/install
Android deployment instructions are here: https://flutter.io/docs/deployment/android
What not to commit https://www.dartlang.org/guides/libraries/private-files
How to return a function in dart https://stackoverflow.com/questions/51490066/how-to-return-function-in-dart
Next steps yolo https://codelabs.developers.google.com/codelabs/first-flutter-app-pt2/#8
Had to add all of the below to ~/.profile for my VirtualBox to detect this stuff. Also tinker around in Box's USB settings and add your phones for adb passthrough to work.
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:/home/bahrom/mobile/flutter/bin
export JAVA_HOME=/home/bahrom/Desktop/android-studio/jre
*/

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Welcome to Memester',
      theme: new ThemeData(
// How the fuck do I change the color of the list items????
        primaryColor: Colors.blue,     // changes overall theme
//        accentColor: Colors.white,   // doesn't do shit
//        backgroundColor: Colors.red, // doesn't do shit
        canvasColor: Colors.red,       // changes content background
        dividerColor: Colors.white,    // changes dividers to white (obvious, I know)
//        hintColor: Colors.pink,      // doesn't do shit
      ),
      home: new RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = new Set<WordPair>();
  final Set<WordPair> _trashed = new Set<WordPair>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0, color: Colors.white); // this fixed content text (remember to occasionally cold restart)
//  final TextStyle _savedFont = const TextStyle(fontSize: 18.0, color: Colors.red);

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      // The itemBuilder callback is called once per suggested word pairing, and places each suggestion into a ListTile row.
      // Fpr even rows, the function adds a ListTile row for the word pairing. For odd rows, the function adds a Divider widget to visually separate the entries.
      // Note that the divider may be difficult to see on smaller devices.
      itemBuilder: (context, i) {
        // Add a one-pixel-high divider widget before each row in theListView.
        if (i.isOdd) return Divider();

        // "i ~/2 is integer division by 2
        final index = i ~/ 2;
        // if you've reached the end of available word pairings...
        if (index >= _suggestions.length) {
          //... then generate 10 more and add them to the suggestions.
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final bool saved = _saved.contains(pair);
    final bool trashed = _trashed.contains(pair);
    void _toggle (contains, set) {
      (contains ? set.remove : set.add)(pair);
    }
    final IconButton favIconBtn = new IconButton(
        icon: new Icon(saved ? Icons.favorite : Icons.favorite_border, color: saved ? Colors.red : null),
        onPressed: () => setState(() => _toggle(saved, _saved)),
    );
    final IconButton trashIconBtn = new IconButton(
      icon: new Icon(trashed ? Icons.delete : Icons.delete_outline, color: trashed ? Colors.black : null),
      onPressed: () => setState(() => (_toggle(trashed, _trashed))),
    );
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,  // not including this fucks padding/alignment in rows
        children: [favIconBtn, trashIconBtn],
      ),
//      onTap: () => setState(() => (saved ? _saved.remove : _saved.add)(pair)), //TODO change to something more fun when tapping the row
    );
  }

  Function _viewPusher(header, Iterable<WordPair> items) {
    void _pushSavedToView() {
      Navigator.of(context).push(
          new MaterialPageRoute<void>(
              builder: (BuildContext context) {
                final Iterable<ListTile> tiles = items.map(
                      (WordPair pair) {
                    return new ListTile(
                      title: new Text(pair.asPascalCase, style: _biggerFont),
                    );
                  },
                );
                final List<Widget> divided = ListTile.divideTiles(context: context, tiles: tiles).toList();
                return new Scaffold(
                  appBar: new AppBar(
                    title: Text(header),
                  ),
                  body: new ListView(children: divided),
                );
              }
          )
      );
    }
    return _pushSavedToView;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Meme Generator'),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.list), onPressed: _viewPusher('Saved memes!', _saved),),
          new IconButton(icon: const Icon(Icons.delete), onPressed: _viewPusher('Deleted memes!', _trashed),),
        ],
      ),
      body: _buildSuggestions(),
      backgroundColor: Colors.blueGrey, //overrides canvasColor: Colors.red
    );
  }
}