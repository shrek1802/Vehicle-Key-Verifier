import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

enum AppStatus {
  verified,
  ai,
  warning,
  supported,
  unsupported,
  unknown,
  information,
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.status,
    super.key,
    this.icon,
  });

  const StatusChip.verified({
    super.key,
    this.label = 'VERIFIED',
    this.icon = Icons.verified_rounded,
  }) : status = AppStatus.verified;

  const StatusChip.ai({
    super.key,
    this.label = 'AI RESEARCH',
    this.icon = Icons.auto_awesome_rounded,
  }) : status = AppStatus.ai;

  const StatusChip.warning({
    super.key,
    this.label = 'WARNING',
    this.icon = Icons.warning_amber_rounded,
  }) : status = AppStatus.warning;

  const StatusChip.supported({
    super.key,
    this.label = 'SUPPORTED',
    this.icon = Icons.check_circle_outline_rounded,
  }) : status = AppStatus.supported;

  const StatusChip.unsupported({
    super.key,
    this.label = 'NOT SUPPORTED',
    this.icon = Icons.cancel_outlined,
  }) : status = AppStatus.unsupported;

  const StatusChip.unknown({
    super.key,
    this.label = 'UNKNOWN',
    this.icon = Icons.help_outline_rounded,
  }) : status = AppStatus.unknown;

  const StatusChip.information({
    super.key,
    this.label = 'INFORMATION',
    this.icon = Icons.info_outline_rounded,
  }) : status = AppStatus.information;

  final String label;
  final AppStatus status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: style.foreground.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: style.foreground,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppText.chip.copyWith(
                color: style.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _styleFor(AppStatus status) {
    switch (status) {
      case AppStatus.verified:
        return const _StatusStyle(
          foreground: AppColors.verifiedLight,
          background: AppColors.verifiedBackground,
        );

      case AppStatus.ai:
        return const _StatusStyle(
          foreground: AppColors.aiLight,
          background: AppColors.aiBackground,
        );

      case AppStatus.warning:
        return const _StatusStyle(
          foreground: AppColors.warning,
          background: AppColors.warningBackground,
        );

      case AppStatus.supported:
        return const _StatusStyle(
          foreground: AppColors.primaryLight,
          background: AppColors.infoBackground,
        );

      case AppStatus.unsupported:
        return const _StatusStyle(
          foreground: AppColors.dangerLight,
          background: AppColors.dangerBackground,
        );

      case AppStatus.unknown:
        return const _StatusStyle(
          foreground: AppColors.textSecondary,
          background: AppColors.unknownBackground,
        );

      case AppStatus.information:
        return const _StatusStyle(
          foreground: AppColors.info,
          background: AppColors.infoBackground,
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
