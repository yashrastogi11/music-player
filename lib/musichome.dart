import 'dart:async';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:music_player/database/database_client.dart';
import 'package:music_player/pages/material_search.dart';
import 'package:music_player/pages/now_playing.dart';
import 'package:music_player/pages/settings.dart';
import 'package:music_player/util/lastplay.dart';
import 'package:music_player/views/album.dart';
import 'package:music_player/views/artists.dart';
import 'package:music_player/views/home.dart';
import 'package:music_player/views/playlists.dart';
import 'package:music_player/views/songs.dart';

class MusicHome extends StatefulWidget {
  List<Song> songs;
  MusicHome();
  final bottomItems = [
    new BottomItem("Home", Icons.home),
    new BottomItem("Albums", Icons.album),
    new BottomItem("Songs", Icons.music_note),
    new BottomItem("Artists", Icons.person),
    new BottomItem("PlayList", Icons.playlist_add_check),
  ];
  @override
  State<StatefulWidget> createState() {
    return new _musicState();
  }
}

class _musicState extends State<MusicHome> {
  int _selectedDrawerIndex = 0;
  List<Song> songs;
  String title = "Music player";
  DatabaseClient db;
  bool isLoading = true;
  Song last;
  Color color = Colors.deepPurple;
  var themeLoading = true;

  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new Home(db);
      case 2:
        return new Songs(db);
      case 3:
        return new Artists(db);
      case 1:
        return new Album(db);
      case 4:
        return new PlayList(db);
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    getDrawerItemWidget(_selectedDrawerIndex);
    title = widget.bottomItems[index].title;
  }

  @override
  void initState() {
    super.initState();
    getLast();
  }

  // void initPlayer() async {
  //   db = new DatabaseClient();
  //   await db.create();
  //   if (await db.alreadyLoaded()) {
  //     setState(() {
  //       isLoading = false;
  //       getLast();
  //     });
  //   } else {
  //     var songs;
  //     try {
  //       songs = await MusicFinder.allSongs();
  //     } catch (e) {
  //       print("failed to get songs");
  //     }
  //     List<Song> list = new List.from(songs);
  //     for (Song song in list) db.upsertSOng(song);
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {
  //       isLoading = false;
  //       getLast();
  //     });
  //   }
  // }

  // getSharedData() async {
  //   const platform = const MethodChannel('app.channel.shared.data');
  //   Map sharedData = await platform.invokeMethod("getSharedData");
  //   if (sharedData != null) {
  //     if (sharedData["albumArt"] == "null") {
  //       sharedData["albumArt"] = null;
  //     }
  //     Song song = new Song(
  //         9999 /*random*/,
  //         sharedData["artist"],
  //         sharedData["title"],
  //         sharedData["album"],
  //         null,
  //         int.parse(sharedData["duration"]),
  //         sharedData["uri"],
  //         sharedData["albumArt"]);
  //     List<Song> list = new List();
  //     list.add((song));
  //     MyQueue.songs = list;
  //     Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
  //       return new NowPlaying(null, list, 0, 0);
  //     }));
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
  }

  void getLast() async {
    db = new DatabaseClient();
    await db.create();
    last = await db.fetchLastSong();
    songs = await db.fetchSongs();
    setState(() {
      songs = songs;
      isLoading = false;
    });
  }

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    var bottomOptions = <BottomNavigationBarItem>[];
    for (var i = 0; i < widget.bottomItems.length; i++) {
      var d = widget.bottomItems[i];
      bottomOptions.add(
        new BottomNavigationBarItem(
          icon: new Icon(
            d.icon,
          ),
          title: new Text(d.title),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
    return new WillPopScope(
      child: new Scaffold(
        key: scaffoldState,
        appBar: _selectedDrawerIndex == 0
            ? null
            : new AppBar(
                title: new Text(title),
                actions: <Widget>[
                  new IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        Navigator.of(context)
                            .push(new MaterialPageRoute(builder: (context) {
                          return new SearchSong(db, songs);
                        }));
                      })
                ],
              ),
        floatingActionButton: new FloatingActionButton(
            child: new Icon(Icons.play_circle_filled),
            onPressed: () async {
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                if (MyQueue.songs == null) {
                  List<Song> list = new List();
                  list.add(last);
                  MyQueue.songs = list;
                  return new NowPlaying(db, list, 0, 0);
                } else
                  return new NowPlaying(db, MyQueue.songs, MyQueue.index, 1);
              }));
              //}
            }),
        drawer: new Drawer(
          child: new Column(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountName: new Text(
                  "Music Player",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                accountEmail: null,
              ),
              new Column(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(
                        Icons.settings,
                        color: Theme.of(context).accentColor,
                      ),
                      title: new Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .push(new MaterialPageRoute(builder: (context) {
                          return new Settings();
                        }));
                      }),
                ],
              )
            ],
          ),
        ),
        body: isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : getDrawerItemWidget(_selectedDrawerIndex),
        bottomNavigationBar: new BottomNavigationBar(
          items: bottomOptions,
          onTap: (index) => _onSelectItem(index),
          currentIndex: _selectedDrawerIndex,
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() {
    if (_selectedDrawerIndex != 0) {
      setState(() {
        _selectedDrawerIndex = 0;
      });
    } else
      return showDialog(
            context: context,
            child: new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Music player will be stopped..'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text(
                    'No',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                new FlatButton(
                  onPressed: () {
                    MyQueue.player.stop();
                    SystemNavigator.pop();
                  },
                  child: new Text('Yes'),
                ),
              ],
            ),
          ) ??
          false;
  }
}

class BottomItem {
  String title;
  IconData icon;
  BottomItem(this.title, this.icon);
}
