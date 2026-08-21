import 'package:flutter/material.dart';

class SlideDrawerController extends ChangeNotifier {
  VoidCallback? openCallback;
  VoidCallback? closeCallback;

  void open() {
    openCallback?.call();
  }

  void close() {
    closeCallback?.call();
  }
}

class SlideDrawer extends StatefulWidget {
  final Widget child;
  final Widget drawer;

  final double drawerWidth;
  final double edgeDragWidth;
  final Duration animationDuration;

  final SlideDrawerController? controller;

  const SlideDrawer({
    super.key,
    required this.child,
    required this.drawer,
    this.controller,
    this.drawerWidth = 300,
    this.edgeDragWidth = 100,
    this.animationDuration =
        const Duration(milliseconds: 220),
  });

  @override
  State<SlideDrawer> createState() =>
      _SlideDrawerState();
}

class _SlideDrawerState extends State<SlideDrawer> {
  double _offset = 0;
  bool _dragging = false;

  double get _progress => (_offset / widget.drawerWidth).clamp(0.0, 1.0);

  bool get _isOpen => _offset >= widget.drawerWidth;

  void _startOpenDrag(DragStartDetails details) {
    if (_offset != 0) {
      return;
    }

    setState(() {
      _dragging = true;
    });
  }

  void _updateOpenDrag(DragUpdateDetails details) {
    if (!_dragging) {
      return;
    }

    final next = _offset + details.delta.dx;

    setState(() {
      _offset = next.clamp(0.0, widget.drawerWidth);
    });
  }

  void _endOpenDrag(DragEndDetails details) {
    if (!_dragging) {
      return;
    }

    _finishDrag(
      open: _offset >= widget.drawerWidth / 2,
    );
  }

  void _startCloseDrag(
    DragStartDetails details,
  ) {
    if (!_isOpen) {
      return;
    }

    setState(() {
      _dragging = true;
    });
  }

  void _updateCloseDrag(
    DragUpdateDetails details,
  ) {
    if (!_dragging) {
      return;
    }

    final next =
        _offset + details.delta.dx;

    setState(() {
      _offset = next.clamp(
        0.0,
        widget.drawerWidth,
      );
    });
  }

  void _endCloseDrag(
    DragEndDetails details,
  ) {
    if (!_dragging) {
      return;
    }

    _finishDrag(
      open: _offset >= widget.drawerWidth / 2,
    );
  }

  void _finishDrag({
    required bool open,
  }) {
    setState(() {
      _dragging = false;
      _offset = open
          ? widget.drawerWidth
          : 0;
    });
  }

  void open() {
    setState(() {
      _offset = widget.drawerWidth;
      _dragging = false;
    });
  }

  void close() {
    setState(() {
      _offset = 0;
      _dragging = false;
    });
  }

  @override
  void didUpdateWidget(
    covariant SlideDrawer oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      widget.controller?.openCallback = null;
      widget.controller?.closeCallback = null;

    widget.controller?.openCallback = open;
    widget.controller?.closeCallback = close;
    }
  }

  @override
  void initState() {
    super.initState();

    widget.controller?.openCallback = open;
    widget.controller?.closeCallback = close;
  }

  @override
  void dispose() {
    widget.controller?.openCallback = null;
    widget.controller?.closeCallback = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (_offset > 0)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _offset < 1,
              child: GestureDetector(
                onTap: close,
                child: ColoredBox(
                  color: Colors.black.withValues(
                    alpha: 0.35 * _progress,
                  ),
                ),
              ),
            ),
          ),

        AnimatedPositioned(
          duration: _dragging
              ? Duration.zero
              : widget.animationDuration,
          curve: Curves.easeOutCubic,
          left: _offset - widget.drawerWidth,
          top: 0,
          bottom: 0,
          width: widget.drawerWidth,
          child: widget.drawer,
        ),

        if (!_isOpen)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: widget.edgeDragWidth,
            child: GestureDetector(
              behavior:
                  HitTestBehavior.translucent,
              onHorizontalDragStart:
                  _startOpenDrag,
              onHorizontalDragUpdate:
                  _updateOpenDrag,
              onHorizontalDragEnd:
                  _endOpenDrag,
            ),
          ),

        if (_isOpen)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: widget.drawerWidth,
            child: GestureDetector(
              behavior:
                  HitTestBehavior.translucent,
              onHorizontalDragStart:
                  _startCloseDrag,
              onHorizontalDragUpdate:
                  _updateCloseDrag,
              onHorizontalDragEnd:
                  _endCloseDrag,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}