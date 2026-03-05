import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextDirection? textDirection;
  final Duration typingSpeed;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.textDirection,
    this.typingSpeed = const Duration(milliseconds: 15),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.dispose();
      _initAnimation();
    }
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.typingSpeed * widget.text.length,
    );
    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        String visibleText = widget.text.substring(0, _characterCount.value);
        return SelectableText(
          visibleText,
          textDirection: widget.textDirection,
          style: widget.style,
        );
      },
    );
  }
}
