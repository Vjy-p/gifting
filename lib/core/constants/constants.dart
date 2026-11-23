class Constants {
  Constants._();

  static const String geminiApiKey = String.fromEnvironment('AI_KEY');
  static const String geminiAIModel = 'gemini-2.5-flash';
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_placeholder',
  );
}
