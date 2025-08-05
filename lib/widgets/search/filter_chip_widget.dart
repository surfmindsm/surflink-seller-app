import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;

  const FilterChipWidget({
    Key? key,
    required this.label,
    this.onDeleted,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isSelected = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: onDeleted != null ? 8 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? 
                (isSelected 
                    ? theme.primaryColor.withOpacity(0.1)
                    : Colors.grey[100]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? theme.primaryColor
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: textColor ?? 
                      (isSelected 
                          ? theme.primaryColor
                          : Colors.grey[600]),
                ),
                const SizedBox(width: 4),
              ],
              
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: textColor ?? 
                        (isSelected 
                            ? theme.primaryColor
                            : Colors.grey[700]),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              if (onDeleted != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDeleted,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: (textColor ?? 
                          (isSelected 
                              ? theme.primaryColor
                              : Colors.grey[600])!).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: textColor ?? 
                          (isSelected 
                              ? theme.primaryColor
                              : Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FilterOptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? description;

  const FilterOptionChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? theme.primaryColor
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
            ],
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? theme.primaryColor
                          : Colors.grey[800],
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 20,
                color: theme.primaryColor,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                size: 20,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
}

class FilterToggleChip extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final String? description;

  const FilterToggleChip({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value 
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value 
                ? theme.primaryColor
                : Colors.grey[300]!,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: value 
                    ? theme.primaryColor
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
            ],
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                      color: value 
                          ? theme.primaryColor
                          : Colors.grey[800],
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: theme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class FilterCountChip extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final String? label;

  const FilterCountChip({
    Key? key,
    required this.count,
    this.onTap,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0 && onTap == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: count > 0 
              ? theme.primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: count > 0 ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: count > 0 ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
