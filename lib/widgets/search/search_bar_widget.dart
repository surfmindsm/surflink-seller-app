import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final List<String> suggestions;
  final Function(String) onSuggestionSelected;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onSubmitted,
    this.suggestions = const [],
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && widget.suggestions.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged('');
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {
                _showSuggestions = value.isNotEmpty && 
                                  widget.suggestions.isNotEmpty &&
                                  _focusNode.hasFocus;
              });
            },
            onSubmitted: widget.onSubmitted,
          ),
        ),
        
        // 검색 제안
        if (_showSuggestions && widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: widget.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, size: 20, color: Colors.grey),
                  title: Text(suggestion),
                  onTap: () {
                    widget.onSuggestionSelected(suggestion);
                    setState(() {
                      _showSuggestions = false;
                    });
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class SearchChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final IconData? icon;

  const SearchChipWidget({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.onDeleted,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SortOptionWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SortOptionWidget({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? Border.all(color: Theme.of(context).primaryColor)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
