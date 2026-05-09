import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default English

  Locale get locale => _locale;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selected_language') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _locale.languageCode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return _translations[_locale.languageCode]?[key] ?? key;
  }

  // Translations Map
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Language Selection Screen
      'app_name': 'Raja Jewellers',
      'app_subtitle': 'Gold & Silver Rate Manager',
      'choose_language': 'Choose Your Language',
      'choose_language_gu': 'તમારી ભાષા પસંદ કરો',
      'continue': 'Continue',
      'gujarati': 'ગુજરાતી',
      'gujarati_subtitle': 'Gujarati',
      'english': 'English',
      'english_subtitle': 'इंग्लिश',

      // Onboarding Screen
      'skip': 'Skip',
      'next': 'Next',
      'get_started': 'Get Started',
      'onboarding_title_1': 'Exquisite Gold & Silver',
      'onboarding_desc_1': 'Discover timeless elegance with Raja Jewellers. Pure 999 gold and 925 silver pieces crafted with precision.',
      'onboarding_title_2': 'Live Rate Updates',
      'onboarding_desc_2': 'Real-time gold and silver rates. Get instant updates on 999, 916, 833, and 750 purity levels.',
      'onboarding_title_3': 'Create & Share Posters',
      'onboarding_desc_3': 'Design beautiful rate posters. Share daily gold and silver rates instantly on WhatsApp and social media.',
      'loading_ad': 'Loading advertisement...',

      // Home Screen
      'raja_jewellers': 'Raja Jewellers',
      'live_market_rates': 'Live Market Rates',
      'settings': 'Settings',
      'live': 'LIVE',
      'market_rates': 'Market Rates',
      'create_poster_theme1': 'Create Poster For Your Shop Theme 1',
      'create_poster_theme2': 'Create Poster For Your Shop Theme 2',
      'costing_details': 'Costing Details',
      'contacts': 'Contacts',
      'gold_usd': 'Gold \$',
      'silver': 'Silver',
      'usd': 'USD',
      'product': 'Product',
      'bid': 'Bid',
      'ask': 'Ask',
      'buy': 'BUY',
      'call': 'Call',
      'high': 'H',
      'low': 'L',
      'gold_costing': 'GOLD COSTING',
      'silver_costing': 'SILVER COSTING',
      'developer': 'Developer',

      // Poster Screen
      'create_poster': 'Create Poster',
      'shop_name': 'Shop Name',
      'set_shop_name': 'Set Shop Name',
      'enter_shop_name': 'Enter shop name',
      'save': 'Save',
      'cancel': 'Cancel',
      'design_style': 'Design Style',
      'classic': 'Classic',
      'minimal': 'Minimal',
      'powered_by': 'Powered by Karan',

      // Gold & Silver Labels
      'silver_999': 'Silver (999)',
      'gold_999': 'Gold (999)',
      'per_kg': '1 kg',
      'per_10g': '10 grams',
      'gold_916': '916 Hm Jewellery',
      'gold_833': '833 Hm Jewellery',
      'gold_750': '750 Hm Jewellery',

      // Common
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'done': 'Done',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'retry': 'Retry',
      'close': 'Close',
    },
    'gu': {
      // Language Selection Screen
      'app_name': 'રાજા જ્વેલર્સ',
      'app_subtitle': 'સોના અને ચાંદીના ભાવ મેનેજર',
      'choose_language': 'Choose Your Language',
      'choose_language_gu': 'તમારી ભાષા પસંદ કરો',
      'continue': 'આગળ વધો',
      'gujarati': 'ગુજરાતી',
      'gujarati_subtitle': 'Gujarati',
      'english': 'English',
      'english_subtitle': 'इंग्लिश',

      // Onboarding Screen
      'skip': 'છોડો',
      'next': 'આગળ',
      'get_started': 'શરૂ કરો',
      'onboarding_title_1': 'શ્રેષ્ઠ સોનું અને ચાંદી',
      'onboarding_desc_1': 'રાજા જ્વેલર્સ સાથે કાલાતીત સુંદરતા શોધો. શુદ્ધ 999 સોનું અને 925 ચાંદીના ટુકડાઓ ચોકસાઈ સાથે તૈયાર.',
      'onboarding_title_2': 'લાઇવ ભાવ અપડેટ',
      'onboarding_desc_2': 'રીઅલ-ટાઇમ સોના અને ચાંદીના ભાવ. 999, 916, 833 અને 750 શુદ્ધતા સ્તરો પર તાત્કાલિક અપડેટ મેળવો.',
      'onboarding_title_3': 'પોસ્ટર બનાવો અને શેર કરો',
      'onboarding_desc_3': 'સુંદર ભાવ પોસ્ટર ડિઝાઇન કરો. દરરોજના સોના અને ચાંદીના ભાવ તાત્કાલિક વોટ્સએપ અને સોશિયલ મીડિયા પર શેર કરો.',
      'loading_ad': 'જાહેરાત લોડ થઈ રહી છે...',

      // Home Screen
      'raja_jewellers': 'રાજા જ્વેલર્સ',
      'live_market_rates': 'લાઇવ માર્કેટ ભાવ',
      'settings': 'સેટિંગ્સ',
      'live': 'લાઇવ',
      'market_rates': 'માર્કેટ ભાવ',
      'create_poster_theme1': 'તમારી દુકાન માટે પોસ્ટર બનાવો થીમ 1',
      'create_poster_theme2': 'તમારી દુકાન માટે પોસ્ટર બનાવો થીમ 2',
      'costing_details': 'કોસ્ટિંગ વિગતો',
      'contacts': 'સંપર્કો',
      'gold_usd': 'સોનું \$',
      'silver': 'ચાંદી',
      'usd': 'યુએસડી',
      'product': 'ઉત્પાદન',
      'bid': 'બિડ',
      'ask': 'આસ્ક',
      'buy': 'ખરીદો',
      'call': 'કૉલ',
      'high': 'હાઇ',
      'low': 'લો',
      'gold_costing': 'સોનું કોસ્ટિંગ',
      'silver_costing': 'ચાંદી કોસ્ટિંગ',
      'developer': 'ડેવલપર',

      // Poster Screen
      'create_poster': 'પોસ્ટર બનાવો',
      'shop_name': 'દુકાનનું નામ',
      'set_shop_name': 'દુકાનનું નામ સેટ કરો',
      'enter_shop_name': 'દુકાનનું નામ દાખલ કરો',
      'save': 'સાચવો',
      'cancel': 'રદ કરો',
      'design_style': 'ડિઝાઇન સ્ટાઇલ',
      'classic': 'ક્લાસિક',
      'minimal': 'મિનિમલ',
      'powered_by': 'Powered by Karan',

      // Gold & Silver Labels
      'silver_999': 'સિલ્વર (999)',
      'gold_999': 'ગોલ્ડ (999)',
      'per_kg': '1 કિલો',
      'per_10g': '10 ગ્રામ',
      'gold_916': '916 Hm દાગીના',
      'gold_833': '833 Hm દાગીના',
      'gold_750': '750 Hm દાગીના',

      // Common
      'ok': 'બરાબર',
      'yes': 'હા',
      'no': 'ના',
      'done': 'પૂર્ણ',
      'error': 'ભૂલ',
      'success': 'સફળતા',
      'loading': 'લોડ થઈ રહ્યું છે...',
      'retry': 'ફરી પ્રયાસ કરો',
      'close': 'બંધ',
    },
  };
}
