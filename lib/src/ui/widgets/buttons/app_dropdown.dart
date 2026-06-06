import 'package:flutter/material.dart';
import 'package:ketamiz/src/theme/app_theme.dart';

class AppDropdownItem<T> {
  final T value;
  final String label;
  final Color? color;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.color,
  });
}

class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>>
    with SingleTickerProviderStateMixin {
  final _key = GlobalKey();
  OverlayEntry? _overlay;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _close();
    _ctrl.dispose();
    super.dispose();
  }

  void _open() {
    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlay = OverlayEntry(
      builder: (_) => _DropdownOverlay<T>(
        anchorOffset: offset,
        anchorSize: size,
        fade: _fade,
        scale: _scale,
        items: widget.items,
        selected: widget.value,
        onSelect: (v) {
          _close();
          widget.onChanged(v);
        },
        onDismiss: _close,
      ),
    );

    Overlay.of(context).insert(_overlay!);
    _ctrl.forward(from: 0);
    setState(() {});
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() {});
  }

  bool get _isOpen => _overlay != null;

  AppDropdownItem<T> get _current =>
      widget.items.firstWhere((i) => i.value == widget.value,
          orElse: () => widget.items.first);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _isOpen ? _close : _open,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              blurRadius: 100,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.12),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_current.color != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _current.color,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                _current.label,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.black,
                ),
              ),
            ),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.dark,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownOverlay<T> extends StatelessWidget {
  const _DropdownOverlay({
    required this.anchorOffset,
    required this.anchorSize,
    required this.fade,
    required this.scale,
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onDismiss,
  });

  final Offset anchorOffset;
  final Size anchorSize;
  final Animation<double> fade;
  final Animation<double> scale;
  final List<AppDropdownItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    const panelPad = 8.0;
    const gap = 6.0;

    return Stack(
      children: [
        // Dismiss tap catcher
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          left: anchorOffset.dx,
          top: anchorOffset.dy + anchorSize.height + gap,
          width: anchorSize.width,
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              alignment: Alignment.topCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: panelPad),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      final isSelected = item.value == selected;
                      return _DropdownOption<T>(
                        item: item,
                        isSelected: isSelected,
                        isLast: i == items.length - 1,
                        onTap: () => onSelect(item.value),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownOption<T> extends StatefulWidget {
  const _DropdownOption({
    required this.item,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });

  final AppDropdownItem<T> item;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  State<_DropdownOption<T>> createState() => _DropdownOptionState<T>();
}

class _DropdownOptionState<T> extends State<_DropdownOption<T>> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppTheme.black.withOpacity(0.06)
              : _pressed
                  ? AppTheme.black.withOpacity(0.03)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: widget.item.color ?? AppTheme.gray,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                widget.item.label,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.isSelected ? AppTheme.black : AppTheme.dark,
                ),
              ),
            ),
            if (widget.isSelected)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppTheme.black,
              ),
          ],
        ),
      ),
    );
  }
}
