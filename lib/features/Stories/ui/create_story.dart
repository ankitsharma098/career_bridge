import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/story/story_model.dart';
import '../create_story_bloc/create_story_bloc.dart';

class CreateStoryScreen extends StatefulWidget {
  final Function(StoryModel) onStoryCreated;
  const CreateStoryScreen({super.key ,required this.onStoryCreated});

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
  List<String> _tags = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryCreationBloc, StoryCreationState>(
      listener: (context, state) {
        if (state is StoryCreationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Story created successfully!')),
          );
          Navigator.pop(context);
        } else if (state is StoryCreationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Create Story'),
            actions: [
              if (state is! StoryCreationLoading)
                TextButton(
                  onPressed: _submitForm,
                  child: Text('Post'),
                ),
            ],
          ),
          body: _buildForm(context, state),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, StoryCreationState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildMediaUpload(context, state),
            SizedBox(height: 16),
            _buildCategoryDropdown(),
            SizedBox(height: 16),
            _buildTagsInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaUpload(BuildContext context, StoryCreationState state) {
    File? mediaFile = state is StoryCreationEditing ? state.mediaFile : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Media', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(context),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: mediaFile != null
                ? Image.file(mediaFile, fit: BoxFit.cover)
                : Center(
              child: Icon(Icons.add_photo_alternate, size: 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.replaceAll('-', ' ').toTitleCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildTagsInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ..._tags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
                context.read<StoryCreationBloc>().add(UpdateTagsEvent(_tags));
              },
            )),
            ActionChip(
              label: Icon(Icons.add),
              onPressed: () => _showAddTagDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      context.read<StoryCreationBloc>().add(
        UpdateMediaEvent(File(image.path)),
      );
    }
  }

  Future<void> _showAddTagDialog(BuildContext context) async {
    final TextEditingController tagController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Tag'),
        content: TextField(
          controller: tagController,
          decoration: InputDecoration(hintText: 'Enter tag'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (tagController.text.isNotEmpty) {
                setState(() {
                  _tags.add(tagController.text.toLowerCase());
                });
                context.read<StoryCreationBloc>().add(UpdateTagsEvent(_tags));
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<StoryCreationBloc>().add(
        SubmitStoryEvent(
          title: _titleController.text,
          content: _contentController.text,
          mediaFile: context.read<StoryCreationBloc>().state is StoryCreationEditing
              ? (context.read<StoryCreationBloc>().state as StoryCreationEditing).mediaFile
              : null,
          tags: _tags,
          category: _selectedCategory,
        ),
      );
    }
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}