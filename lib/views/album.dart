import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music_player/database/database_client.dart';
import 'package:music_player/pages/card_detail.dart';
import 'package:music_player/util/utility.dart';


class Album extends StatefulWidget {
  DatabaseClient db;
  Album(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _stateAlbum();
  }
}

class _stateAlbum extends State<Album> {
  List<Song> songs;
  var f;
  bool isLoading = true;
  @override
  initState() {
    super.initState();
    initAlbum();
  }

  void initAlbum() async {
    // songs=await widget.db.fetchSongs();
    songs = await widget.db.fetchAlbum();
    setState(() {
      isLoading = false;
    });
  }

  List<Card> _buildGridCards(BuildContext context) {
    return songs.map((song) {
      return Card(
        child: new InkResponse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Hero(
                tag: song.album,
                child: AspectRatio(
                  aspectRatio: 18 / 16,
                  child: getImage(song) != null
                      ? new Image.file(
                          getImage(song),
                          height: 120.0,
                          fit: BoxFit.fill,
                        )
                      : new Image.asset(
                          "images/back.jpg",
                          height: 120.0,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  // padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  padding: EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        song.album,
                        style: new TextStyle(fontSize: 18.0),
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        song.artist,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14.0, color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(context, new MaterialPageRoute(builder: (_) {
              return new CardDetail(widget.db, song, 0);
            }));
            /*Navigator
                .of(context)
                .push(new MaterialPageRoute(builder: (_) {
              return new CardDetail(widget.db, song, 0);
            }));*/
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return new Container(
        child: isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : new GridView.count(
                crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                children: _buildGridCards(context),
                padding: EdgeInsets.all(2.0),
                childAspectRatio: 8.0 / 10.0,
              ));
  }
}
