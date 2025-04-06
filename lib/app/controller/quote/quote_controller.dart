import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:thoughts/app/model/quote/quote_model.dart';
import 'package:thoughts/app/utils/snackbar.dart';

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

  Future<void> _fetchQuotes() async {
    isLoading.value = true;
    try {
      final todaysQuoteList = await getRandomQuotes(1);
      final recommendedQuotesList = await getRandomQuotes(12);

      if (todaysQuoteList.isNotEmpty) {
        todaysQuote.value = todaysQuoteList.first;
      }

      recommendedQuotes.value = recommendedQuotesList;
      isLoading.value = false;
    } catch (e, s) {
      isLoading.value = false;

      showSnackbar(
        title: 'Error',
        message: e.toString(),
        type: SnackbarType.error,
      );
      debugPrint(s.toString());
    }
  }

  Future<void> loadQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _allQuotes =
          jsonList
              .map((item) => QuoteModel.fromJson(item as Map<String, dynamic>))
              .toList();

      _usedIndices = [];
      debugPrint('Quotes loaded');
    } catch (e) {
      throw Exception('Failed to load quotes: $e');
    }
  }

  Future<List<QuoteModel>> getRandomQuotes(int n) async {
    await loadQuotes();

    if (_allQuotes.isEmpty) {
      throw Exception('Quotes not loaded. Call loadQuotes() first.');
    }

    if (n <= 0) {
      return [];
    }

    if (n > _allQuotes.length) {
      n = _allQuotes.length;
    }

    if (_usedIndices.length >= _allQuotes.length) {
      _usedIndices = [];
    }

    if (n > _allQuotes.length - _usedIndices.length) {
      n = _allQuotes.length - _usedIndices.length;
    }

    List<QuoteModel> selectedQuotes = [];

    while (selectedQuotes.length < n) {
      int randomIndex = _random.nextInt(_allQuotes.length);
      if (!_usedIndices.contains(randomIndex)) {
        selectedQuotes.add(_allQuotes[randomIndex]);
        _usedIndices.add(randomIndex);
      }
    }

    return selectedQuotes;
  }

  void resetSelection() {
    _usedIndices = [];
  }

  int get totalQuotes => _allQuotes.length;

  int get usedQuotes => _usedIndices.length;

  int get availableQuotes => _allQuotes.length - _usedIndices.length;
}
