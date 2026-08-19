import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AvatarEditorScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const AvatarEditorScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> {
  // ============================================================
  // НАСТРОЙКИ
  // ============================================================

  /// Размер итогового изображения.
  static const int outputSize = 1024;

  /// Максимальное приближение относительно минимально допустимого.
  static const double maxZoom = 10.0;

  /// Какая часть доступной области экрана отводится редактору.
  static const double editorScreenRatio = 1;

  // ============================================================
  // IMAGE
  // ============================================================

  ui.Image? _image;

  // ============================================================
  // EDITOR
  // ============================================================

  double _editorSize = 320.0;

  double get editorSize => _editorSize;

  final GlobalKey _editorKey = GlobalKey();

  // ============================================================
  // TRANSFORM
  // ============================================================

  /// Масштаб относительно минимально допустимого.
  ///
  /// 1.0 = изображение ровно покрывает область редактора.
  /// 10.0 = максимальный zoom.
  double _scale = 1.0;

  /// Значения transform в начале жеста.
  double _startScale = 1.0;
  Offset _startOffset = Offset.zero;

  /// Точка фокуса в начале жеста.
  Offset _startFocalPoint = Offset.zero;

  /// Смещение изображения относительно центра редактора.
  Offset _offset = Offset.zero;

  // ============================================================
  // STATE
  // ============================================================

  bool _isSaving = false;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadImage();
  }

  @override
  void dispose() {
    _image?.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD IMAGE
  // ============================================================

  Future<void> _loadImage() async {
    final codec = await ui.instantiateImageCodec(
      widget.imageBytes,
    );

    final frame = await codec.getNextFrame();

    codec.dispose();

    if (!mounted) {
      frame.image.dispose();
      return;
    }

    setState(() {
      _image = frame.image;
      _scale = 1.0;
      _offset = Offset.zero;
    });
  }

  // ============================================================
  // BASE SCALE
  // ============================================================

  /// Минимальный масштаб, при котором изображение полностью
  /// закрывает квадрат редактора.
  ///
  /// Например:
  ///
  /// image = 1920 x 1080
  /// editor = 320 x 320
  ///
  /// scaleX = 320 / 1920
  /// scaleY = 320 / 1080
  ///
  /// Берём MAX, потому что нам нужно именно покрытие,
  /// а не вписывание изображения внутрь квадрата.
  double _baseScale({
    required double editorSize,
  }) {
    final image = _image;

    if (image == null) {
      return 1.0;
    }

    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    final scaleX = editorSize / imageWidth;
    final scaleY = editorSize / imageHeight;

    return math.max(
      scaleX,
      scaleY,
    );
  }

  // ============================================================
  // DISPLAY SCALE
  // ============================================================

  /// Полный масштаб изображения на экране:
  ///
  /// baseScale * userScale
  double _displayScale({
    double? scale,
    double? editorSize,
  }) {
    return _baseScale(
          editorSize: editorSize ?? _editorSize,
        ) *
        (scale ?? _scale);
  }

  // ============================================================
  // DISPLAYED IMAGE RECT
  // ============================================================

  /// Возвращает прямоугольник, в который должно быть нарисовано
  /// исходное изображение внутри редактора.
  ///
  /// Это центральная часть всей новой архитектуры.
  ///
  /// ВАЖНО:
  /// этот Rect используется И НА ЭКРАНЕ, И ПРИ СОХРАНЕНИИ.
  ///
  /// Поэтому визуальный результат и итоговый файл используют
  /// абсолютно одинаковую геометрию.
  Rect _imageRect({
    double? scale,
    Offset? offset,
    double? editorSize,
  }) {
    final image = _image;

    if (image == null) {
      return Rect.zero;
    }

    final currentEditorSize = editorSize ?? _editorSize;
    final currentScale = _displayScale(
      scale: scale,
      editorSize: currentEditorSize,
    );

    final width = image.width * currentScale;
    final height = image.height * currentScale;

    final currentOffset = offset ?? _offset;

    final editorCenter = Offset(
      currentEditorSize / 2.0,
      currentEditorSize / 2.0,
    );

    final imageCenter = editorCenter + currentOffset;

    return Rect.fromCenter(
      center: imageCenter,
      width: width,
      height: height,
    );
  }

  // ============================================================
  // MAX OFFSET
  // ============================================================

  /// Максимально допустимое смещение изображения.
  ///
  /// Изображение обязано полностью покрывать область редактора.
  ///
  /// Для каждой оси:
  ///
  /// maxOffset = (imageSize - editorSize) / 2
  ///
  /// Если по какой-то оси изображение равно редактору,
  /// смещение по ней = 0.
  Offset _maxOffset({
    required double scale,
    required double editorSize,
  }) {
    final image = _image;

    if (image == null) {
      return Offset.zero;
    }

    final displayScale = _displayScale(
      scale: scale,
      editorSize: editorSize,
    );

    final imageWidth = image.width * displayScale;
    final imageHeight = image.height * displayScale;

    final maxX = math.max(
      0.0,
      (imageWidth - editorSize) / 2.0,
    );

    final maxY = math.max(
      0.0,
      (imageHeight - editorSize) / 2.0,
    );

    return Offset(
      maxX,
      maxY,
    );
  }

  // ============================================================
  // CLAMP OFFSET
  // ============================================================

  Offset _clampOffset({
    required Offset offset,
    required double scale,
    required double editorSize,
  }) {
    final maxOffset = _maxOffset(
      scale: scale,
      editorSize: editorSize,
    );

    return Offset(
      offset.dx.clamp(
        -maxOffset.dx,
        maxOffset.dx,
      ),
      offset.dy.clamp(
        -maxOffset.dy,
        maxOffset.dy,
      ),
    );
  }

  // ============================================================
  // GESTURE START
  // ============================================================

  void _onScaleStart(
    ScaleStartDetails details,
  ) {
    if (_image == null) {
      return;
    }

    _startScale = _scale;
    _startOffset = _offset;

    final renderObject =
        _editorKey.currentContext?.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    _startFocalPoint = renderObject.globalToLocal(
      details.focalPoint,
    );
  }

  // ============================================================
  // GESTURE UPDATE
  // ============================================================

  void _onScaleUpdate(
    ScaleUpdateDetails details,
  ) {
    if (_image == null) {
      return;
    }

    final renderObject =
        _editorKey.currentContext?.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final currentFocalPoint = renderObject.globalToLocal(
      details.focalPoint,
    );

    final focalPointDelta =
        currentFocalPoint - _startFocalPoint;

    // ------------------------------------------------------------
    // Считаем новый scale.
    // ------------------------------------------------------------

    final requestedScale =
        _startScale * details.scale;

    final newScale = requestedScale.clamp(
      1.0,
      maxZoom,
    );

    // ------------------------------------------------------------
    // Если масштаб уже упёрся в предел,
    // его изменение должно стать ровно 0.
    // ------------------------------------------------------------

    final scaleChange =
        newScale / _startScale;

    // ------------------------------------------------------------
    // Масштабирование относительно точки фокуса.
    // ------------------------------------------------------------

    final editorCenter = Offset(
      editorSize / 2.0,
      editorSize / 2.0,
    );

    final focalPointFromCenter =
        _startFocalPoint - editorCenter;

    final zoomOffset =
        focalPointFromCenter *
        (1.0 - scaleChange);

    final newOffset =
        _startOffset +
        focalPointDelta +
        zoomOffset;

    final clampedOffset = _clampOffset(
      offset: newOffset,
      scale: newScale,
      editorSize: editorSize,
    );

    // ------------------------------------------------------------
    // Обновляем состояние.
    // ------------------------------------------------------------

    setState(() {
      _scale = newScale;
      _offset = clampedOffset;
    });
  }

  // ============================================================
  // MOUSE WHEEL
  // ============================================================

  void _onPointerSignal(
    PointerSignalEvent event,
  ) {
    if (_image == null) {
      return;
    }

    if (event is! PointerScrollEvent) {
      return;
    }

    final delta = event.scrollDelta.dy;

    if (delta == 0) {
      return;
    }

    // ------------------------------------------------------------
    // Определяем точку курсора внутри редактора.
    // ------------------------------------------------------------

    final renderObject =
        _editorKey.currentContext?.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final focalPoint = renderObject.globalToLocal(
      event.position,
    );

    // ------------------------------------------------------------
    // Новый масштаб.
    // ------------------------------------------------------------

    final zoomFactor = delta < 0
        ? 1.05
        : (1.0 / 1.05);

    final requestedScale =
        _scale * zoomFactor;

    final newScale = requestedScale.clamp(
      1.0,
      maxZoom,
    );

    // ------------------------------------------------------------
    // КРИТИЧЕСКИ ВАЖНО:
    //
    // Если мы уже на максимуме и колесо пытается увеличить
    // изображение ещё сильнее — ВООБЩЕ НИЧЕГО НЕ ДЕЛАЕМ.
    //
    // То же самое для минимального масштаба.
    //
    // Именно это устраняет эффект:
    //
    // "картинка уже не увеличивается,
    //  но продолжает ехать влево/вверх".
    // ------------------------------------------------------------

    if ((newScale - _scale).abs() < 0.000001) {
      return;
    }

    // ------------------------------------------------------------
    // Масштабирование относительно курсора.
    // ------------------------------------------------------------

    final scaleChange =
        newScale / _scale;

    final editorCenter = Offset(
      editorSize / 2.0,
      editorSize / 2.0,
    );

    final focalPointFromCenter =
        focalPoint - editorCenter;

    final zoomOffset =
        focalPointFromCenter *
        (1.0 - scaleChange);

    final newOffset =
        _offset + zoomOffset;

    final clampedOffset = _clampOffset(
      offset: newOffset,
      scale: newScale,
      editorSize: editorSize,
    );

    setState(() {
      _scale = newScale;
      _offset = clampedOffset;
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (_image == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await _renderAvatar();

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        result,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось обработать изображение',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // RENDER AVATAR
  // ============================================================

  Future<Uint8List> _renderAvatar() async {
    final image = _image;

    if (image == null) {
      throw Exception(
        'Image is not loaded',
      );
    }

    // ==========================================================
    // 1. Определяем геометрию изображения НА ЭКРАНЕ.
    // ==========================================================

    final imageRect = _imageRect();

    final displayScale = _displayScale();

    // ==========================================================
    // 2. Область редактора соответствует квадрату,
    //    который мы хотим получить на выходе.
    // ==========================================================

    final editorRect = Rect.fromLTWH(
      0,
      0,
      editorSize,
      editorSize,
    );

    // ==========================================================
    // 3. Находим исходную область изображения,
    //    которая попадает в editorRect.
    //
    //    Это и есть настоящий crop.
    // ==========================================================

    final sourceLeft =
        (editorRect.left - imageRect.left) /
        displayScale;

    final sourceTop =
        (editorRect.top - imageRect.top) /
        displayScale;

    final sourceSize =
        editorSize / displayScale;

    // ----------------------------------------------------------
    // Защита от микроскопических floating point ошибок.
    // ----------------------------------------------------------

    final sourceRect = Rect.fromLTWH(
      sourceLeft.clamp(
        0.0,
        image.width.toDouble(),
      ),
      sourceTop.clamp(
        0.0,
        image.height.toDouble(),
      ),
      sourceSize.clamp(
        0.0,
        image.width.toDouble(),
      ),
      sourceSize.clamp(
        0.0,
        image.height.toDouble(),
      ),
    );

    // ==========================================================
    // 4. Создаём итоговый canvas.
    // ==========================================================

    final recorder = ui.PictureRecorder();

    final canvas = Canvas(
      recorder,
    );

    final outputRect = Rect.fromLTWH(
      0,
      0,
      outputSize.toDouble(),
      outputSize.toDouble(),
    );

    // ==========================================================
    // 5. Рисуем ТО ЖЕ изображение,
    //    ТОЙ ЖЕ геометрией,
    //    только из sourceRect в outputRect.
    // ==========================================================

    canvas.drawImageRect(
      image,
      sourceRect,
      outputRect,
      Paint()
        ..filterQuality = FilterQuality.high,
    );

    // ==========================================================
    // 6. Получаем PNG.
    // ==========================================================

    final picture = recorder.endRecording();

    final outputImage = await picture.toImage(
      outputSize,
      outputSize,
    );

    picture.dispose();

    final byteData = await outputImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    outputImage.dispose();

    if (byteData == null) {
      throw Exception(
        'Failed to encode image',
      );
    }

    return byteData.buffer.asUint8List();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Настройка аватара',
        ),
        actions: [
          IconButton(
            onPressed: _isSaving
                ? null
                : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.check,
                  ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          // ------------------------------------------------------
          // Определяем размер квадратного редактора.
          // ------------------------------------------------------

          final newEditorSize =
              math.min(
                constraints.maxWidth,
                constraints.maxHeight,
              ) *
              editorScreenRatio;

          _editorSize = newEditorSize;

          // ------------------------------------------------------
          // Если размер редактора изменился,
          // старое смещение может перестать быть допустимым.
          // ------------------------------------------------------

          _offset = _clampOffset(
            offset: _offset,
            scale: _scale,
            editorSize: _editorSize,
          );

          if (_image == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: _buildEditor(),
          );
        },
      ),
    );
  }

  // ============================================================
  // EDITOR
  // ============================================================

  Widget _buildEditor() {
    return Listener(
      onPointerSignal: _onPointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: SizedBox(
          key: _editorKey,
          width: editorSize,
          height: editorSize,
          child: Stack(
            children: [
              // ==================================================
              // ИЗОБРАЖЕНИЕ
              //
              // Больше НИКАКОГО RawImage.
              //
              // Рисуем картинку через CustomPaint и drawImageRect,
              // чтобы экран и сохранение использовали одинаковую
              // геометрию.
              // ==================================================

              ClipRect(
                child: CustomPaint(
                  size: Size(
                    editorSize,
                    editorSize,
                  ),
                  painter: _AvatarImagePainter(
                    image: _image!,
                    imageRect: _imageRect(),
                  ),
                ),
              ),

              // ==================================================
              // OVERLAY
              // ==================================================

              IgnorePointer(
                child: CustomPaint(
                  size: Size(
                    editorSize,
                    editorSize,
                  ),
                  painter: const _AvatarOverlayPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// IMAGE PAINTER
// ================================================================

class _AvatarImagePainter extends CustomPainter {
  final ui.Image image;
  final Rect imageRect;

  const _AvatarImagePainter({
    required this.image,
    required this.imageRect,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // ------------------------------------------------------------
    // Весь исходник изображения.
    // ------------------------------------------------------------

    final sourceRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // ------------------------------------------------------------
    // Рисуем весь исходник точно в imageRect.
    // ------------------------------------------------------------

    canvas.drawImageRect(
      image,
      sourceRect,
      imageRect,
      Paint()
        ..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(
    covariant _AvatarImagePainter oldDelegate,
  ) {
    return oldDelegate.image != image ||
        oldDelegate.imageRect != imageRect;
  }
}

// ================================================================
// OVERLAY PAINTER
// ================================================================

class _AvatarOverlayPainter extends CustomPainter {
  const _AvatarOverlayPainter();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2.0,
      size.height / 2.0,
    );

    final radius = size.width / 2.0;

    // ------------------------------------------------------------
    // Затемнение вне круга.
    // ------------------------------------------------------------

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(
        alpha: 0.55,
      )
      ..style = PaintingStyle.fill;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );

    canvas.drawPath(
      path,
      overlayPaint,
    );

    // ------------------------------------------------------------
    // Белая рамка.
    // ------------------------------------------------------------

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      center,
      radius - 1.0,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _AvatarOverlayPainter oldDelegate,
  ) {
    return false;
  }
}