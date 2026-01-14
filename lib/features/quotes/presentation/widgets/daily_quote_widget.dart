import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/settings_helper.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/quote.dart';
import '../bloc/quotes_bloc.dart';
import '../pages/share_quote_page.dart';

class DailyQuoteWidget extends StatefulWidget {
  const DailyQuoteWidget({super.key});

  @override
  State<DailyQuoteWidget> createState() => _DailyQuoteWidgetState();
}

class _DailyQuoteWidgetState extends State<DailyQuoteWidget> {
  Quote? _lastQuote;
  bool _lastIsFavorite = false;

  @override
  void initState() {
    super.initState();
    // Load daily quote when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotesBloc>().add(const GetDailyQuoteEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuotesBloc, QuotesState>(
      listener: (context, state) {
        if (state is QuotesLoaded) {
          _lastQuote = state.quote;
          _lastIsFavorite = state.isFavorite;
        }
      },
      builder: (context, state) {
        // Use cached data if available to prevent flicker
        if ((state is FavoritesLoaded || state is QuotesLoading) &&
            _lastQuote != null) {
          return _buildQuoteCard(_lastQuote!, _lastIsFavorite);
        }

        if (state is QuotesLoading && _lastQuote == null) {
          return _buildLoadingCard();
        }

        if (state is QuotesError && _lastQuote == null) {
          return _buildErrorCard(state.message);
        }

        if (state is QuotesLoaded) {
          return _buildQuoteCard(state.quote, state.isFavorite);
        }

        if (_lastQuote != null) {
          return _buildQuoteCard(_lastQuote!, _lastIsFavorite);
        }

        return _buildLoadingCard();
      },
    );
  }

  Widget _buildLoadingCard() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Quote quote, bool isFavorite) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.primaryBlue.withValues(alpha: 0.2),
                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.primaryBlue.withValues(alpha: 0.15),
                  AppTheme.primaryBlue.withValues(alpha: 0.08),
                ],
        ),
        color: isDark ? null : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Quote of the Day"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.quoteOfTheDay,
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.red
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  size: 20,
                ),
                onPressed: () {
                  if (isFavorite) {
                    context
                        .read<QuotesBloc>()
                        .add(RemoveFavoriteQuoteEvent(quote));
                  } else {
                    context
                        .read<QuotesBloc>()
                        .add(SaveFavoriteQuoteEvent(quote));
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quote text
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              final fontSize =
                  SettingsHelper.getFontSizeFromState(settingsState);
              return Text(
                quote.text,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          const SizedBox(height: 12),
          // Author and share button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '— ${quote.author}',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.share,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShareQuotePage(quote: quote),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            ErrorHandler.getErrorMessage(errorMessage),
            style: GoogleFonts.poppins(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              context.read<QuotesBloc>().add(const GetDailyQuoteEvent());
            },
            child: Text(
              AppStrings.retry,
              style: GoogleFonts.poppins(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
