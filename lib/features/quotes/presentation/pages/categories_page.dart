import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/browse_quotes_bloc.dart';
import '../../domain/entities/category.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<BrowseQuotesBloc>().add(const LoadCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.moreCategories,
          style: GoogleFonts.poppins(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<BrowseQuotesBloc, BrowseQuotesState>(
        builder: (context, state) {
          List<Category> categories = [];

          if (state is BrowseQuotesLoaded) {
            categories = state.categories;
          } else if (state is BrowseQuotesCategoriesLoaded) {
            categories = state.categories;
          }

          if (categories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(categories[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        context.read<BrowseQuotesBloc>().add(
              FilterByCategoryEvent(
                categoryId: category.id,
                categoryName: category.name,
              ),
            );
        Navigator.pop(context); // Go back to BrowsePage instead of replace
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (category.icon != null)
              Text(
                category.icon!,
                style: const TextStyle(fontSize: 32),
              )
            else
              const Icon(
                Icons.category,
                color: AppTheme.primaryBlue,
                size: 32,
              ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: GoogleFonts.poppins(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
