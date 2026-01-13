import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../bloc/collections_bloc.dart';
import '../../domain/entities/collection.dart';

class CreateCollectionPage extends StatefulWidget {
  final Collection? collection; // If provided, we're editing; otherwise creating

  const CreateCollectionPage({super.key, this.collection});

  @override
  State<CreateCollectionPage> createState() => _CreateCollectionPageState();
}

class _CreateCollectionPageState extends State<CreateCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedColor;
  String? _selectedIcon;

  final List<String> _colors = [
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#FFA07A', // Orange
    '#98D8C8', // Green
    '#F7DC6F', // Yellow
    '#BB8FCE', // Purple
  ];

  final List<String> _icons = ['📁', '⭐', '💡', '🎯', '🌟', '💪', '❤️', '📚'];

  bool get _isEditing => widget.collection != null;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing collection data
    if (_isEditing && widget.collection != null) {
      _nameController.text = widget.collection!.name;
      _descriptionController.text = widget.collection!.description ?? '';
      _selectedColor = widget.collection!.color;
      _selectedIcon = widget.collection!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Collection' : 'Create Collection',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocConsumer<CollectionsBloc, CollectionsState>(
            listener: (context, state) {
              if (state is CollectionsLoaded) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isEditing
                          ? 'Collection updated successfully'
                          : 'Collection created successfully',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is CollectionsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ErrorHandler.getErrorMessage(state.message),
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: state is CollectionsLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          if (_isEditing && widget.collection != null) {
                            // Update existing collection
                            final descriptionText = _descriptionController.text.trim();
                            final updatedCollection = widget.collection!.copyWith(
                              name: _nameController.text.trim(),
                              description: descriptionText.isEmpty ? null : descriptionText,
                              color: _selectedColor,
                              icon: _selectedIcon,
                            );
                            context.read<CollectionsBloc>().add(
                                  UpdateCollectionEvent(collection: updatedCollection),
                                );
                          } else {
                            // Create new collection
                            context.read<CollectionsBloc>().add(
                                  CreateCollectionEvent(
                                    name: _nameController.text.trim(),
                                    description:
                                        _descriptionController.text.trim().isEmpty
                                            ? null
                                            : _descriptionController.text.trim(),
                                    color: _selectedColor,
                                    icon: _selectedIcon,
                                  ),
                                );
                          }
                        }
                      },
                child: state is CollectionsLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Save' : 'Create',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Collection Name
              Text(
                'Collection Name',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., Morning Motivation',
                  hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppTheme.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a collection name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'Description (Optional)',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a description for your collection',
                  hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppTheme.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Color Selection
              Text(
                'Color (Optional)',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = isSelected ? null : color;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Icon Selection
              Text(
                'Icon (Optional)',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _icons.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = isSelected ? null : icon;
                      });
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                            : AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
