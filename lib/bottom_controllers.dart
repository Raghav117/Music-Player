import 'package:flutter/material.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'package:music_player/songs.dart';

class BottomControllers extends StatelessWidget {
  const BottomControllers({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.red[300],
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
        child: new Column(
          children: <Widget>[
            new AudioPlaylistComponent(playlistBuilder:
                (BuildContext context, Playlist play, Widget child) {
              String songTitle = demoPlaylist.songs[play.activeIndex].songTitle;
              String artist = demoPlaylist.songs[play.activeIndex].artist;
              return new RichText(
                text: new TextSpan(
                    text: "${songTitle.toUpperCase()}\n",
                    style: new TextStyle(fontSize: 15.0, letterSpacing: 4.0),
                    children: [
                      new TextSpan(
                        text: "${artist.toUpperCase()}",
                        style:
                            new TextStyle(fontSize: 10.0, letterSpacing: 2.0),
                      )
                    ]),
              );
            }),
            new Padding(
              padding: const EdgeInsets.only(top: 90.0),
              child: Material(
                color: Colors.red[300],
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Container(),
                    ),
                    new PreviousButton(),
                    new Expanded(
                      child: new Container(),
                    ),
                    new PlayPauseButton(),
                    new Expanded(
                      child: new Container(),
                    ),
                    new NextButton(),
                    new Expanded(
                      child: new Container(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AudioPlaylistComponent(
      playlistBuilder: (BuildContext context, Playlist play, Widget child) {
        return new IconButton(
          icon: new Icon(Icons.skip_previous),
          color: Colors.white,
          onPressed: play.previous,
        );
      },
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AudioComponent(
      updateMe: [WatchableAudioProperties.audioPlayerState],
      playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
        IconData icon = Icons.music_note;
        Function onPressed;

        if (player.state == AudioPlayerState.playing) {
          icon = Icons.pause;
          onPressed = player.pause;
        } else if (player.state == AudioPlayerState.paused ||
            player.state == AudioPlayerState.completed) {
          icon = Icons.play_arrow;
          onPressed = player.play;
        }

        return new RawMaterialButton(
          shape: new CircleBorder(),
          fillColor: Colors.white,
          splashColor: Colors.red[300],
          elevation: 10.0,
          child: new Padding(
            padding: EdgeInsets.all(13.0),
            child: new Icon(
              icon,
              color: Colors.red[300],
            ),
          ),
          onPressed: onPressed,
        );
      },
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AudioPlaylistComponent(
        playlistBuilder: (BuildContext context, Playlist play, Widget child) {
      return new IconButton(
        icon: new Icon(Icons.skip_next),
        color: Colors.white,
        onPressed: play.next,
      );
    });
  }
}
