import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../theme/app_colors.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String currencySymbol;

  const TransactionTile({
    required this.tx,
    required this.onDelete,
    required this.onEdit,
    required this.currencySymbol,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categoryInfo = CategoryHelper.getCategoryInfo(tx.category);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? AppColors.cardBg : Colors.white;
    final textColor = isDarkMode ? AppColors.textPrimary : AppColors.lightText;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: categoryInfo.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryInfo.icon,
                  color: categoryInfo.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          categoryInfo.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? AppColors.textHint
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.textHint
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tx.date.toString().split(' ')[0],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? AppColors.textHint
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.isIncome ? '+' : '-'}$currencySymbol${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tx.isIncome ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 28,
                    child: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: onEdit,
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: onDelete,
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: isDarkMode
                            ? AppColors.textHint
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
