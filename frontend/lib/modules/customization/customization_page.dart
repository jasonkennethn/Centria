import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';

class CustomizationPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const CustomizationPage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String _selectedTargetModel = 'Employee';
  List<dynamic> _customFields = [];

  final List<String> _models = ['Employee', 'Invoice', 'Task', 'Document', 'Policy'];

  @override
  void initState() {
    super.initState();
    _loadCustomFields();
  }

  Future<void> _loadCustomFields() async {
    setState(() => _isLoading = true);
    final res = await _api.getCustomFields(_selectedTargetModel);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.isSuccess && res.data is List) {
          _customFields = res.data;
        } else {
          _customFields = [];
        }
      });
    }
  }

  void _showAddFieldDialog() {
    final labelCtrl = TextEditingController();
    String fieldType = 'TEXT';
    bool isRequired = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: Text('Add Custom Field to $_selectedTargetModel', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Field Label', hintText: 'e.g. GitHub Username or Tax ID'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: fieldType,
                  dropdownColor: AppTheme.darkCard,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Data Type'),
                  items: const [
                    DropdownMenuItem(value: 'TEXT', child: Text('Text String')),
                    DropdownMenuItem(value: 'NUMBER', child: Text('Numeric Value')),
                    DropdownMenuItem(value: 'DATE', child: Text('Date Picker')),
                    DropdownMenuItem(value: 'CHECKBOX', child: Text('Boolean Checkbox')),
                    DropdownMenuItem(value: 'DROPDOWN', child: Text('Select Dropdown')),
                  ],
                  onChanged: (val) => setDialogState(() => fieldType = val!),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Mandatory Field', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                  value: isRequired,
                  onChanged: (val) => setDialogState(() => isRequired = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (labelCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                final key = labelCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
                final res = await _api.createCustomField({
                  'name': labelCtrl.text.trim(),
                  'field_key': key,
                  'target_model': _selectedTargetModel,
                  'field_type': fieldType,
                  'is_required': isRequired,
                });
                if (res.isSuccess) _loadCustomFields();
              },
              child: const Text('Save Field'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'No-Code Customization & Fields', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DualModeBanner(
                    title: 'Dynamic Entity Extension Engine',
                    description: 'Extend any business model with custom fields without modifying PostgreSQL database schemas.',
                    aiButtonLabel: 'AI Auto-Map Schema',
                    onAiAction: () => widget.onNavigate('/copilot'),
                  ),

                  // Model Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: _models.map((m) {
                          final isSelected = m == _selectedTargetModel;
                          return ChoiceChip(
                            label: Text(m),
                            selected: isSelected,
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.darkCard,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedTargetModel = m);
                                _loadCustomFields();
                              }
                            },
                          );
                        }).toList(),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddFieldDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Field'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.darkBorder),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  else if (_customFields.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.darkBorder)),
                      child: Center(
                        child: Text(
                          'No custom fields configured for $_selectedTargetModel yet. Click "Add Field" to extend the schema.',
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _customFields.length,
                      itemBuilder: (ctx, idx) {
                        final f = _customFields[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.tune, color: AppTheme.accent),
                            ),
                            title: Text(f['name'] ?? 'Field', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                            subtitle: Text('Key: ${f['field_key']} • Type: ${f['field_type']}', style: const TextStyle(color: AppTheme.textMuted)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.darkBorder, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                f['is_required'] == true ? 'REQUIRED' : 'OPTIONAL',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
