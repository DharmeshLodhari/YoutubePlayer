import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomRangeThumbShapeForMovie extends RangeSliderThumbShape {
  static const double _thumbSize = 4.0;

  int startValue;
  int endValue;

  CustomRangeThumbShapeForMovie(this.startValue, this.endValue);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(_thumbSize, _thumbSize);

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double>? activationAnimation,
      Animation<double>? enableAnimation,
      bool? isDiscrete,
      bool? isEnabled,
      bool? isOnTop,
      TextDirection? textDirection,
      required SliderThemeData sliderTheme,
      Thumb? thumb,
      bool? isPressed}) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint();
    paint.color = sliderTheme.thumbColor!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    canvas.drawCircle(center, 8, Paint()..color = Colors.white);
    canvas.drawCircle(center, 8, paint);

    final textStyleForCurrency = TextStyle(
      color: blackFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    final textStyle = TextStyle(
        color: blackFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: "OpenSans");

    switch (textDirection ?? TextDirection.ltr) {
      case TextDirection.rtl:
        switch (thumb ?? Thumb.start) {
          case Thumb.start:
            final textSpan = TextSpan(children: [
              TextSpan(
                text: "₦",
                style: textStyleForCurrency,
              ),
              TextSpan(
                text: startValue.toString(),
                style: textStyle,
              )
            ]);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.textAlign = TextAlign.center;
            textPainter.layout(
              minWidth: 0,
              maxWidth: 40,
            );

            textPainter.paint(
                canvas,
                Offset(
                    startValue.toString().length == 2
                        ? center.dx - 15
                        : startValue.toString().length == 1
                            ? center.dx - 5
                            : center.dx - 20,
                    center.dy + 15));
            break;
          case Thumb.end:
            final textSpan = TextSpan(children: [
              TextSpan(
                text: "₦",
                style: textStyleForCurrency,
              ),
              TextSpan(
                text: endValue.toString(),
                style: textStyle,
              )
            ]);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.textAlign = TextAlign.center;
            textPainter.layout(
              minWidth: 0,
              maxWidth: 40,
            );
            textPainter.paint(
                canvas,
                Offset(
                    endValue.toString().length == 2
                        ? center.dx - 15
                        : endValue.toString().length == 1
                            ? center.dx - 5
                            : center.dx - 20,
                    center.dy + 15));
            break;
        }

        break;
      case TextDirection.ltr:
        switch (thumb ?? Thumb.start) {
          case Thumb.start:
            final textSpan = TextSpan(children: [
              TextSpan(
                text: "₦",
                style: textStyleForCurrency,
              ),
              TextSpan(
                text: startValue.toString(),
                style: textStyle,
              )
            ]);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.textAlign = TextAlign.center;
            textPainter.layout(
              minWidth: 0,
              maxWidth: 40,
            );

            textPainter.paint(
                canvas,
                Offset(
                    startValue.toString().length == 2
                        ? center.dx - 12
                        : startValue.toString().length == 1
                            ? center.dx - 5
                            : center.dx - 17,
                    center.dy + 15));
            break;
          case Thumb.end:
            final textSpan = TextSpan(children: [
              TextSpan(
                text: "₦",
                style: textStyleForCurrency,
              ),
              TextSpan(
                text: endValue.toString(),
                style: textStyle,
              )
            ]);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.textAlign = TextAlign.center;
            textPainter.layout(
              minWidth: 0,
              maxWidth: 40,
            );
            textPainter.paint(
                canvas,
                Offset(
                    endValue.toString().length == 2
                        ? center.dx - 12
                        : endValue.toString().length == 1
                            ? center.dx - 5
                            : center.dx - 17,
                    center.dy + 15));
            break;
        }

        break;
    }
  }
}

class CustomRangeThumbShapeForProperty extends RangeSliderThumbShape {
  static const double _thumbSize = 4.0;

  int startValue;
  int endValue;

  CustomRangeThumbShapeForProperty(this.startValue, this.endValue);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(_thumbSize, _thumbSize);

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double>? activationAnimation,
      Animation<double>? enableAnimation,
      bool? isDiscrete,
      bool? isEnabled,
      bool? isOnTop,
      TextDirection? textDirection,
      required SliderThemeData sliderTheme,
      Thumb? thumb,
      bool? isPressed}) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint();
    paint.color = sliderTheme.thumbColor!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    canvas.drawCircle(center, 8, Paint()..color = Colors.white);
    canvas.drawCircle(center, 8, paint);

    final textStyleForCurrency = TextStyle(
      color: blackFont,
      fontSize: 8,
      fontWeight: FontWeight.w400,
    );

    final textStyle = TextStyle(
        color: blackFont,
        fontSize: 8,
        fontWeight: FontWeight.w400,
        fontFamily: "OpenSans");

    switch (textDirection ?? TextDirection.ltr) {
      case TextDirection.rtl:
        switch (thumb ?? Thumb.start) {
          case Thumb.start:
            final textSpan = TextSpan(children: [
              TextSpan(
                text: "₦",
                style: textStyleForCurrency,
              ),
              TextSpan(
                text: startValue.toString(),
                style: textStyle,
              )
            ]);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.textAlign = TextAlign.center;

            textPainter.layout(
              minWidth: 0,
              maxWidth: 40,
            );

            textPainter.paint(
                canvas,
                Offset(
                    startValue.toString().length == 2
                        ? center.dx - 15
                        : startValue.toString().length == 1
                            ? center.dx - 5
                            : center.dx - 20,
                    center.dy + 15));
            break;
          case Thumb.end:
            final textSpan = TextSpan(children: [
              TextSpan(
                text: "₦",
                style: textStyleForCurrency,
              ),
              TextSpan(
                text: endValue.toString(),
                style: textStyle,
              )
            ]);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.textAlign = TextAlign.center;
            textPainter.layout(
              minWidth: 0,
              maxWidth: 40,
            );
            textPainter.paint(
                canvas,
                Offset(
                    endValue.toString().length == 2
                        ? center.dx - 15
                        : endValue.toString().length == 1
                            ? center.dx - 5
                            : center.dx - 20,
                    center.dy + 15));
            break;
        }

        break;
      case TextDirection.ltr:
        switch (thumb ?? Thumb.start) {
          case Thumb.start:
            final textSpan = TextSpan(children: [
              TextSpan(
                text: "₦",
                style: textStyleForCurrency,
              ),
              TextSpan(
                text: startValue.toString(),
                style: textStyle,
              )
            ]);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.textAlign = TextAlign.center;
            textPainter.layout(
              minWidth: 0,
              maxWidth: 40,
            );

            textPainter.paint(
                canvas,
                Offset(
                    startValue.toString().length == 2
                        ? center.dx - 12
                        : startValue.toString().length == 1
                            ? center.dx - 5
                            : center.dx - 17,
                    center.dy + 15));
            break;
          case Thumb.end:
            final textSpan = TextSpan(children: [
              TextSpan(
                text: "₦",
                style: textStyleForCurrency,
              ),
              TextSpan(
                text: endValue.toString(),
                style: textStyle,
              )
            ]);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.textAlign = TextAlign.center;
            textPainter.layout(
              minWidth: 0,
              maxWidth: 40,
            );
            textPainter.paint(
                canvas,
                Offset(
                    endValue.toString().length == 2
                        ? center.dx - 12
                        : endValue.toString().length == 1
                            ? center.dx - 5
                            : center.dx - 17,
                    center.dy + 15));
            break;
        }

        break;
    }
  }
}
