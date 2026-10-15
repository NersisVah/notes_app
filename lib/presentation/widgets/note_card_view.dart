import 'package:flutter/material.dart';

import '../resources/app_colors.dart';
import '../resources/app_sizes.dart';
import 'styled_text.dart';

/// Note title card that can be dragged from left to right.
///
/// - Released before the middle: snaps open to reveal the favorite button,
///   or closed if barely dragged.
/// - Released past the middle: slides off and asks [onDeleteRequested];
///   slides back when it resolves to `false`.
///
/// With [showHint] it slides open a little and back once after the first
/// frame, to show that it can be dragged.
class NoteCardView extends StatefulWidget {
  const NoteCardView({
    super.key,
    required this.title,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggled,
    required this.onDeleteRequested,
    this.showHint = false,
  });

  final String title;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggled;
  final Future<bool> Function() onDeleteRequested;
  final bool showHint;

  @override
  State<NoteCardView> createState() => _NoteCardViewState();
}

class _NoteCardViewState extends State<NoteCardView>
    with SingleTickerProviderStateMixin {
  static const _settleDuration = Duration(milliseconds: 250);
  static const _hintDuration = Duration(milliseconds: 1000);
  static const _deleteThreshold = 0.35;
  static const _flingVelocity = 700.0;

  /// 0 is closed, 1 is fully off screen to the right.
  late final AnimationController _controller = AnimationController(vsync: this);

  double _width = 1;

  /// Drag fraction where only the favorite button is visible.
  double get _openValue => AppSizes.noteCardActionWidth / _width;

  bool get _isOpen => _controller.value > 0;

  @override
  void initState() {
    super.initState();
    if (widget.showHint) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _playHint());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playHint() async {
    if (!mounted) return;
    await _controller.animateTo(
      _openValue,
      duration: _hintDuration,
      curve: Curves.easeOut,
    );
    if (!mounted) return;
    await _controller.animateTo(
      0,
      duration: _hintDuration,
      curve: Curves.easeIn,
    );
  }

  void _animateTo(double value) {
    _controller.animateTo(
      value,
      duration: _settleDuration,
      curve: Curves.easeOut,
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value += details.primaryDelta! / _width;
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    final value = _controller.value;
    final velocity = details.primaryVelocity ?? 0;

    if (value >= _deleteThreshold) {
      await _controller.animateTo(
        1,
        duration: _settleDuration,
        curve: Curves.easeOut,
      );
      final deleted = await widget.onDeleteRequested();
      if (!deleted && mounted) _animateTo(0);
    } else if (velocity < -_flingVelocity) {
      _animateTo(0);
    } else if (velocity > _flingVelocity || value >= _openValue / 2) {
      _animateTo(_openValue);
    } else {
      _animateTo(0);
    }
  }

  void _onCardTap() {
    if (_isOpen) {
      _animateTo(0);
    } else {
      widget.onTap();
    }
  }

  void _onFavoriteTap() {
    widget.onFavoriteToggled();
    _animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSizes.radiusMedium);

    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;

        return GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, card) => Stack(
              children: [
                if (_isOpen)
                  Positioned.fill(
                    child: _NoteCardBackground(
                      borderRadius: borderRadius,
                      isDeleting: _controller.value >= _deleteThreshold,
                      isFavorite: widget.isFavorite,
                      onFavoriteTap: _onFavoriteTap,
                    ),
                  ),
                Transform.translate(
                  offset: Offset(_controller.value * _width, 0),
                  child: card,
                ),
              ],
            ),
            child: Material(
              color: AppColors.secondaryBackground,
              elevation: AppSizes.noteCardElevation,
              borderRadius: borderRadius,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: _onCardTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Row(
                    children: [
                      Expanded(
                        child: StyledText(
                          widget.title,
                          size: AppTextSize.medium,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Icon(
                        widget.isFavorite ? Icons.star : Icons.star_border,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// What is revealed behind the card: the favorite button while the card is
/// open, a red delete background once it is dragged past the middle.
class _NoteCardBackground extends StatelessWidget {
  const _NoteCardBackground({
    required this.borderRadius,
    required this.isDeleting,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final BorderRadius borderRadius;
  final bool isDeleting;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return isDeleting
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: borderRadius,
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: AppSizes.noteCardActionWidth,
                child: Icon(Icons.delete_outline, color: AppColors.white),
              ),
            ),
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: AppSizes.noteCardActionWidth,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: AppColors.primary,
                  ),
                  onPressed: onFavoriteTap,
                ),
              ),
            ),
          );
  }
}
