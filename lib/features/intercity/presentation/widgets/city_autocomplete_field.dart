import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

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

  /// `CITY` for cities (intercity départ/destination). `null` for any place (quartiers, POI, villes).
  final String? kind;
  final IconData suggestionIcon;

  /// Bias geocode toward a departure city (pickup / POI search).
  final double? biasLat;
  final double? biasLon;

  /// When true and bias is missing, show a hint and skip remote search.
  final bool requireBias;
  final String missingBiasMessage;

  /// Called when the user picks a suggestion, or `null` when the typed text no longer matches.
  final ValueChanged<UrbanPlace?>? onPlaceSelected;

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
    this.kind = 'CITY',
    this.suggestionIcon = Icons.location_city_outlined,
    this.biasLat,
    this.biasLon,
    this.requireBias = false,
    this.missingBiasMessage = 'Choisissez d\'abord une ville de départ',
    this.onPlaceSelected,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final UrbanRemoteDataSource _remote = UrbanRemoteDataSource(getIt<ChopperClient>());
  Timer? _debounce;
  List<UrbanPlace> _suggestions = const [];
  bool _loading = false;
  bool _suppressNext = false;
  bool _searched = false;
  String? _error;
  String _lastText = '';
  String? _selectedLabel;
  int _requestId = 0;

  bool get _hasBias => widget.biasLat != null && widget.biasLon != null;

  @override
  void initState() {
    super.initState();
    _lastText = widget.controller.text;
    widget.controller.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant CityAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerTick);
      _lastText = widget.controller.text;
      widget.controller.addListener(_onControllerTick);
    }
    final biasChanged =
        oldWidget.biasLat != widget.biasLat || oldWidget.biasLon != widget.biasLon;
    if (biasChanged && widget.controller.text.trim().length >= 2) {
      _queueSearch(widget.controller.text);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerTick);
    _debounce?.cancel();
    super.dispose();
  }

  void _onControllerTick() {
    // TextEditingController notifies on selection/composing changes too — ignore those.
    final text = widget.controller.text;
    if (text == _lastText) return;
    _lastText = text;

    if (_suppressNext) {
      _suppressNext = false;
      return;
    }

    if (_selectedLabel != null && text.trim() != _selectedLabel) {
      _selectedLabel = null;
      widget.onPlaceSelected?.call(null);
    }

    _queueSearch(text);
  }

  void _queueSearch(String raw) {
    _debounce?.cancel();
    final query = raw.trim();
    if (query.length < 2) {
      _requestId++;
      setState(() {
        _suggestions = const [];
        _loading = false;
        _searched = false;
        _error = null;
      });
      return;
    }

    if (widget.requireBias && !_hasBias) {
      _requestId++;
      setState(() {
        _suggestions = const [];
        _loading = false;
        _searched = true;
        _error = widget.missingBiasMessage;
      });
      return;
    }

    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    _debounce = Timer(const Duration(milliseconds: 280), () => _search(query, id));
  }

  Future<void> _search(String query, int id) async {
    debugPrint(
      '[CityAutocomplete] search q="$query" kind=${widget.kind} '
      'bias=${widget.biasLat},${widget.biasLon}',
    );
    List<UrbanPlace> places = const [];
    String? error;
    try {
      places = await _remote
              .geocode(
                query,
                kind: widget.kind,
                lat: widget.biasLat,
                lon: widget.biasLon,
              )
              .timeout(const Duration(seconds: 8)) ??
          const <UrbanPlace>[];
    } on TimeoutException {
      error = 'Recherche trop lente';
    } on ApiException catch (e) {
      error = e.message;
      debugPrint('[CityAutocomplete] api error: $e');
    } catch (e) {
      error = 'Recherche indisponible';
      debugPrint('[CityAutocomplete] error: $e');
    }

    if (!mounted) return;
    if (id != _requestId) return;

    debugPrint('[CityAutocomplete] results=${places.length} error=$error');
    setState(() {
      _suggestions = places;
      _loading = false;
      _searched = true;
      _error = error;
    });
  }

  void _select(UrbanPlace place) {
    _debounce?.cancel();
    _requestId++;
    _suppressNext = true;
    _selectedLabel = place.label;
    _lastText = place.label;
    widget.controller.value = TextEditingValue(
      text: place.label,
      selection: TextSelection.collapsed(offset: place.label.length),
    );
    widget.onPlaceSelected?.call(place);
    setState(() {
      _suggestions = const [];
      _loading = false;
      _searched = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: widget.controller,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      cursorColor: const Color(0xFF16A34A),
      style: widget.textStyle,
      decoration: widget.decoration.copyWith(hintText: widget.hint),
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

    final queryLen = widget.controller.text.trim().length;
    final showEmpty = !_loading && _searched && _suggestions.isEmpty && queryLen >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        input,
        if (_loading) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            minHeight: 2,
            color: Color(0xFF16A34A),
            backgroundColor: Color(0xFFE7EAE3),
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7EAE3)),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _suggestions.length && i < 6; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Color(0xFFECEEE8)),
                  InkWell(
                    onTap: () => _select(_suggestions[i]),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            widget.suggestionIcon,
                            size: 18,
                            color: const Color(0xFF8A968C),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _suggestions[i].label,
                                  style: const TextStyle(
                                    color: Color(0xFF101512),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (_suggestions[i].subtitle != null &&
                                    _suggestions[i].subtitle!.trim().isNotEmpty)
                                  Text(
                                    _suggestions[i].subtitle!,
                                    style: const TextStyle(
                                      color: Color(0xFF8A968C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else if (showEmpty) ...[
          const SizedBox(height: 8),
          Text(
            (_error ?? 'Aucun lieu trouvé').tr(context),
            style: const TextStyle(
              color: Color(0xFF8A968C),
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
        if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 14)],
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
