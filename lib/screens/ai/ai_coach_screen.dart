import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';
import '../../services/budget_service.dart';
import '../../services/gemini_service.dart';
import '../../services/category_service.dart';
import '../../services/wallet_service.dart';
import '../../services/goal_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();
  final GeminiService _geminiService = GeminiService();
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();
  final GoalService _goalService = GoalService();

  final List<Map<String, String>> _conversationHistory = [];

  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _threads = [];
  String? _activeThreadId;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists &&
          doc.data() != null &&
          doc.data()!.containsKey('threads')) {
        final rawThreads = doc.data()!['threads'] as List<dynamic>;
        setState(() {
          _threads = rawThreads
              .map((t) => Map<String, dynamic>.from(t))
              .toList();

          if (_threads.isNotEmpty) {
            // Sort threads by date descending
            _threads.sort((a, b) {
              final aDate = a['date'] is Timestamp
                  ? (a['date'] as Timestamp).toDate()
                  : DateTime.parse(a['date'] as String);
              final bDate = b['date'] is Timestamp
                  ? (b['date'] as Timestamp).toDate()
                  : DateTime.parse(b['date'] as String);
              return bDate.compareTo(aDate);
            });

            _activeThreadId = _threads.first['id'];
            _loadMessagesFromActiveThread();
          } else {
            _createNewThread("New Conversation");
          }
        });
      } else {
        _createNewThread("New Conversation");
      }
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    }
  }

  void _loadMessagesFromActiveThread() {
    if (_activeThreadId == null) return;
    final thread = _threads.firstWhere(
      (t) => t['id'] == _activeThreadId,
      orElse: () => {},
    );
    if (thread.isNotEmpty) {
      final history = thread['messages'] as List<dynamic>;
      setState(() {
        _conversationHistory.clear();
        _messages.clear();
        for (var item in history) {
          final map = Map<String, dynamic>.from(item);
          _messages.add({
            'text': map['text'] ?? '',
            'isMe': map['isMe'] ?? false,
            'time': map['time'] is Timestamp
                ? (map['time'] as Timestamp).toDate()
                : DateTime.parse(map['time'] as String),
          });
          _conversationHistory.add({
            "role": map["isMe"] ? "user" : "assistant",
            "text": map["text"],
          });
        }
      });
      _scrollToBottom();
    }
  }

  void _createNewThread(String title) {
    final newId = const Uuid().v4();
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "there";

    final newThread = {
      'id': newId,
      'title': title,
      'date': Timestamp.now(),
      'messages': [
        {
          'text':
              "Hi $userName! I'm Nova, your personal finance coach. 👋 I analyze your spending patterns to offer smart budgeting tips and savings recommendations. How can I help you today?",
          'isMe': false,
          'time': Timestamp.now(),
        },
      ],
    };

    setState(() {
      _threads.add(newThread);
      _activeThreadId = newId;
      _conversationHistory.clear();
      _loadMessagesFromActiveThread();
    });

    _saveChatHistory();
  }

  Future<void> _saveChatHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final index = _threads.indexWhere((t) => t['id'] == _activeThreadId);
      if (index != -1) {
        _threads[index]['messages'] = _messages
            .map(
              (m) => {
                'text': m['text'],
                'isMe': m['isMe'],
                'time': Timestamp.fromDate(m['time'] as DateTime),
              },
            )
            .toList();
        _threads[index]['date'] = Timestamp.now();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'threads': _threads,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving chat history: $e");
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Update active thread title if it was a default placeholder
    final index = _threads.indexWhere((t) => t['id'] == _activeThreadId);
    if (index != -1 && _threads[index]['title'] == "New Conversation") {
      setState(() {
        _threads[index]['title'] = text.length > 25
            ? "${text.substring(0, 22)}..."
            : text;
      });
    }

    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': DateTime.now()});
      _isTyping = true;
    });

    _scrollToBottom();
    _textController.clear();
    _saveChatHistory();

    // Process Nova response
    Future.delayed(const Duration(milliseconds: 1800), () async {
      final transactions = await _transactionService.getTransactions().first;
      final categoryMap = await _categoryService.getCategoryMap();

      double income = 0;
      double expense = 0;

      Map<String, double> categoryTotals = {};

      for (final t in transactions) {
        if (t.type == "Income") {
          income += t.amount;
        } else {
          expense += t.amount;
        }

        final categoryName = categoryMap[t.categoryId]?.name ?? "Unknown";

        categoryTotals.update(
          categoryName,
          (value) => value + t.amount,
          ifAbsent: () => t.amount,
        );
      }

      final wallets = await _walletService.getWalletList();

      final walletSummary = wallets
          .map((w) => "${w.name}: ₹${w.balance.toStringAsFixed(0)}")
          .join("\n");

      final goals = await _goalService.getGoals().first;
      final goalSummary = goals
          .map((g) {
            final progress = (g.currentAmount / g.targetAmount * 100)
                .toStringAsFixed(0);

            return "${g.title}: ₹${g.currentAmount.toStringAsFixed(0)} / ₹${g.targetAmount.toStringAsFixed(0)} ($progress%)";
          })
          .join("\n");

      final budgets = await _budgetService.getCategoryBudgets().first;

      final budgetSummary = budgets.values
          .map((b) {
            final categoryName = categoryMap[b.categoryId]?.name ?? "Unknown";

            final spent = transactions
                .where(
                  (t) => t.type == "Expense" && t.categoryId == b.categoryId,
                )
                .fold<double>(0, (sum, t) => sum + t.amount);

            final percent = ((spent / b.amount) * 100)
                .clamp(0, 999)
                .toStringAsFixed(0);

            return "$categoryName: ₹${spent.toStringAsFixed(0)} / ₹${b.amount.toStringAsFixed(0)} ($percent%)";
          })
          .join("\n");

      final recurringSummary = transactions
          .where((t) => t.isRecurring)
          .map((t) {
            return "${t.title} • ${t.recurrence} • Next: ${t.nextOccurrence?.day}/${t.nextOccurrence?.month}/${t.nextOccurrence?.year}";
          })
          .join("\n");

      final context = await _geminiService.buildFinancialContext(
        totalIncome: income,

        totalExpense: expense,

        categoryTotals: categoryTotals,

        totalSavings: income - expense,

        walletSummary: walletSummary,

        goalSummary: goalSummary,

        budgetSummary: budgetSummary,

        recurringSummary: recurringSummary,
      );

      _conversationHistory.add({"role": "user", "text": text});

      final history = _conversationHistory
          .map((m) => "${m["role"]}: ${m["text"]}")
          .join("\n");

      final prompt =
          """
$context

Previous Conversation:

$history

Current User Question:

$text
""";

      String reply;

      try {
        reply = await _geminiService.askGemini(prompt);
      } catch (e) {
        reply = "Sorry, I couldn't connect to Gemini.\n\nError:\n$e";
      }

      _conversationHistory.add({"role": "assistant", "text": reply});

      if (_conversationHistory.length > 10) {
        _conversationHistory.removeRange(0, _conversationHistory.length - 10);
      }

      if (mounted) {
        setState(() {
          _messages.add({'text': reply, 'isMe': false, 'time': DateTime.now()});
          _isTyping = false;
        });
        _scrollToBottom();
        _saveChatHistory();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showChatHistoryOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.70,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: themeProvider.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nova Conversations",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),

                        // New Thread Action Button
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: themeProvider.primaryColor,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            "New Chat",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _createNewThread("New Conversation");
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Review and switch between your cloud-synced sessions:",
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Scrollable List of Historical Sessions/Threads
                    Expanded(
                      child: _threads.isEmpty
                          ? Center(
                              child: Text(
                                "No conversation history found.",
                                style: TextStyle(
                                  color: themeProvider.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _threads.length,
                              itemBuilder: (context, idx) {
                                final thread = _threads[idx];
                                final isSelected =
                                    thread['id'] == _activeThreadId;
                                final messagesCount =
                                    (thread['messages'] as List<dynamic>)
                                        .length;

                                final dateVal = thread['date'] is Timestamp
                                    ? (thread['date'] as Timestamp).toDate()
                                    : DateTime.parse(thread['date'] as String);
                                final dateStr = DateFormat(
                                  "dd MMM, hh:mm a",
                                ).format(dateVal);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? themeProvider.primaryColor
                                                .withOpacity(0.08)
                                          : themeProvider.backgroundColor,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? themeProvider.primaryColor
                                            : themeProvider.borderColor,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _activeThreadId = thread['id'];
                                          _loadMessagesFromActiveThread();
                                        });
                                        Navigator.pop(context);
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor: isSelected
                                            ? themeProvider.primaryColor
                                                  .withOpacity(0.2)
                                            : themeProvider.borderColor,
                                        child: Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          color: isSelected
                                              ? themeProvider.primaryColor
                                              : themeProvider.textPrimary,
                                          size: 18,
                                        ),
                                      ),
                                      title: Text(
                                        thread['title'] ?? "New Conversation",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: themeProvider.textPrimary,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "$messagesCount messages",
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color:
                                                    themeProvider.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              dateStr,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: themeProvider
                                                    .textSecondary
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const Divider(height: 24),

                    // Reset Option
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                        ),
                        icon: const Icon(Icons.delete_sweep_rounded),
                        label: const Text(
                          "Delete All Chat Sessions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: themeProvider.surfaceColor,
                              title: const Text(
                                "Clear All Sessions",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                "Are you sure you want to delete all historical sessions? This cannot be undone.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: themeProvider.textSecondary,
                                    ),
                                  ),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Delete All"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && uid != null) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .update({'threads': FieldValue.delete()});
                              setState(() {
                                _threads.clear();
                                _messages.clear();
                                _activeThreadId = null;
                                _createNewThread("New Conversation");
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Chat history successfully cleared",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint("Error clearing chat: $e");
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: themeProvider.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: themeProvider.textPrimary),
            onPressed: () => _showChatHistoryOptions(context),
          ),
          const SizedBox(width: 8),
        ],
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: themeProvider.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nova AI Coach",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Active Insights",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? themeProvider.primaryColor
                          : themeProvider.isDarkMode
                          ? const Color(0xFF1E213E)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isMe
                            ? const Radius.circular(20)
                            : Radius.zero,
                        bottomRight: isMe
                            ? Radius.zero
                            : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.4,
                        color: isMe ? Colors.white : themeProvider.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(
                      Icons.smart_toy_rounded,
                      size: 16,
                      color: themeProvider.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Nova is writing...",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Suggestions
          if (!_isTyping)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _suggestionChip("Analyze my spending"),
                  _suggestionChip("Budget suggestions"),
                  _suggestionChip("Savings recommendations"),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              border: Border(top: BorderSide(color: themeProvider.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(color: themeProvider.textPrimary),
                    decoration: InputDecoration(
                      hintText: "Ask Nova...",
                      hintStyle: TextStyle(
                        color: themeProvider.textSecondary.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: themeProvider.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 20),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(String text) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: themeProvider.isDarkMode
            ? const Color(0xFF1E213E)
            : Colors.grey.shade100,
        side: BorderSide(color: themeProvider.borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: themeProvider.primaryColor,
          ),
        ),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}
