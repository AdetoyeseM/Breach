import 'package:flutter/material.dart'; 

class TextView extends StatelessWidget {
  final GlobalKey? textKey;
  final String text;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final double? lineHeight;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final Function()? onTap;
  final int? maxLines;
  final bool? softWrap;
  final TextStyle? textStyle;
  final TextDecoration? decoration;
  final Color? decorationColor;

  const TextView({
    super.key,
    this.textKey,
    required this.text,
    this.softWrap = true,
    this.textOverflow = TextOverflow.clip,
    this.textAlign = TextAlign.left,
    this.color,
    this.onTap,
    this.fontSize,
    this.lineHeight,
    this.textStyle,
    this.maxLines,
    this.fontWeight = FontWeight.normal,
    this.decoration,
    this.decorationColor,
    this.fontStyle = FontStyle.normal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        key: textKey,
        style: textStyle ??
            TextStyle(
              fontFamily: 'Inter',
              color: color,
              decoration: decoration,
              fontWeight: fontWeight,
              decorationColor: decorationColor,
              fontSize: ((fontSize ?? 15) + 2),
              fontStyle: fontStyle,
              height: lineHeight,
            ),
        textAlign: textAlign,
        overflow: textOverflow,
        maxLines: maxLines,
        softWrap: softWrap,
      ),
    );
  }
}

TextStyle appTextStyle({
  double? fontSize,
  Color? color,
  TextDecoration? decoration,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontFamily: "Inter",
    fontSize: ((fontSize ?? 15) + 2),
    color: color,
    fontWeight: fontWeight ?? FontWeight.w600,
    decoration: decoration,
    overflow: TextOverflow.clip,
  );
}
