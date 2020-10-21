import 'dart:async';

import 'package:Slydo/screens/more_apps/utils/video_plyer_controller/chewie_player.dart';
import 'package:Slydo/screens/more_apps/utils/video_plyer_controller/chewie_progress_colors.dart';
import 'package:Slydo/screens/more_apps/utils/video_plyer_controller/material_progress_bar.dart';
import 'package:Slydo/screens/more_apps/utils/video_plyer_controller/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MaterialControls extends StatefulWidget {
  const MaterialControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls> {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;
  bool isWishList = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideStuff,
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity:
                    _latestValue != null && _latestValue.isPlaying ? 0.0 : 1.0,
                duration: Duration(milliseconds: 10),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl:
                        "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  _buildVideoTitle(),
                  _latestValue != null &&
                              !_latestValue.isPlaying &&
                              _latestValue.duration == null ||
                          _latestValue.isBuffering
                      ? const Expanded(
                          child: const Center(
                            child: const CircularProgressIndicator(),
                          ),
                        )
                      : _latestValue != null && !_latestValue.isPlaying
                          ? _buildHitArea()
                          : _buildHitAreaWhenPlaying(),
                  _buildBottomBar(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  AnimatedOpacity _buildBottomBar(
    BuildContext context,
  ) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            // _buildPlayPause(controller),
            // chewieController.isLive
            //     ? Expanded(child: const Text('LIVE'))
            //     : _buildPosition(iconColor),
            chewieController.isLive ? const SizedBox() : _buildProgressBar(),
            _buildRemainingDuration(iconColor),
            // chewieController.allowMuting
            //     ? _buildMuteButton(controller)
            //     : Container(),
            chewieController.allowFullScreen
                ? _buildExpandButton()
                : Container(),
          ],
        ),
      ),
    );
  }

  AnimatedOpacity _buildVideoTitle() {
    return _latestValue != null && _latestValue.isPlaying
        ? AnimatedOpacity(
            opacity: _hideStuff ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: Container(
              height: barHeight,
              color: Colors.transparent,
              child: Row(
                children: <Widget>[
                  flexibleSpace(),
                  Text(
                    "DAWN OF THUNDER",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  flexibleSpace(),
                  chewieController.isFullScreen
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _onExpandCollapse();
                          },
                        )
                      : Container(),
                ],
              ),
            ),
          )
        : AnimatedOpacity(
            opacity: _hideStuff ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: Container(
              height: barHeight,
              color: Colors.transparent,
              child: Row(
                children: <Widget>[
                  flexibleSpace(),
                  IconButton(
                    icon: Icon(
                      isWishList
                          ? SlydoAppIcon.heart_1
                          : SlydoAppIcon.heart_empty,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      debugPrint("i am called!");
                      isWishList = !isWishList;
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: chewieController.isFullScreen
          ? () {}
          : () {
              _onExpandCollapse();
            },
      child: chewieController.isFullScreen
          ? Container()
          : AnimatedOpacity(
              opacity: _hideStuff ? 0.0 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                height: barHeight,
                child: Center(
                  child: Icon(
                    chewieController.isFullScreen
                        ? Icons.fullscreen_exit
                        : SlydoAppIcon.full_screen,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
    );
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_latestValue != null && _latestValue.isPlaying) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else
              _cancelAndRestartTimer();
          } else {
            _playPause();

            setState(() {
              _hideStuff = true;
            });
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedOpacity(
              opacity:
                  _latestValue != null && !_latestValue.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: Duration(milliseconds: 300),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 32.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitAreaWhenPlaying() {
    return Expanded(
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () {
            if (_latestValue != null && _latestValue.isPlaying) {
              if (_displayTapped) {
                setState(() {
                  _hideStuff = true;
                });
              } else
                _cancelAndRestartTimer();
            } else {
              _playPause();

              setState(() {
                _hideStuff = true;
              });
            }
          },
          child: Row(
            children: [
              flexibleSpace(flex: 2),
              rewindButton(),
              flexibleSpace(flex: 1),
              pauseButton(),
              flexibleSpace(flex: 1),
              forwardButton(),
              flexibleSpace(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget rewindButton() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: AnimatedOpacity(
          opacity: _latestValue != null && _latestValue.isPlaying && !_dragging
              ? 1.0
              : 0.0,
          duration: Duration(milliseconds: 300),
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  SlydoAppIcon.ccw,
                  size: 32.0,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              rewindVideo();
            },
          ),
        ),
      ),
    );
  }

  Widget pauseButton() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: AnimatedOpacity(
          opacity: _latestValue != null && _latestValue.isPlaying && !_dragging
              ? 1.0
              : 0.0,
          duration: Duration(milliseconds: 300),
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(48.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.pause,
                  size: 32.0,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              _playPause();
            },
          ),
        ),
      ),
    );
  }

  Widget forwardButton() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: AnimatedOpacity(
          opacity: _latestValue != null && _latestValue.isPlaying && !_dragging
              ? 1.0
              : 0.0,
          duration: Duration(milliseconds: 300),
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  SlydoAppIcon.cw,
                  size: 32.0,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              forwardVideo();
            },
          ),
        ),
      ),
    );
  }

  void forwardVideo() {
    if (chewieController != null &&
        chewieController.videoPlayerController != null &&
        _latestValue != null &&
        _latestValue.position != null) {
      chewieController.videoPlayerController
          .seekTo(_latestValue.position + Duration(seconds: 10));
    }
  }

  void rewindVideo() {
    if (chewieController != null &&
        chewieController.videoPlayerController != null &&
        _latestValue != null &&
        _latestValue.position != null) {
      chewieController.videoPlayerController
          .seekTo(_latestValue.position - Duration(seconds: 10));
    }
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Icon(
                (_latestValue != null && _latestValue.volume > 0)
                    ? Icons.volume_up
                    : Icons.volume_off,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 8.0, right: 4.0),
        padding: EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    return Padding(
      padding: EdgeInsets.only(right: 24.0),
      child: Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: TextStyle(fontSize: 14.0, color: Colors.white),
      ),
    );
  }

  Widget _buildRemainingDuration(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;
    final remainingDuration = duration - position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        '${formatDuration(remainingDuration)}',
        style: TextStyle(
            fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();

      _showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: MaterialVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: chewieController.materialProgressColors ??
              ChewieProgressColors(
                  playedColor: Theme.of(context).accentColor,
                  handleColor: Theme.of(context).accentColor,
                  bufferedColor: Theme.of(context).backgroundColor,
                  backgroundColor: Theme.of(context).disabledColor),
        ),
      ),
    );
  }
}
