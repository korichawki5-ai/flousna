// ═══════════════════════════════════════════════════════════════
//  category_manager_screen.dart — إدارة الفئات المخصصة (م2.1)
//
//  ✅ إضافة فئة باسمين (عربي/فرنسي) + أيقونة من القائمة المغلقة
//     + علم موسمية — عبر CategoryRepository (تحقق مزدوج هناك).
//  ✅ أرشفة/استعادة بدل الحذف: فئة لها حركات لا تختفي من التاريخ.
//  ✅ خمس حالات: تحميل / خطأ+إعادة / فارغ / بيانات / نجاح فوري.
// ═══════════════════════════════════════════════════════════════
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/seed_icons.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/db/db.dart';
import '../../data/seed/seed_categories.dart';

class CategoryManagerScreen extends ConsumerStatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  ConsumerState<CategoryManagerScreen> createState() =>
      _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends ConsumerState<CategoryManagerScreen> {
  Future<Result<List<CategoryView>, AppError>>? _reload;

  Future<Result<List<CategoryView>, AppError>> _load() {
    return ref.read(categoryRepositoryProvider).customOnly();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: AppTokens.snackBarDuration),
    );
  }

  Future<void> _toggleArchive(CategoryView view) async {
    final Result<void, AppError> result = await ref
        .read(categoryRepositoryProvider)
        .setArchived(view.id, archived: !view.archived);
    if (result.isSuccess) {
      setState(() => _reload = _load());
    } else {
      if (!mounted) return;
      _snack(result.errorOrNull!.body(context));
    }
  }

  Future<void> _openAddDialog() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) =>
          _AddCategoryDialog(onSaved: () => Navigator.of(dialogContext).pop(true)),
    );
    if (saved == true) {
      _snack(l10n.catMgrSaved);
      setState(() => _reload = _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool arabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return ScreenScaffold(
      title: l10n.catMgrTitle,
      scrollable: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppButton(
            label: l10n.catMgrAdd,
            icon: Icons.add_rounded,
            onPressed: _openAddDialog,
            variant: AppButtonVariant.filled,
            expandWidth: true,
            semanticLabel: l10n.catMgrAdd,
          ),
          const SizedBox(height: AppTokens.spaceLg),
          Expanded(
            child: FutureBuilder<Result<List<CategoryView>, AppError>>(
              future: _reload ??= _load(),
              builder: (
                BuildContext context,
                AsyncSnapshot<Result<List<CategoryView>, AppError>> snapshot,
              ) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final Result<List<CategoryView>, AppError>? result =
                    snapshot.data;
                if (result == null || result.isFailure) {
                  return Center(
                    child: AppButton(
                      label: l10n.actionRetry,
                      icon: Icons.refresh_rounded,
                      onPressed: () => setState(() => _reload = _load()),
                      semanticLabel: l10n.actionRetry,
                    ),
                  );
                }
                final List<CategoryView> rows = result.requireValue;
                if (rows.isEmpty) {
                  return EmptyState(
                    icon: Icons.category_outlined,
                    title: l10n.catMgrEmpty,
                    message: l10n.catMgrEmptyBody,
                  );
                }
                return ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CategoryView view = rows[index];
                    return Card(
                      margin: const EdgeInsetsDirectional.only(
                        bottom: AppTokens.spaceSm,
                      ),
                      child: ListTile(
                        leading: Icon(
                          SeedIcons.fromName(view.icon),
                          color: scheme.primary,
                        ),
                        title: Text(
                          arabic ? (view.nameAr ?? '') : (view.nameFr ?? ''),
                          style: AppTypography.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          arabic ? (view.nameFr ?? '') : (view.nameAr ?? ''),
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (view.archived)
                              Text(
                                l10n.catMgrArchived,
                                style: AppTypography.textTheme.labelSmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            IconButton(
                              tooltip: view.archived
                                  ? l10n.catMgrRestore
                                  : l10n.catMgrArchive,
                              icon: Icon(
                                view.archived
                                    ? Icons.restore_rounded
                                    : Icons.archive_outlined,
                              ),
                              onPressed: () => _toggleArchive(view),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// نافذة إضافة فئة — تحقق مزدوج في المستودع لا هنا فقط
class _AddCategoryDialog extends ConsumerStatefulWidget {
  const _AddCategoryDialog({required this.onSaved});

  final VoidCallback onSaved;

  @override
  ConsumerState<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<_AddCategoryDialog> {
  final TextEditingController _ar = TextEditingController();
  final TextEditingController _fr = TextEditingController();
  SeedCategoryKind _kind = SeedCategoryKind.expense;
  String _icon = SeedIcons.knownNames.first;
  bool _seasonal = false;
  bool _busy = false;

  @override
  void dispose() {
    _ar.dispose();
    _fr.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final Result<CategoryView, AppError> result =
        await ref.read(categoryRepositoryProvider).addCustom(
      kind: _kind,
      nameAr: _ar.text,
      nameFr: _fr.text,
      icon: _icon,
      seasonal: _seasonal,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.isSuccess) {
      widget.onSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorOrNull!.body(context)),
          duration: AppTokens.snackBarDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.catMgrAdd),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SegmentedButton<SeedCategoryKind>(
                segments: <ButtonSegment<SeedCategoryKind>>[
                  ButtonSegment<SeedCategoryKind>(
                    value: SeedCategoryKind.expense,
                    label: Text(l10n.expenseKind),
                  ),
                  ButtonSegment<SeedCategoryKind>(
                    value: SeedCategoryKind.income,
                    label: Text(l10n.incomeKind),
                  ),
                ],
                selected: <SeedCategoryKind>{_kind},
                onSelectionChanged: (Set<SeedCategoryKind> selection) =>
                    setState(() => _kind = selection.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: AppTokens.spaceMd),
              AppTextField(
                label: l10n.catMgrNameAr,
                controller: _ar,
                fieldType: AppFieldType.text,
                semanticLabel: l10n.catMgrNameAr,
              ),
              const SizedBox(height: AppTokens.spaceMd),
              AppTextField(
                label: l10n.catMgrNameFr,
                controller: _fr,
                fieldType: AppFieldType.text,
                semanticLabel: l10n.catMgrNameFr,
              ),
              const SizedBox(height: AppTokens.spaceMd),
              Text(l10n.catMgrIconLabel,
                  style: AppTypography.textTheme.titleSmall),
              const SizedBox(height: AppTokens.spaceSm),
              Wrap(
                spacing: AppTokens.spaceXs,
                runSpacing: AppTokens.spaceXs,
                children: <Widget>[
                  for (final String name in SeedIcons.knownNames)
                    IconButton(
                      icon: Icon(
                        SeedIcons.fromName(name),
                        color: name == _icon ? null : Colors.grey,
                      ),
                      isSelected: name == _icon,
                      selectedIcon: Icon(
                        SeedIcons.fromName(name),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => setState(() => _icon = name),
                      tooltip: name,
                    ),
                ],
              ),
              SwitchListTile(
                value: _seasonal,
                onChanged: (bool value) => setState(() => _seasonal = value),
                title: Text(l10n.catMgrSeasonal),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        AppButton(
          label: l10n.actionSave,
          icon: Icons.check_rounded,
          onPressed: _busy ? null : _save,
          semanticLabel: l10n.actionSave,
        ),
      ],
    );
  }
}
