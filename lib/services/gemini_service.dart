import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  String get _apiKey => dotenv.env['GEMINI_API_KEY']!;

  static const String _url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  Future<String> askGemini(String prompt) async {
    final response = await http.post(
      Uri.parse("$_url?key=$_apiKey"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> buildFinancialContext({
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categoryTotals,
    required double totalSavings,
    required String walletSummary,
    required String goalSummary,
    required String budgetSummary,
    required String recurringSummary,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln("""
You are Nova, the AI Financial Coach inside the Finova app.

Your role is to help users understand and improve their finances.

Rules:
- Never greet repeatedly.
- Continue the conversation naturally.
- Answer directly.
- Keep responses under 150 words.
- Use ONLY the financial data provided below.
- Never invent financial values.
- If some information is unavailable, clearly mention it.
- Give practical and realistic suggestions.
- If the user's financial situation is already healthy, acknowledge that instead of always suggesting they cut expenses.
- Explain your reasoning briefly when making recommendations.
- Consider income, expenses, budgets, wallets, savings goals and recurring payments before making recommendations.
- If a user asks whether they can afford something, analyze wallet balances, savings, upcoming recurring payments and budget usage before answering.
- If the user asks how to save money, identify the biggest spending categories first.
- Encourage good financial habits instead of only giving numbers.
""");

    buffer.writeln(
      "Today's Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}\n",
    );

    buffer.writeln();

    buffer.writeln("Income: ₹${totalIncome.toStringAsFixed(0)}");
    buffer.writeln("Expense: ₹${totalExpense.toStringAsFixed(0)}");
    buffer.writeln("Savings: ₹${totalSavings.toStringAsFixed(0)}");

    buffer.writeln("\nCategory Spending:");

    categoryTotals.forEach((category, amount) {
      buffer.writeln("- $category : ₹${amount.toStringAsFixed(0)}");
    });

    buffer.writeln();

    buffer.writeln("Wallet Balances:");

    buffer.writeln(
      walletSummary.isEmpty ? "No wallets available." : walletSummary,
    );

    buffer.writeln();

    buffer.writeln("Savings Goals:");

    buffer.writeln(goalSummary.isEmpty ? "No active goals." : goalSummary);

    buffer.writeln();

    buffer.writeln("Budgets:");

    buffer.writeln(budgetSummary.isEmpty ? "No budgets." : budgetSummary);

    buffer.writeln();

    buffer.writeln("Upcoming Recurring Payments:");

    buffer.writeln(
      recurringSummary.isEmpty ? "No recurring payments." : recurringSummary,
    );

    buffer.writeln("""
Response Style:
- Use short paragraphs.
- Use bullet points when appropriate.
- Highlight important numbers.
- Avoid repeating information.
""");

    return buffer.toString();
  }
}
