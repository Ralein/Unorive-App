import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unorive/app/router.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';
import 'package:unorive/core/widgets/app_button.dart';
import 'package:unorive/core/widgets/empty_state_view.dart';
import 'package:unorive/core/widgets/glass_card.dart';
import 'package:unorive/data/models/saved_place.dart';
import 'package:unorive/features/auth/auth_provider.dart';
import 'package:unorive/features/saved_places/saved_places_provider.dart';
import 'package:unorive/features/home_map/map_provider.dart';

/// Screen listing user's saved locations, offering CRUD capabilities and Firestore sync status.
class SavedPlacesScreen extends ConsumerStatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  ConsumerState<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends ConsumerState<SavedPlacesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController(text: '51.5074');
  final _lngController = TextEditingController(text: '-0.1278');
  String _selectedIconName = 'home';

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'transit':
        return Icons.directions_bus_rounded;
      case 'star':
      default:
        return Icons.star_rounded;
    }
  }

  void _showAddPlaceDialog(BuildContext context) {
    _nameController.clear();
    // Default coordinates to London or try to read from search/location
    _latController.text = '51.5074';
    _lngController.text = '-0.1278';
    setState(() {
      _selectedIconName = 'home';
    });

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            
            Widget iconOption(String iconName, IconData iconData) {
              final isSelected = _selectedIconName == iconName;
              return GestureDetector(
                onTap: () {
                  setDialogState(() {
                    _selectedIconName = iconName;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor.withOpacity(0.15) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? theme.primaryColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: const BorderSide(color: AppColors.borderDark),
              ),
              title: Text(
                'Add Saved Place',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.borderDark),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      // Latitude field
                      TextFormField(
                        controller: _latController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.borderDark),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter latitude';
                          final val = double.tryParse(value);
                          if (val == null || val < -90 || val > 90) return 'Invalid latitude (-90 to 90)';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Longitude field
                      TextFormField(
                        controller: _lngController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.borderDark),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter longitude';
                          final val = double.tryParse(value);
                          if (val == null || val < -180 || val > 180) return 'Invalid longitude (-180 to 180)';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Icon Picker label
                      Text(
                        'Choose Icon',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Icon Picker options row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          iconOption('home', Icons.home_rounded),
                          iconOption('work', Icons.work_rounded),
                          iconOption('school', Icons.school_rounded),
                          iconOption('transit', Icons.directions_bus_rounded),
                          iconOption('star', Icons.star_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final name = _nameController.text.trim();
                      final lat = double.parse(_latController.text.trim());
                      final lng = double.parse(_lngController.text.trim());

                      final newPlace = SavedPlace(
                        id: 'place_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        latitude: lat,
                        longitude: lng,
                        iconName: _selectedIconName,
                        createdAt: DateTime.now(),
                      );

                      await ref.read(savedPlacesProvider.notifier).addPlace(newPlace);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('Save', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedPlaces = ref.watch(savedPlacesProvider);
    final authState = ref.watch(authStateProvider);
    final isAnonymous = authState.value?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Saved Places',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('add_place_button'),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            onPressed: () => _showAddPlaceDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Cloud Sync Warning Banner for Anonymous/Guest users
            if (isAnonymous)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: GlassCard(
                  borderColor: AppColors.warning.withOpacity(0.3),
                  backgroundColor: AppColors.warning.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off_rounded, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Sign in to enable automatic cloud backup and sync.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        TextButton(
                          onPressed: () => context.push(AppRouter.auth),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Main List view
            Expanded(
              child: savedPlaces.isEmpty
                  ? EmptyStateView(
                      title: 'No Saved Places',
                      description: 'Add your favorite destinations to start trips quickly.',
                      icon: Icons.bookmark_border_rounded,
                      actionText: 'Add New Place',
                      onActionPressed: () => _showAddPlaceDialog(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: savedPlaces.length,
                      itemBuilder: (context, index) {
                        final place = savedPlaces[index];
                        return Dismissible(
                          key: Key(place.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: AppSpacing.xl),
                            margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
                          ),
                          onDismissed: (_) {
                            ref.read(savedPlacesProvider.notifier).removePlace(place.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${place.name} deleted'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            child: GlassCard(
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconData(place.iconName),
                                    color: theme.primaryColor,
                                  ),
                                ),
                                title: Text(
                                  place.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkTextPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  'Coordinates: ${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.darkTextSecondary,
                                ),
                                onTap: () {
                                  // Pre-fill destination and route to home map
                                  final dest = Destination(
                                    name: place.name,
                                    latitude: place.latitude,
                                    longitude: place.longitude,
                                    address: 'Saved Location',
                                  );
                                  ref.read(selectedDestinationProvider.notifier).select(dest);
                                  context.go(AppRouter.home);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
