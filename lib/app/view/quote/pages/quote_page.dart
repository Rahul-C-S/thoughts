import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughts/app/config/theme/app_colors.dart';
import 'package:thoughts/app/controller/quote/quote_controller.dart';
import 'package:thoughts/app/model/quote/quote_model.dart';
import 'package:thoughts/app/view/common/widgets/loader.dart';

class QuotesPage extends StatelessWidget {
  QuotesPage({super.key});

  final _controller = Get.find<QuoteController>();

  void _handleShare(String text) {
    Share.share(text, subject: 'Inspire today with Thoughts');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return _buildScaffold(context, constraints, orientation);
          },
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    BoxConstraints constraints,
    Orientation orientation,
  ) {
    return Obx(
        () => SafeArea(
          child:
              _controller.isLoading.value
                  ? const Center(child: Loader())
                  : _buildContent(constraints, orientation),
        ),
      );

      
  }



  Widget _buildContent(BoxConstraints constraints, Orientation orientation) {
    final double maxWidth = constraints.maxWidth;
    final double maxHeight = constraints.maxHeight;

    final bool isPhone = maxWidth < 600;
    final bool isTablet = maxWidth >= 600 && maxWidth < 1024;
    final bool isDesktop = maxWidth >= 1024;

    final double horizontalPadding =
        isPhone
            ? maxWidth * 0.04
            : isTablet
            ? maxWidth * 0.05
            : maxWidth * 0.06;

    int columns = 1;
    if (orientation == Orientation.landscape && isPhone) {
      columns = 2;
    } else if (isTablet) {
      columns = orientation == Orientation.portrait ? 2 : 3;
    } else if (isDesktop) {
      columns = orientation == Orientation.portrait ? 3 : 4;
    }

    final bool useSideBySideLayout =
        orientation == Orientation.landscape && isPhone && maxHeight < 500;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isPhone ? 12 : 16,
      ),
      child:
          useSideBySideLayout
              ? _buildLandscapeContent(constraints, columns)
              : _buildPortraitContent(constraints, columns),
    );
  }

  Widget _buildLandscapeContent(BoxConstraints constraints, int columns) {
    final double maxWidth = constraints.maxWidth;
    final double todaysQuoteWidth = maxWidth * 0.45;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: todaysQuoteWidth,
          child: _buildTodaysQuoteCard(
            Size(todaysQuoteWidth, constraints.maxHeight),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
                child: Row(
                  children: [
                    const Text(
                      'Picked for you',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Obx(
                        () => Text(
                          "${_controller.recommendedQuotes.length}",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: constraints.maxHeight - 80,
                child: Obx(
                  () => ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _controller.recommendedQuotes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildCompactQuoteCard(
                          _controller.recommendedQuotes[index],
                          index,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitContent(BoxConstraints constraints, int columns) {
    final bool isPhone = constraints.maxWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTodaysQuoteCard(
          Size(constraints.maxWidth, constraints.maxHeight * 0.3),
        ),

        SizedBox(height: isPhone ? 24 : 32),

        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Text(
                'Picked for you',
                style: TextStyle(
                  fontSize: isPhone ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(
                  () => Text(
                    "${_controller.recommendedQuotes.length}",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isPhone ? 12 : 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        columns == 1
            ? _buildQuoteListView()
            : _buildQuoteGridView(columns, constraints.maxWidth),

        SizedBox(height: isPhone ? 80 : 100),
      ],
    );
  }

  Widget _buildTodaysQuoteCard(Size size) {
    final bool isSmallScreen = size.width < 600;
    final bool isLandscapeSmall = size.height < 500 && size.width < 900;

    final double fontSize =
        isLandscapeSmall ? 16 : (size.width * 0.045).clamp(16.0, 28.0);

    final double padding =
        isLandscapeSmall ? 16 : (size.width * 0.06).clamp(20.0, 40.0);

    return Card(
      elevation: 8,
      shadowColor: const Color(0xFF6A11CB).withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Today's Quote",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  onPressed:
                      () => _handleShare(
                        '${_controller.todaysQuote.value.quote} \n -${_controller.todaysQuote.value.author}',
                      ),
                  iconSize: isSmallScreen ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: isSmallScreen ? 32 : 40,
                    minHeight: isSmallScreen ? 32 : 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                "\"${_controller.todaysQuote.value.quote}\"",
                style: TextStyle(
                  fontSize: fontSize,
                  height: 1.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),

                maxLines: isLandscapeSmall ? 4 : null,
                overflow:
                    isLandscapeSmall
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(
                () => Text(
                  "— ${_controller.todaysQuote.value.author}",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteListView() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _controller.recommendedQuotes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildQuoteCard(
              _controller.recommendedQuotes[index],
              index,
              true,
              context,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuoteGridView(int columns, double availableWidth) {
    final double cardWidth = (availableWidth - (16 * (columns - 1))) / columns;

    double heightFactor = columns <= 2 ? 200 : 220;
    final double aspectRatio = cardWidth / heightFactor;

    return Obx(
      () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: aspectRatio.clamp(1, 1.3),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _controller.recommendedQuotes.length,
        itemBuilder: (context, index) {
          return _buildQuoteCard(
            _controller.recommendedQuotes[index],
            index,
            false,
            context,
          );
        },
      ),
    );
  }

  Widget _buildCompactQuoteCard(QuoteModel quote, int index) {
    final List<List<Color>> cardGradients = [
      [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
      [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
      [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
      [Color(0xFFFBC2EB), Color(0xFFA6C1EE)],
      [Color(0xFFFFD1FF), Color(0xFFFAD0C4)],
    ];

    final gradient = cardGradients[index % cardGradients.length];

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradient[0].withOpacity(0.2),
              gradient[1].withOpacity(0.25),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradient[0], gradient[1]],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quote.author,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "\"${quote.quote}\"",
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(
    QuoteModel quote,
    int index,
    bool isListView,
    BuildContext context,
  ) {
    final List<List<Color>> cardGradients = [
      [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
      [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
      [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
      [Color(0xFFFBC2EB), Color(0xFFA6C1EE)],
      [Color(0xFFFFD1FF), Color(0xFFFAD0C4)],
    ];

    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;
    final bool isLargeScreen = size.width >= 1200;

    final gradient = cardGradients[index % cardGradients.length];

    final double quoteFontSize =
        isListView
            ? (isSmallScreen ? 15 : 16)
            : (isSmallScreen
                ? 14
                : isLargeScreen
                ? 16
                : 15);

    final double authorFontSize =
        isListView
            ? (isSmallScreen ? 13 : 14)
            : (isSmallScreen
                ? 12
                : isLargeScreen
                ? 14
                : 13);

    final EdgeInsets cardPadding =
        isListView
            ? (isSmallScreen ? EdgeInsets.all(16) : EdgeInsets.all(20))
            : (isSmallScreen ? EdgeInsets.all(16) : EdgeInsets.all(20));

    final int maxLines =
        isListView
            ? 3
            : (isSmallScreen
                ? 3
                : isLargeScreen
                ? 5
                : 4);

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradient[0].withOpacity(0.2),
              gradient[1].withOpacity(0.25),
            ],
          ),
        ),
        child: Padding(
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradient[0], gradient[1]],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.share_rounded,
                        size: isSmallScreen ? 16 : 18,
                        color: gradient[0].withOpacity(0.8),
                      ),
                      constraints: BoxConstraints(
                        minWidth: isSmallScreen ? 32 : 36,
                        minHeight: isSmallScreen ? 32 : 36,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed:
                          () => _handleShare(
                            '${quote.quote} \n -${quote.author}',
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                "\"${quote.quote}\"",
                style: TextStyle(
                  fontSize: quoteFontSize,
                  height: 1.5,
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: maxLines,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: isSmallScreen ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradient[0].withOpacity(0.8),
                      gradient[1].withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "— ${quote.author}",
                  style: TextStyle(
                    fontSize: authorFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
