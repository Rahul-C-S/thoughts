import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/config/theme/app_colors.dart';
import 'package:thoughts/app/model/quote/quote_model.dart';

class QuoteController extends GetxController {
  List<QuoteModel> _allQuotes = [];
  List<int> _usedIndices = [];
  final Random _random = Random();
  final assetPath = 'assets/json/quotes.json';

  RxBool isLoading = true.obs;
  final Rx<QuoteModel> todaysQuote = QuoteModel(quote: '', author: '').obs;

  final RxList<QuoteModel> recommendedQuotes = <QuoteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchQuotes();
  }

  // Separate method for loading quotes
  Future<void> _fetchQuotes() async {
    isLoading.value = true;
    try {
      // Fetch quotes and update the Rx variables
      final todaysQuoteList = await getRandomQuotes(1);
      final recommendedQuotesList = await getRandomQuotes(12);

      if (todaysQuoteList.isNotEmpty) {
        todaysQuote.value = todaysQuoteList.first;
      }

      recommendedQuotes.value = recommendedQuotesList;
      isLoading.value = false;
    } catch (e, s) {
      isLoading.value = false;

      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      debugPrint(s.toString());
    }
  }

  // Load quotes from a JSON file in the assets folder
  Future<void> loadQuotes() async {
    try {
      // Read the JSON file from assets
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      // Convert JSON data to Quote objects
      _allQuotes =
          jsonList
              .map((item) => QuoteModel.fromJson(item as Map<String, dynamic>))
              .toList();

      // Reset used indices when loading new quotes
      _usedIndices = [];
      debugPrint('Quotes loaded');
    } catch (e) {
      throw Exception('Failed to load quotes: $e');
    }
  }

  // Get n random quotes without repetition
  Future<List<QuoteModel>> getRandomQuotes(int n) async {
    await loadQuotes();

    if (_allQuotes.isEmpty) {
      throw Exception('Quotes not loaded. Call loadQuotes() first.');
    }

    if (n <= 0) {
      return [];
    }

    // If we're asking for more quotes than are available or remaining
    if (n > _allQuotes.length) {
      n = _allQuotes.length;
    }

    // If we've used all quotes, reset the used indices
    if (_usedIndices.length >= _allQuotes.length) {
      _usedIndices = [];
    }

    // If we're asking for more quotes than are remaining
    if (n > _allQuotes.length - _usedIndices.length) {
      n = _allQuotes.length - _usedIndices.length;
    }

    List<QuoteModel> selectedQuotes = [];

    // Select n random quotes
    while (selectedQuotes.length < n) {
      int randomIndex = _random.nextInt(_allQuotes.length);
      if (!_usedIndices.contains(randomIndex)) {
        selectedQuotes.add(_allQuotes[randomIndex]);
        _usedIndices.add(randomIndex);
      }
    }

    return selectedQuotes;
  }

  // Reset used indices to allow selecting all quotes again
  void resetSelection() {
    _usedIndices = [];
  }

  // Get the total number of quotes
  int get totalQuotes => _allQuotes.length;

  // Get the number of quotes that have been used
  int get usedQuotes => _usedIndices.length;

  // Get the number of quotes that are still available
  int get availableQuotes => _allQuotes.length - _usedIndices.length;
}
