import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("About"),
        ),
        body: new Center(
          child: new Container(
              margin: EdgeInsets.all(50),
              height: 300.0,
              child: new Card(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new CircleAvatar(
                      radius: 50.0,
                      backgroundImage: new AssetImage("images/avatar.jpg"),
                    ),
                    new Text(" Music Player "),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text("Checkout this profile on GitHub"),
                    ),
                    new IconButton(
                      icon: new Icon(Icons.open_in_browser),
                      onPressed: launchUrl,
                    )
                  ],
                ),
              )),
        ));
  }

  launchUrl() async {
    const url = "https://github.com/yashrastogi11";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}
