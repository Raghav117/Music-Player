import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttery/gestures.dart';
import 'package:music_player/songs.dart';

import 'bottom_controllers.dart';
import 'package:fluttery_audio/fluttery_audio.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Music Player",
      home: new AudioPlaylist(
        playlist: demoPlaylist.songs.map((DemoSong song) {
          return song.audioUrl;
        }).toList(growable: false),
        child: new Scaffold(
          appBar: new AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: new IconButton(
              icon: new Icon(
                Icons.arrow_back_ios,
                color: Colors.grey[400],
              ),
              onPressed: () {},
            ),
            actions: <Widget>[
              new IconButton(
                icon: new Icon(
                  Icons.menu,
                  color: Colors.grey[400],
                ),
                onPressed: () {},
              )
            ],
          ),
          body: new Column(
            children: <Widget>[
              // For Seek Bar
              new Expanded(
                child: new RadialAudioComponent(),
              ),

              // For Visualizer

              new Container(
                color: Colors.red[200],
                height: 80.0,
                width: double.infinity,
              ),

              // For Song title , artist and controllers

              new BottomControllers()
            ],
          ),
        ),
      ),
    );
  }
}

class RadialAudioComponent extends StatelessWidget {
  const RadialAudioComponent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AudioComponent(
      updateMe: [
        WatchableAudioProperties.audioSeeking,
        WatchableAudioProperties.audioPlayhead,
      ],
      playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
        double playerplaybackprogress = 0.0;
        if (player.audioLength != null && player.position != null) {
          playerplaybackprogress = player.position.inMilliseconds /
              player.audioLength.inMilliseconds;
        }

        return new Radialseekbar(
          seek: playerplaybackprogress,
          thumb: playerplaybackprogress,
          onEnd: (double onend) {
            final seekMillis =
                (onend * player.audioLength.inMilliseconds).round();
            player.seek(new Duration(milliseconds: seekMillis));
          },
        );
      },
    );
  }
}

class Radialseekbar extends StatefulWidget {
  final double seek;
  final double thumb;
  final Function(double) onEnd;
  Radialseekbar({this.seek = 0.0, this.thumb = 0.0, this.onEnd});
  @override
  _RadialseekbarState createState() => _RadialseekbarState();
}

class _RadialseekbarState extends State<Radialseekbar> {
  PolarCoord _dragstartcord;

  double _startdragpercent;

  double _currentdragpercent = 0.0;
  double seekbar;
  double thumbP;

  @override
  void initState() {
    super.initState();
    seekbar = widget.seek;
    thumbP = widget.thumb;
  }

  @override
  void didUpdateWidget(Radialseekbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    seekbar = widget.seek;
    thumbP = widget.thumb;
  }

  void _dragStart(PolarCoord coord) {
    _dragstartcord = coord;
    _startdragpercent = thumbP;
  }

  void _dragUpdate(PolarCoord coord) {
    final dragangle = coord.angle - _dragstartcord.angle;
    final dragpercent = dragangle / (2 * pi);
    setState(() {
      _currentdragpercent = (dragpercent + _startdragpercent) % 1.0;
    });
  }

  void _dragEnd() {
    widget.onEnd(_currentdragpercent);

    setState(() {
      thumbP = _currentdragpercent;
      seekbar = _currentdragpercent;
      _currentdragpercent = 0.0;
      _dragstartcord = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new RadialDragGestureDetector(
      onRadialDragEnd: _dragEnd,
      onRadialDragStart: _dragStart,
      onRadialDragUpdate: _dragUpdate,
      child: new Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.transparent,
        child: new Center(
          child: new Container(
            height: 150.0,
            width: 150.0,
            child: new RadialProgressBar(
              progressPercent: seekbar,
              thumbPosition:
                  (_currentdragpercent == 0.0) ? thumbP : _currentdragpercent,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: new AudioPlaylistComponent(playlistBuilder:
                    (BuildContext context, Playlist play, Widget child) {
                  String image =
                      demoPlaylist.songs[play.activeIndex].albumArtUrl;
                  return new ClipOval(
                    child: new Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                    clipper: new MyClipper(),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return new Rect.fromCircle(
      center: new Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbSize;
  final Color thumbColor;
  final double thumbPosition;
  final Widget child;

  RadialProgressBar({
    this.trackWidth = 3.0,
    this.trackColor = const Color(0xFFE0E0E0),
    this.progressWidth = 5.0,
    this.progressColor = const Color(0xFFEF9A9A),
    this.progressPercent = 0.0,
    this.thumbSize = 10.0,
    this.thumbColor = const Color(0xFFE57373),
    this.thumbPosition = 0.0,
    this.child,
  });

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      child: widget.child,
      painter: new RadialSeekBarPainter(
          progressPercent: widget.progressPercent,
          thumbPosition: widget.thumbPosition,
          thumbSize: widget.thumbSize,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          thumbColor: widget.thumbColor,
          trackColor: widget.trackColor,
          trackWidth: widget.trackWidth),
    );
  }
}

class RadialSeekBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final Paint progressPaint;
  final double progressPercent;
  final double thumbSize;
  final Paint thumbPaint;
  final double thumbPosition;

  RadialSeekBarPainter({
    @required this.trackWidth,
    @required trackColor,
    @required this.progressWidth,
    @required progressColor,
    @required this.progressPercent,
    @required this.thumbSize,
    @required thumbColor,
    @required this.thumbPosition,
  })  : trackPaint = new Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = new Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = new Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    //Paint Track

    final center = new Offset(size.width / 2, size.height / 2);
    final radius = min(size.height, size.width) / 2;

    canvas.drawCircle(center, radius, trackPaint);

    //Paint Progress

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progressPercent;
    bool useCenter = false;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, useCenter, progressPaint);

    //Paint Thumb

    final thumbAngle = 2 * pi * thumbPosition - pi / 2;
    final thumbx = cos(thumbAngle) * radius;
    final thumby = sin(thumbAngle) * radius;
    final thumbCenter = center + new Offset(thumbx, thumby);
    final thumbRadius = thumbSize / 2;

    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
