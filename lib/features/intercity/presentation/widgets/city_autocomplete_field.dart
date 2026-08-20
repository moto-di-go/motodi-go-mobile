import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';

class CityAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? leading;
  final String? label;
  final TextStyle textStyle;
  final InputDecoration decoration;
  final Decoration? boxDecoration;
  final EdgeInsetsGeometry? boxPadding;
  final double minHeight;

  const CityAutocompleteField({
    super.key,
    required this.controller,
    required this.hint,
    required this.textStyle,
    required this.decoration,
    this.leading,
    this.label,
    this.boxDecoration,
    this.boxPadding,
    this.minHeight = 0,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final UrbanRemoteDataSource _remote = UrbanRemoteDataSource(getIt<ChopperClient>());
  Timer? _debounce;
  List<UrbanPlace> _suggestions = const [];
  bool _suppressNext = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant CityAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerTick);
      widget.controller.addListener(_onControllerTick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerTick);
    _debounce?.cancel();
    super.dispose();
  }

  void _onControllerTick() {
    if (_suppressNext) {
      _suppressNext = false;
      return;
    }
    _schedule(widget.controller.text);
  }

  void _schedule(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = const []);
      }
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), () => _search(query));
  }

  Future<void> _search(String query) async {
    final places = await _remote.geocode(query, kind: 'CITY') ?? const <UrbanPlace>[];
    if (!mounted || widget.controller.text.trim() != query) return;
    setState(() => _suggestions = places);
  }

  void _select(UrbanPlace place) {
    _debounce?.cancel();
    _suppressNext = true;
    widget.controller.value = TextEditingValue(
      text: place.label,
      selection: TextSelection.collapsed(offset: place.label.length),
    );
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: widget.controller,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      cursorColor: const Color(0xFF16A34A),
      style: widget.textStyle,
      decoration: widget.decoration.copyWith(
        hintText: widget.hint,
      ),
    );

    final input = widget.boxDecoration == null
        ? _labeled(field)
        : _labeled(
            Container(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              padding: widget.boxPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: widget.boxDecoration,
              alignment: Alignment.centerLeft,
              child: field,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        input,
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._suggestions.take(6).map(
            (place) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _select(place),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city_outlined, size: 18, color: Color(0xFF8A968C)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          place.label,
                          style: const TextStyle(
                            color: Color(0xFF101512),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _labeled(Widget child) {
    if (widget.leading == null && (widget.label == null || widget.label!.isEmpty)) {
      return child;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: const TextStyle(
                    color: Color(0xFF8A968C),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              if (widget.label != null) const SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ],
    );
  }
}
