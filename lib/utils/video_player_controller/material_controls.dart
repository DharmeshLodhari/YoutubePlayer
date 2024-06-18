import 'dart:async';
import 'dart:io';

import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/video_player_controller/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'chewie_player.dart';
import 'chewie_progress_colors.dart';
import 'material_progress_bar.dart';

// ignore: must_be_immutable
class MaterialControls extends StatefulWidget {
  String? posterUrl;
  String? titleName;

  MaterialControls({super.key, this.posterUrl, this.titleName})
     ;

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls> {
  VideoPlayerValue? _latestValue;
  // double _latestVolume;
  bool _hideStuff = true;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;
  bool isWishList = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  VideoPlayerController? controller;
  ChewieController? chewieController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue!.hasError) {
      return chewieController!.errorBuilder != null
          ? chewieController!.errorBuilder!(
              context,
              chewieController!.videoPlayerController.value.errorDescription,
            )
          : const Center(
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
              if (widget.posterUrl != null && widget.posterUrl != "")
                AnimatedOpacity(
                  opacity: _latestValue != null && _latestValue!.isPlaying
                      ? 0.0
                      : 1.0,
                  duration: const Duration(milliseconds: 10),
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: widget.posterUrl!.startsWith('http')
                        ? CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: widget.posterUrl!,
                          )
                        : Image.file(
                            File(widget.posterUrl!),
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                )
              else
                Container(),
              Column(
                children: <Widget>[
                  _buildVideoTitle(),
                  if (_latestValue != null &&
                      !_latestValue!.isPlaying &&
                      _latestValue!.isBuffering)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    _latestValue != null && !_latestValue!.isPlaying
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
    controller!.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController!.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  AnimatedOpacity _buildBottomBar(
    BuildContext context,
  ) {
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            // _buildPlayPause(controller),
            // chewieController.isLive
            //     ? Expanded(child: const Text('LIVE'))
            //     : _buildPosition(iconColor),
            if (chewieController!.isLive)
              const SizedBox()
            else
              _buildProgressBar(),
            _buildRemainingDuration(),
            // chewieController.allowMuting
            //     ? _buildMuteButton(controller)
            //     : Container(),
            if (chewieController!.allowFullScreen)
              _buildExpandButton()
            else
              Container(),
          ],
        ),
      ),
    );
  }

  AnimatedOpacity _buildVideoTitle() {
    return _latestValue != null && _latestValue!.isPlaying
        ? AnimatedOpacity(
            opacity: _hideStuff ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              height: barHeight,
              color: Colors.transparent,
              child: Row(
                children: <Widget>[
                  flexibleSpace(),
                  Text(
                    widget.titleName != null
                        ? widget.titleName!.length > 45
                            ? "${widget.titleName!.substring(0, 45)}..."
                            : widget.titleName!
                        : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: true,
                  ),
                  flexibleSpace(),
                  if (chewieController!.isFullScreen)
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _onExpandCollapse();
                      },
                    )
                  else
                    Container(),
                ],
              ),
            ),
          )
        : AnimatedOpacity(
            opacity: _hideStuff ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
                height: barHeight, color: Colors.transparent, child: Container()
                // Row(
                //   children: <Widget>[
                // flexibleSpace(),
                // IconButton(
                //   icon: Icon(
                //     isWishList
                //         ? SlydoAppIcon.heart_1
                //         : SlydoAppIcon.heart_empty,
                //     size: 20,
                //     color: Colors.white,
                //   ),
                //   onPressed: () {
                //     isWishList = !isWishList;
                //     setState(() {});
                //   },
                // )
                //   ],
                // ),
                ),
          );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: chewieController!.isFullScreen
          ? () {}
          : () {
              _onExpandCollapse();
            },
      child: chewieController!.isFullScreen
          ? Container()
          : AnimatedOpacity(
              opacity: _hideStuff ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                height: barHeight,
                child: Center(
                  child: Icon(
                    chewieController!.isFullScreen
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
          if (_latestValue != null && _latestValue!.isPlaying) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else {
              _cancelAndRestartTimer();
            }
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
                  _latestValue != null && !_latestValue!.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: const Padding(
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
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () {
            if (_latestValue != null && _latestValue!.isPlaying) {
              if (_displayTapped) {
                setState(() {
                  _hideStuff = true;
                });
              } else {
                _cancelAndRestartTimer();
              }
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
          opacity: _latestValue != null && _latestValue!.isPlaying && !_dragging
              ? 1.0
              : 0.0,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48.0),
              ),
              child: const Padding(
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
          opacity: _latestValue != null && _latestValue!.isPlaying && !_dragging
              ? 1.0
              : 0.0,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(48.0),
              ),
              child: const Padding(
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
          opacity: _latestValue != null && _latestValue!.isPlaying && !_dragging
              ? 1.0
              : 0.0,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48.0),
              ),
              child: const Padding(
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
    if (chewieController != null && _latestValue != null) {
      chewieController!.videoPlayerController
          .seekTo(_latestValue!.position + const Duration(seconds: 10));
    }
  }

  void rewindVideo() {
    if (chewieController != null && _latestValue != null) {
      chewieController!.videoPlayerController
          .seekTo(_latestValue!.position - const Duration(seconds: 10));
    }
  }

  // GestureDetector _buildMuteButton(
  //   VideoPlayerController controller,
  // ) {
  //   return GestureDetector(
  //     onTap: () {
  //       _cancelAndRestartTimer();
  //
  //       if (_latestValue.volume == 0) {
  //         controller.setVolume(_latestVolume ?? 0.5);
  //       } else {
  //         _latestVolume = controller.value.volume;
  //         controller.setVolume(0.0);
  //       }
  //     },
  //     child: AnimatedOpacity(
  //       opacity: _hideStuff ? 0.0 : 1.0,
  //       duration: Duration(milliseconds: 300),
  //       child: ClipRect(
  //         child: Container(
  //           child: Container(
  //             height: barHeight,
  //             padding: EdgeInsets.only(
  //               left: 8.0,
  //               right: 8.0,
  //             ),
  //             child: Icon(
  //               (_latestValue != null && _latestValue.volume > 0)
  //                   ? Icons.volume_up
  //                   : Icons.volume_off,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // GestureDetector _buildPlayPause(VideoPlayerController controller) {
  //   return GestureDetector(
  //     onTap: _playPause,
  //     child: Container(
  //       height: barHeight,
  //       color: Colors.transparent,
  //       margin: EdgeInsets.only(left: 8.0, right: 4.0),
  //       padding: EdgeInsets.only(
  //         left: 12.0,
  //         right: 12.0,
  //       ),
  //       child: Icon(
  //         controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildPosition(Color iconColor) {
  //   final position = _latestValue != null && _latestValue.position != null
  //       ? _latestValue.position
  //       : Duration.zero;
  //   final duration = _latestValue != null && _latestValue.duration != null
  //       ? _latestValue.duration
  //       : Duration.zero;
  //
  //   return Padding(
  //     padding: EdgeInsets.only(right: 24.0),
  //     child: Text(
  //       '${formatDuration(position)} / ${formatDuration(duration)}',
  //       style: TextStyle(fontSize: 14.0, color: Colors.white),
  //     ),
  //   );
  // }

  Widget _buildRemainingDuration() {
    final position =
        _latestValue != null ? _latestValue!.position : Duration.zero;
    final duration =
        _latestValue != null ? _latestValue!.duration : Duration.zero;
    final remainingDuration = duration - position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        formatDuration(remainingDuration),
        style: const TextStyle(
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

  Future<void> _initialize() async {
    controller!.addListener(_updateState);

    _updateState();

    if ((controller!.value.isPlaying) || chewieController!.autoPlay) {
      _startHideTimer();
    }

    if (chewieController!.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController!.toggleFullScreen();

      _showAfterExpandCollapseTimer =
          Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    final bool isFinished = _latestValue!.position >= _latestValue!.duration;

    setState(() {
      if (controller!.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller!.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller!.value.isInitialized) {
          controller!.initialize().then((_) {
            controller!.play();
          });
        } else {
          if (isFinished) {
            controller!.seekTo(const Duration(seconds: 0));
          }
          controller!.play();
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
      _latestValue = controller!.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
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
          colors: chewieController!.materialProgressColors ??
              ChewieProgressColors(
                  playedColor: Theme.of(context).colorScheme.secondary,
                  handleColor: Theme.of(context).colorScheme.secondary,
                  bufferedColor:
                      Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  backgroundColor: Theme.of(context).disabledColor),
        ),
      ),
    );
  }
}
