class AIHealthService {
  int calculateScore({
    required double income,
    required double expense,
    required int completedGoals,
    required int totalGoals,
    required int exceededBudgets,
  }) {
    // New user / no financial data yet
    if (income == 0 &&
        expense == 0 &&
        totalGoals == 0 &&
        exceededBudgets == 0) {
      return 0;
    }

    int score = 100;

    // Spending check
    if (income > 0 && expense > income) {
      score -= 30;
    } else if (income > 0 && expense > income * 0.8) {
      score -= 10;
    }

    // Goal progress
    if (totalGoals > 0) {
      final progress = completedGoals / totalGoals;

      if (progress < 0.25) {
        score -= 10;
      } else if (progress > 0.75) {
        score += 5;
      }
    }

    // Budget breaches
    score -= exceededBudgets * 5;

    return score.clamp(0, 100);
  }

  String getHealthLabel(int score) {
    if (score == 0) {
      return "No Available";
    } else if (score >= 90) {
      return "Excellent";
    } else if (score >= 75) {
      return "Good";
    } else if (score >= 60) {
      return "Average";
    } else if (score >= 40) {
      return "Needs Improvement";
    } else {
      return "Critical";
    }
  }

  String getSuggestion(int score) {
    if (score == 0) {
      return "Add your income and expenses to generate your financial health score.";
    }

    if (score >= 90) {
      return "You're managing your finances very well. Keep it up!";
    }

    if (score >= 75) {
      return "You're doing well. Focus on increasing savings.";
    }

    if (score >= 60) {
      return "Reduce unnecessary spending and review your budgets.";
    }

    if (score >= 40) {
      return "Your expenses are getting high. Review spending carefully.";
    }

    return "Immediate financial attention is recommended.";
  }
}
