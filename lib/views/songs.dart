import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music_player/database/database_client.dart';
import 'package:music_player/pages/now_playing.dart';
import 'package:music_player/util/lastplay.dart';
import 'package:music_player/util/utility.dart';

class Songs extends StatefulWidget {
  DatabaseClient db;
  List<Song> songs;
  Songs(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _songsState();
  }
}

class _songsState extends State<Songs> {
  List<Song> songs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initSongs();
  }

  void initSongs() async {
    songs = await widget.db.fetchSongs();
    setState(() {
      isLoading = false;
    });
  }

  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(song.albumArt));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : new ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, i) => new Column(
                      children: <Widget>[
                        new Divider(
                          height: 8.0,
                        ),
                        new ListTile(
                          leading: new Hero(
                            tag: songs[i].id,
                            child: avatar(
                                context, getImage(songs[i]), songs[i].title),
                          ),
                          title: new Text(songs[i].title,
                              maxLines: 1,
                              style: new TextStyle(fontSize: 18.0)),
                          subtitle: new Text(
                            songs[i].artist,
                            maxLines: 1,
                            style: new TextStyle(
                                fontSize: 12.0, color: Colors.grey),
                          ),
                          trailing: new Text(
                              new Duration(milliseconds: songs[i].duration)
                                  .toString()
                                  .split('.')
                                  .first,
                              style: new TextStyle(
                                  fontSize: 12.0, color: Colors.grey)),
                          onTap: () {
                            MyQueue.songs = songs;
                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (context) => new NowPlaying(
                                    widget.db, MyQueue.songs, i, 0)));
                          },
                          onLongPress: () {
                            setFav(songs[i]);
                          },
                        ),
                      ],
                    ),
              ));
  }

  Future<void> setFav(song) {
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text('Add this to favourites?'),
        content: new Text(song.title),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              'No',
            ),
          ),
          new FlatButton(
            onPressed: () async {
              await widget.db.favSong(song);

              Navigator.of(context).pop();
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    );
  }
}
