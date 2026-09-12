import 'package:flutter/material.dart';

/// Renders text like "氣(ㄑㄧˋ)喘(ㄔㄨㄢˇ)" with the zhuyin (bopomofo) stacked
/// vertically beside each character (traditional style), instead of inline
/// in parentheses.
class ZhuyinText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final double zhuyinScale;

  const ZhuyinText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.zhuyinScale = 0.34,
  });

  static final RegExp _pattern = RegExp(r'(.)\(([^)]+)\)', dotAll: true);
  static const Set<String> _toneMarks = {'ˊ', 'ˇ', 'ˋ'};

  /// Builds the vertical stack of zhuyin symbols for one character, sized so
  /// the whole stack's height roughly matches the base character's height
  /// (instead of a fixed size that hangs below short characters when a
  /// syllable needs 3-4 rows). A trailing 2nd/3rd/4th tone mark (ˊˇˋ) isn't
  /// stacked on its own row — it sits as a small mark beside the last letter.
  Widget _buildZhuyinStack(String zhuyin, TextStyle baseStyle, double zhuyinScale) {
    final fontSize = baseStyle.fontSize ?? 16;

    String letters = zhuyin;
    String? toneMark;
    if (letters.isNotEmpty && _toneMarks.contains(letters[letters.length - 1])) {
      toneMark = letters[letters.length - 1];
      letters = letters.substring(0, letters.length - 1);
    }

    // The neutral-tone dot (˙) is a prefix, not a stacked letter — it should
    // sit tucked close above the first letter, not take up a full row.
    String? neutralDot;
    if (letters.isNotEmpty && letters[0] == '˙') {
      neutralDot = letters[0];
      letters = letters.substring(1);
    }

    final letterList = letters.split('');
    // Fixed size for every symbol, regardless of this character's own row
    // count — otherwise a 3-row syllable renders visibly smaller glyphs than
    // a 2-row one. Sized to roughly fill the character's height when a
    // syllable needs its most common max of 3 rows; shorter stacks are
    // centered (below) instead of stretched to match.
    final symbolBoxSize = fontSize * zhuyinScale;
    final dotBoxHeight = symbolBoxSize * 0.7;
    final zhuyinStyle = baseStyle.copyWith(
      fontSize: symbolBoxSize / 1.1,
      fontWeight: FontWeight.normal,
      height: 1.0,
    );

    final rows = <Widget>[
      if (neutralDot != null)
        SizedBox(
          width: symbolBoxSize,
          height: dotBoxHeight,
          child: Center(child: Text(neutralDot, style: zhuyinStyle.copyWith(fontSize: zhuyinStyle.fontSize! * 1.6))),
        ),
      ...List.generate(letterList.length, (i) {
        final letterBox = SizedBox(
          width: symbolBoxSize,
          height: symbolBoxSize,
          child: Center(child: Text(letterList[i], style: zhuyinStyle)),
        );
        final isLast = i == letterList.length - 1;
        if (!isLast || toneMark == null) {
          return letterBox;
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            letterBox,
            Text(toneMark, style: zhuyinStyle.copyWith(fontSize: zhuyinStyle.fontSize! * 1.6)),
          ],
        );
      }),
    ];

    final stack = Column(
      mainAxisSize: MainAxisSize.min,
      // Without this, Column centers each row against the widest one (the
      // last row when it has a tone mark appended), shifting the plain
      // letter rows sideways and making the stack look crooked.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );

    // When the stack is shorter than the character's own height, center it
    // instead of leaving it stuck to the top.
    final stackHeight = letterList.length * symbolBoxSize + (neutralDot != null ? dotBoxHeight : 0);
    final topPad = ((fontSize - stackHeight) / 2).clamp(0.0, double.infinity);
    return Padding(padding: EdgeInsets.only(top: topPad), child: stack);
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = (style ?? const TextStyle(fontSize: 16, color: Colors.black)).copyWith(height: 1.0);
    final fontSize = baseStyle.fontSize ?? 16;

    final children = <Widget>[];
    int last = 0;
    for (final match in _pattern.allMatches(text)) {
      if (match.start > last) {
        children.add(Text(text.substring(last, match.start), style: baseStyle));
      }
      final char = match.group(1)!;
      final zhuyin = match.group(2)!;
      children.add(
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(char, style: baseStyle),
              _buildZhuyinStack(zhuyin, baseStyle, zhuyinScale),
            ],
          ),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      children.add(Text(text.substring(last), style: baseStyle));
    }

    return Wrap(
      alignment: switch (textAlign) {
        TextAlign.center => WrapAlignment.center,
        TextAlign.end || TextAlign.right => WrapAlignment.end,
        _ => WrapAlignment.start,
      },
      // Top-align every group: annotations vary in length (2-4 symbols), so
      // centering them would make the base characters drift up/down relative
      // to each other along the line.
      crossAxisAlignment: WrapCrossAlignment.start,
      runSpacing: fontSize * 0.3,
      children: children,
    );
  }
}
