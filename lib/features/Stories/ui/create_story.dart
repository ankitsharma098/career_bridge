import 'dart:convert';
import 'dart:io';

import 'package:android/core/utils/snackBarUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/story/story_model.dart';
import '../create_story_bloc/create_story_bloc.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({
    super.key,
  });

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _categories = [
    'success-story',
    'challenge',
    'inspiration',
    'achievement'
  ];
  String _selectedCategory = 'success-story';
  List<String> selectedTags = [];
  List<XFile> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocConsumer<StoryCreationBloc, StoryCreationState>(
      listener: (context, state) {
        if (state is StoryCreationSuccess) {
          //widget.onStoryCreated(state.story);
          SnackBarUtils.showGreenSnackBar(
              "Story Created Successfully", context);
          Navigator.pop(context, state.story);
        } else if (state is StoryCreationError) {
          SnackBarUtils.showRedSnackBar("Failed to create a Story", context);
        }
      },
      builder: (context, state) {
        if (state is StoryCreationLoading) {
          return Scaffold(
              body: Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.lightPrimary, size: 20),
          ));
        }
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Create New Story'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: _buildForm(context, state, screenSize),
          ),
        );
      },
    );
  }

  Widget _buildForm(
      BuildContext context, StoryCreationState state, Size screenSize) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor.withOpacity(0.9),
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                  context, screenSize, 'Story Title', Icons.title),
              const SizedBox(height: 10),
              _buildEnhancedTextField(
                controller: _titleController,
                hint: 'Write an engaging title',
                prefixIcon: Icons.edit_note_outlined,
              ),

              const SizedBox(height: 20),
              _buildSectionHeader(
                  context, screenSize, 'Story Content', Icons.description),
              const SizedBox(height: 10),
              _buildEnhancedTextField(
                controller: _contentController,
                hint: 'Share your story...',
                maxLines: 5,
                prefixIcon: Icons.article_outlined,
              ),

              const SizedBox(height: 20),

              // Media Upload with Enhanced Design
              _buildMediaUploadSection(context, state, screenSize),

              const SizedBox(height: 20),

              // Category Dropdown
              _buildSectionHeader(
                  context, screenSize, 'Story Category', Icons.category),
              const SizedBox(height: 10),
              _buildEnhancedDropdown(
                value: _selectedCategory,
                items: _categories,
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),

              const SizedBox(height: 20),

              // Tags Section
              _buildTagSection(screenSize),

              const SizedBox(height: 20),

              // Submit Button
              _buildSubmitButton(screenSize, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, Size screenSize, String title, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.primaryColor,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaUploadSection(
      BuildContext context, StoryCreationState state, Size screenSize) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, screenSize, 'Add Media', Icons.image),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickMultipleImages,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 60,
                    color: theme.primaryColor.withOpacity(0.7),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to upload images',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Display selected images
        _buildSelectedImagesGrid(theme),
      ],
    );
  }

  Widget _buildSelectedImagesGrid(ThemeData theme) {
    return _selectedImages.isEmpty
        ? const SizedBox.shrink()
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(_selectedImages[index].path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: theme.colorScheme.onError,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
  }

  Future<void> _pickMultipleImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    setState(() {
      // Limit to 6 images or adjust as needed
      _selectedImages.addAll(images.take(6 - _selectedImages.length));
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildTagSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionTitle(context, screenSize, 'Tags', Icons.work),
        _buildChipInputSection(
          '',
          'Add Tags',
          selectedTags,
          (value) => setState(() => selectedTags.add(value.toString())),
          screenSize,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Size screenSize, StoryCreationState state) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.03),
      child: ElevatedButton(
        onPressed: state is StoryCreationLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  Map<String, dynamic> story = {
                    'title': _titleController.text,
                    "content": _contentController.text,
                    'category': _selectedCategory,
                    "tags": jsonEncode(selectedTags),
                    'images':
                        _selectedImages.map((images) => images.path).toList(),
                  };
                  print("Story $story");

                  BlocProvider.of<StoryCreationBloc>(context).add(
                    SubmitStoryEvent(
                      story: story,
                      isEditing: false,
                      storyId: '',
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, screenSize.height * 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Create Story',
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, Size screenSize, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: screenSize.width * 0.06),
        SizedBox(width: screenSize.width * 0.02),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: screenSize.width * 0.045,
              ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: theme.primaryColor)
              : null,
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEnhancedDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.cardColor,
          prefixIcon: Icon(Icons.category_outlined, color: theme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
        ),
        dropdownColor: theme.cardColor,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: theme.textTheme.bodyMedium,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildChipInputSection(
    String label,
    String hint,
    List<String> selectedItems,
    Function(String) onAdd,
    Size screenSize,
  ) {
    final TextEditingController controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.isNotEmpty
            ? Text(
                label,
                style: TextStyle(
                  fontSize: screenSize.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              )
            : SizedBox(
                height: 0,
              ),
        SizedBox(height: screenSize.height * 0.01),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    onAdd(value);
                    controller.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text);
                  controller.clear();
                }
              },
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.01),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedItems.map((item) {
            return Chip(
              label: Text(item),
              onDeleted: () {
                setState(() {
                  selectedItems.remove(item);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
