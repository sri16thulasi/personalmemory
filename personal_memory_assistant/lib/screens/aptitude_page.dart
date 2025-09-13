import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'base_preparation_page.dart';

class AptitudePage extends BasePreparationPage {
  const AptitudePage({Key? key, String? initialTopic, String? initialLevel})
      : super(key: key, initialTopic: initialTopic, initialLevel: initialLevel);

  @override
  _AptitudePageState createState() => _AptitudePageState();
}

class _AptitudePageState extends BasePreparationPageState<AptitudePage> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    topics = {
      'time_and_work': {
        'name': 'Time and Work',
        'formulas': [
          'Work = Rate × Time',
          'Combined Rate = Rate1 + Rate2',
          'Time to complete work together = Total Work / Combined Rate',
        ],
        'real_world_applications': [
          'Project management for estimating task completion times.',
          'Workforce planning in manufacturing.',
          'Scheduling in construction projects.',
        ],
        'questions': _generateTimeAndWorkQuestions(),
      },
      'percentage': {
        'name': 'Percentage',
        'formulas': [
          'Percentage = (Part / Whole) × 100',
          'New Value = Original × (1 + Percentage/100)',
        ],
        'real_world_applications': [
          'Financial planning for budgeting.',
          'Retail for discount calculations.',
          'Data analysis for statistical reporting.',
        ],
        'questions': _generatePercentageQuestions(),
      },
      'profit_and_loss': {
        'name': 'Profit and Loss',
        'formulas': [
          'Profit = Selling Price - Cost Price',
          'Loss = Cost Price - Selling Price',
          'Profit% = (Profit / Cost Price) × 100',
        ],
        'real_world_applications': [
          'Retail business for pricing strategies.',
          'Stock market trading.',
          'Manufacturing cost analysis.',
        ],
        'questions': _generateProfitAndLossQuestions(),
      },
      'simple_interest': {
        'name': 'Simple Interest',
        'formulas': [
          'Simple Interest = (Principal × Rate × Time) / 100',
          'Amount = Principal + Simple Interest',
        ],
        'real_world_applications': [
          'Bank loans and savings accounts.',
          'Investment planning.',
          'Personal finance calculations.',
        ],
        'questions': _generateSimpleInterestQuestions(),
      },
      'time_and_distance': {
        'name': 'Time and Distance',
        'formulas': [
          'Speed = Distance / Time',
          'Time = Distance / Speed',
          'Distance = Speed × Time',
        ],
        'real_world_applications': [
          'Logistics and transportation planning.',
          'Sports performance analysis.',
          'Travel time estimation.',
        ],
        'questions': _generateTimeAndDistanceQuestions(),
      },
    };
    currentTopic = widget.initialTopic ?? '';
    currentLevel = widget.initialLevel ?? 'easy';
    if (widget.initialTopic != null) {
      showTopicSelection = false;
      generateQuestion();
    }
    loadAchievements();
  }

  Map<String, List<Map<String, dynamic>>> _generateTimeAndWorkQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        int days = 10 + random.nextInt(10); // 10 to 19 days
        double fraction = [1 / 2, 1 / 3, 1 / 4][random.nextInt(3)];
        int answer = (days * fraction).toInt();
        List<int> options = [answer, answer + 1, answer + 2, answer - 1]..shuffle();
        return {
          'q': 'A can complete a work in $days days. How many days will it take for A to complete ${fraction == 1 / 2 ? "half" : fraction == 1 / 3 ? "1/3rd" : "1/4th"} of the work?',
          'options': options.map((e) => e.toString()).toList(),
          'a': answer.toString(),
          'explanation': 'Total work = $days days. For ${fraction == 1 / 2 ? "1/2" : fraction == 1 / 3 ? "1/3" : "1/4"} of the work, time = $days × $fraction = $answer days.',
          'common_mistakes': [
            'Dividing total days by $fraction instead of multiplying.',
            'Assuming partial work changes the rate.',
            'Ignoring the fraction of work required.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        int daysA = 6 + random.nextInt(6); // 6 to 11 days
        int daysTogether = 3 + random.nextInt(3); // 3 to 5 days
        int daysB = (daysA * daysTogether) ~/ (daysA - daysTogether);
        List<int> options = [daysB, daysB + 3, daysB - 3, daysB + 6]..shuffle();
        return {
          'q': 'A and B can complete a work in $daysTogether days together. A alone takes $daysA days. How many days will B take alone?',
          'options': options.map((e) => e.toString()).toList(),
          'a': daysB.toString(),
          'explanation': 'Combined rate = 1/$daysTogether. A\'s rate = 1/$daysA. B\'s rate = 1/$daysTogether - 1/$daysA = 1/$daysB. So, B takes $daysB days.',
          'common_mistakes': [
            'Adding rates instead of subtracting.',
            'Misinterpreting combined work rate.',
            'Forgetting to find the reciprocal for B\'s time.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        int daysA = 4 + random.nextInt(4); // 4 to 7 days
        int daysB = 6 + random.nextInt(4); // 6 to 9 days
        int daysC = 12 + random.nextInt(6); // 12 to 17 days
        double combinedRate = 1 / daysA + 1 / daysB + 1 / daysC;
        int answer = (1 / combinedRate).round();
        List<int> options = [answer, answer + 1, answer + 2, answer - 1]..shuffle();
        return {
          'q': 'A, B, and C can complete a work in $daysA, $daysB, and $daysC days respectively. How many days to complete the work together?',
          'options': options.map((e) => e.toString()).toList(),
          'a': answer.toString(),
          'explanation': 'Rates: A = 1/$daysA, B = 1/$daysB, C = 1/$daysC. Combined rate = 1/$daysA + 1/$daysB + 1/$daysC ≈ ${combinedRate.toStringAsFixed(3)}. Time = 1 / $combinedRate ≈ $answer days.',
          'common_mistakes': [
            'Adding times instead of rates.',
            'Incorrectly calculating least common multiple.',
            'Neglecting to sum all rates.',
          ],
        };
      }),
    };
  }

  Map<String, List<Map<String, dynamic>>> _generatePercentageQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        int percentage = 10 + random.nextInt(41); // 10% to 50%
        int whole = 100 + random.nextInt(101); // 100 to 200
        int answer = (whole * percentage / 100).toInt();
        List<int> options = [answer, answer + 10, answer - 10, answer + 20]..shuffle();
        return {
          'q': 'What is $percentage% of $whole?',
          'options': options.map((e) => e.toString()).toList(),
          'a': answer.toString(),
          'explanation': '$percentage% of $whole = ($percentage/100) × $whole = $answer.',
          'common_mistakes': [
            'Multiplying by $percentage instead of 0.$percentage.',
            'Dividing instead of multiplying.',
            'Misplacing the decimal point.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        int original = 400 + random.nextInt(201); // 400 to 600
        int discount = 10 + random.nextInt(21); // 10% to 30%
        int discountAmount = (original * discount / 100).toInt();
        int answer = original - discountAmount;
        List<int> options = [answer, answer + 25, answer - 25, answer + 50]..shuffle();
        return {
          'q': 'A price of $original is discounted by $discount%. What is the final price?',
          'options': options.map((e) => e.toString()).toList(),
          'a': answer.toString(),
          'explanation': 'Discount = $original × $discount/100 = $discountAmount. Final price = $original - $discountAmount = $answer.',
          'common_mistakes': [
            'Subtracting percentage without converting to decimal.',
            'Adding discount instead of subtracting.',
            'Miscalculating percentage of total.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        int finalValue = 80 + random.nextInt(41); // 80 to 120
        int increase = 20 + random.nextInt(21); // 20% to 40%
        int decrease = 10 + random.nextInt(21); // 10% to 30%
        double original = finalValue / (1 + increase / 100) / (1 - decrease / 100);
        int answer = original.round();
        List<int> options = [answer, answer + 5, answer - 5, answer + 10]..shuffle();
        return {
          'q': 'A number is increased by $increase% and then decreased by $decrease%. If the final number is $finalValue, what was the original?',
          'options': options.map((e) => e.toString()).toList(),
          'a': answer.toString(),
          'explanation': 'Let original = x. After $increase% increase, x × ${1 + increase / 100}. After $decrease% decrease, x × ${1 + increase / 100} × ${1 - decrease / 100} = $finalValue. So, x = $finalValue / (${1 + increase / 100} × ${1 - decrease / 100}) ≈ $answer.',
          'common_mistakes': [
            'Assuming increase and decrease cancel out.',
            'Applying percentages in wrong order.',
            'Dividing by incorrect factor.',
          ],
        };
      }),
    };
  }

  Map<String, List<Map<String, dynamic>>> _generateProfitAndLossQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        int cp = 100 + random.nextInt(101); // 100 to 200
        int sp = cp + random.nextInt(51); // cp to cp+50
        int profit = sp - cp;
        int profitPercent = (profit * 100 ~/ cp);
        List<int> options = [profitPercent, profitPercent + 5, profitPercent - 5, profitPercent + 10]..shuffle();
        return {
          'q': 'A shopkeeper buys an item for \$$cp and sells it for \$$sp. What is the profit percentage?',
          'options': options.map((e) => '$e%').toList(),
          'a': '$profitPercent%',
          'explanation': 'Profit = $sp - $cp = $profit. Profit% = ($profit / $cp) × 100 = $profitPercent%.',
          'common_mistakes': [
            'Using selling price instead of cost price in percentage calculation.',
            'Misinterpreting profit as selling price.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        int sp = 100 + random.nextInt(101); // 100 to 200
        int lossPercent = 10 + random.nextInt(16); // 10% to 25%
        int cp = (sp * 100 ~/ (100 - lossPercent));
        List<int> options = [cp, cp + 20, cp - 20, cp + 50]..shuffle();
        return {
          'q': 'An item is sold for \$$sp at a loss of $lossPercent%. What was the cost price?',
          'options': options.map((e) => e.toString()).toList(),
          'a': cp.toString(),
          'explanation': 'Let cost price = x. Selling price = x × (1 - $lossPercent/100) = $sp. So, ${100 - lossPercent}x/100 = $sp, x = $sp × 100 / ${100 - lossPercent} = $cp.',
          'common_mistakes': [
            'Assuming loss percentage is applied to selling price.',
            'Incorrectly setting up the equation.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        int sp = 100; // Fixed SP for both items
        int gainPercent = 20 + random.nextInt(11); // 20% to 30%
        int lossPercent = 10 + random.nextInt(11); // 10% to 20%
        int cp1 = (sp * 100 ~/ (100 + gainPercent));
        int cp2 = (sp * 100 ~/ (100 - lossPercent));
        int totalCP = cp1 + cp2;
        int totalSP = 2 * sp;
        int loss = totalCP - totalSP;
        List<String> options = ['Loss of \$$loss', 'No profit/loss', 'Profit of \$$loss', 'Profit of \$${loss + 4}']..shuffle();
        return {
          'q': 'A shopkeeper sells two items at \$$sp each. On one, he gains $gainPercent%, and on the other, he loses $lossPercent%. What is his overall profit or loss?',
          'options': options,
          'a': 'Loss of \$$loss',
          'explanation': 'First item: CP = $sp / ${1 + gainPercent / 100} = $cp1, Profit = $sp - $cp1 = ${sp - cp1}. Second item: CP = $sp / ${1 - lossPercent / 100} = $cp2, Loss = $cp2 - $sp = ${cp2 - sp}. Total CP = $cp1 + $cp2 = $totalCP, Total SP = $totalSP. Loss = $totalCP - $totalSP = $loss.',
          'common_mistakes': [
            'Assuming percentages cancel out.',
            'Not calculating individual cost prices.',
            'Misinterpreting net effect.',
          ],
        };
      }),
    };
  }

  Map<String, List<Map<String, dynamic>>> _generateSimpleInterestQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        int principal = 1000 + random.nextInt(1001); // 1000 to 2000
        int rate = 5 + random.nextInt(6); // 5% to 10%
        int time = 1 + random.nextInt(3); // 1 to 3 years
        int si = (principal * rate * time ~/ 100);
        List<int> options = [si, si + 10, si - 10, si + 20]..shuffle();
        return {
          'q': 'What is the simple interest on \$$principal at $rate% per annum for $time years?',
          'options': options.map((e) => '\$$e').toList(),
          'a': '\$$si',
          'explanation': 'SI = ($principal × $rate × $time) / 100 = $si.',
          'common_mistakes': [
            'Forgetting to divide by 100.',
            'Using compound interest formula.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        int amount = 1000 + random.nextInt(501); // 1000 to 1500
        int rate = 5 + random.nextInt(6); // 5% to 10%
        int time = 2 + random.nextInt(2); // 2 to 3 years
        int principal = (amount * 100 ~/ (100 + rate * time));
        List<int> options = [principal, principal + 100, principal - 100, principal + 200]..shuffle();
        return {
          'q': 'A sum of money amounts to \$$amount in $time years at $rate% simple interest. What is the principal?',
          'options': options.map((e) => '\$$e').toList(),
          'a': '\$$principal',
          'explanation': 'Let principal = P. Amount = P + (P × $rate × $time) / 100 = $amount. So, P + ${rate * time}P/100 = $amount, ${100 + rate * time}P/100 = $amount, P = $amount × 100 / ${100 + rate * time} = $principal.',
          'common_mistakes': [
            'Assuming amount is interest.',
            'Not accounting for principal in amount.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        int time = 5 + random.nextInt(3); // 5 to 7 years
        int rate = (100 ~/ time); // Ensure doubling is exact
        List<int> options = [rate, rate + 5, rate - 5, rate + 10]..shuffle();
        return {
          'q': 'A sum of money doubles itself in $time years at simple interest. What is the rate of interest?',
          'options': options.map((e) => '$e%').toList(),
          'a': '$rate%',
          'explanation': 'Let principal = P. Amount = 2P. Interest = 2P - P = P. SI = (P × R × $time) / 100 = P. So, R × $time = 100, R = 100/$time = $rate%.',
          'common_mistakes': [
            'Assuming amount is interest.',
            'Incorrectly setting up the equation.',
          ],
        };
      }),
    };
  }

  Map<String, List<Map<String, dynamic>>> _generateTimeAndDistanceQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        int distance = 100 + random.nextInt(101); // 100 to 200 km
        int time = 2 + random.nextInt(3); // 2 to 4 hours
        int speed = distance ~/ time;
        List<int> options = [speed, speed + 10, speed - 10, speed + 20]..shuffle();
        return {
          'q': 'A car travels $distance km in $time hours. What is its speed?',
          'options': options.map((e) => '$e km/h').toList(),
          'a': '$speed km/h',
          'explanation': 'Speed = Distance / Time = $distance / $time = $speed km/h.',
          'common_mistakes': [
            'Multiplying instead of dividing.',
            'Confusing units.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        int speed1 = 50 + random.nextInt(21); // 50 to 70 km/h
        int time1 = 2 + random.nextInt(2); // 2 to 3 hours
        int speed2 = 70 + random.nextInt(21); // 70 to 90 km/h
        int time2 = 1 + random.nextInt(2); // 1 to 2 hours
        int totalDistance = speed1 * time1 + speed2 * time2;
        int totalTime = time1 + time2;
        double avgSpeed = totalDistance / totalTime.toDouble(); // Cast to double
        int answer = avgSpeed.round();
        List<int> options = [answer, answer + 5, answer - 5, answer + 10]..shuffle();
        return {
          'q': 'A train travels at $speed1 km/h for $time1 hours and then at $speed2 km/h for $time2 hours. What is the average speed?',
          'options': options.map((e) => '$e km/h').toList(),
          'a': '$answer km/h',
          'explanation': 'Total distance = $speed1 × $time1 + $speed2 × $time2 = $totalDistance km. Total time = $time1 + $time2 = $totalTime hours. Average speed = $totalDistance / $totalTime ≈ $answer km/h.',
          'common_mistakes': [
            'Averaging speeds directly.',
            'Not calculating total distance.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        int speed1 = 40 + random.nextInt(21); // 40 to 60 km/h
        int speed2 = 60 + random.nextInt(21); // 60 to 80 km/h
        int distance = 300 + random.nextInt(101); // 300 to 400 km
        int time = distance ~/ (speed1 + speed2);
        List<int> options = [time, time + 1, time - 1, time + 2]..shuffle();
        return {
          'q': 'Two cars start from the same point and travel in opposite directions at $speed1 km/h and $speed2 km/h. After how many hours will they be $distance km apart?',
          'options': options.map((e) => '$e hours').toList(),
          'a': '$time hours',
          'explanation': 'Relative speed = $speed1 + $speed2 = ${speed1 + speed2} km/h. Time = Distance / Speed = $distance / ${speed1 + speed2} = $time hours.',
          'common_mistakes': [
            'Not adding speeds for opposite directions.',
            'Using individual speeds.',
          ],
        };
      }),
    };
  }

  @override
  String getSection() => 'aptitude';

  @override
  Future<void> submitAnswer(dynamic userAnswer, bool Function(dynamic) isCorrectCheck, String correctAnswerDisplay) async {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an option')),
      );
      return;
    }
    await super.submitAnswer(
      selectedOption,
      (userAnswer) => userAnswer == currentQuestion['a'],
      currentQuestion['a'].toString(),
    );
    setState(() {
      selectedOption = null;
    });
  }

  Widget _buildTopicSelection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topicKey = topics.keys.elementAt(index);
        final topic = topics[topicKey]!;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.book, color: Colors.blue[900]),
            title: Text(topic['name'], style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            subtitle: Text('Practice ${topic['name']} problems', style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700])),
            onTap: () {
              setState(() {
                currentTopic = topicKey;
                showTopicSelection = false;
                generateQuestion();
              });
            },
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'About Aptitude Tests',
          style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is an aptitude test?',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'An aptitude test is a way to measure a job candidate’s cognitive abilities, work behaviours, or personality traits. Aptitude tests will examine your numeracy, logic and problem-solving skills, as well as how you deal with work situations. They are a proven method to assess employability skills.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Aptitude tests measure a range of skills such as numerical ability, language comprehension and logical reasoning.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'What are the different types of aptitude tests?',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'There are a number of different types of aptitude test due to the range of cognitive capabilities and employer priorities. At Practice Aptitude Tests, we provide industry standard aptitude or psychometric tests for banking, accountancy, finance, law, engineering, business, marketing and vocational fields.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'The most commonly used are numerical reasoning tests, verbal reasoning tests, diagrammatic reasoning tests, situational judgement tests, mechanical reasoning tests and personality tests.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'How do I prepare for aptitude tests?',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'The best way to prepare for aptitude tests is to practice them. The more you practice aptitude tests, the better you’ll get and the higher results you’ll achieve. You can start with these aptitude test sample questions and answers.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Practice isn’t just about taking test after test though. You need to practice smartly, define which assessments you’ll need to master, reveal which areas you need to work on and follow expert advice to help you improve.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'If you’d like further practice you can try our free aptitude tests for online practice or our aptitude test pdf if you’d prefer to practice offline.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Practice smartly and measure your performance to show your results improve.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'We set up Practice Aptitude Tests to help people practice and we’re proud to say that we’ve now helped over 9 million people all over the world.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'As well as a huge vault of online assessments, we’ve also created an aptitude test resource hub full of articles and videos to help you improve. Get started with our top aptitude test tips.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Aptitude Preparation', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.blue[900],
            actions: [
              IconButton(
                icon: Icon(Icons.leaderboard, color: Colors.white),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Leaderboard', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    content: buildLeaderboard(),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: showTopicSelection
                ? _buildTopicSelection()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topics[currentTopic]!['name'],
                                    style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: currentLevel,
                                    items: ['easy', 'intermediate', 'advanced']
                                        .map((level) => DropdownMenuItem(value: level, child: Text(StringExtension(level).capitalize(), style: GoogleFonts.lora(fontSize: 16))))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        currentLevel = value!;
                                        generateQuestion();
                                      });
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  if (currentQuestion.isNotEmpty) ...[
                                    Text(
                                      'Question:',
                                      style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      currentQuestion['q'],
                                      style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 16),
                                    ...currentQuestion['options'].asMap().entries.map((entry) {
                                      int idx = entry.key;
                                      String option = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: FadeInUp(
                                          delay: Duration(milliseconds: idx * 100),
                                          child: RadioListTile<String>(
                                            title: Text(option, style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                                            value: option,
                                            groupValue: selectedOption,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedOption = value;
                                              });
                                            },
                                            activeColor: Colors.blue[900],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () => submitAnswer(
                                        selectedOption,
                                        (userAnswer) => userAnswer == currentQuestion['a'],
                                        currentQuestion['a'].toString(),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[900],
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      ),
                                      child: Text('Submit', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Formulas',
                                    style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                  ),
                                  SizedBox(height: 8),
                                  ...topics[currentTopic]!['formulas'].map((formula) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                          '• $formula',
                                          style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
                                        ),
                                      )),
                                  SizedBox(height: 16),
                                  Text(
                                    'Real-World Applications',
                                    style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                  ),
                                  SizedBox(height: 8),
                                  ...topics[currentTopic]!['real_world_applications'].map((app) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                          '• $app',
                                          style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
                                        ),
                                      )),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReferencePage(topic: currentTopic),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[900],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    ),
                                    child: Text('Reference', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(Icons.info_outline, color: Colors.blue[900], size: 30),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About Aptitude Tests',
          ),
        ),
      ],
    );
  }
}

class ReferencePage extends StatelessWidget {
  final String topic;

  const ReferencePage({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topicNames = {
      'time_and_work': 'Time and Work',
      'percentage': 'Percentage',
      'profit_and_loss': 'Profit and Loss',
      'simple_interest': 'Simple Interest',
      'time_and_distance': 'Time and Distance',
    };

    final videoLinks = {
      'time_and_work': [
        {
          'title': 'Time and Work Concepts Playlist - Feel Free to Learn',
          'url': 'https://youtube.com/playlist?list=PLbwyTwgtmtCGWhR4gyAOnFGMD5ZFigU0n&si=EzQw03t6obQAQNh2',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Time and Work Concepts Playlist - Radhina Quants',
          'url': 'https://youtube.com/playlist?list=PLVEh8puYXfDcKsvJdfWiqxkDrvZ5Mgjwq&si=-_jKDGJu7W8cDslu',
          'channel': 'Radhina Quants',
        },
      ],
      'percentage': [
        {
          'title': 'Percentage Concepts - Radhina Quants',
          'url': 'https://www.youtube.com/watch?v=6kXjU0nO0cQ',
          'channel': 'Radhina Quants',
        },
        {
          'title': 'Percentage for Placements - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=4eW3F9v4y5k',
          'channel': 'Feel Free to Learn',
        },
      ],
      'profit_and_loss': [
        {
          'title': 'Profit and Loss Basics - Radhina Quants',
          'url': 'https://www.youtube.com/watch?v=9Q8z1lZ3v8I',
          'channel': 'Radhina Quants',
        },
        {
          'title': 'Profit and Loss Shortcuts - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=8vL2hF5K7mM',
          'channel': 'Feel Free to Learn',
        },
      ],
      'simple_interest': [
        {
          'title': 'Simple Interest Concepts - Radhina Quants',
          'url': 'https://www.youtube.com/watch?v=2kT9z7lZ5pU',
          'channel': 'Radhina Quants',
        },
        {
          'title': 'Simple Interest for Placements - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=O3j7lZ9k2qY',
          'channel': 'Feel Free to Learn',
        },
      ],
      'time_and_distance': [
        {
          'title': 'Time and Distance Basics - Radhina Quants',
          'url': 'https://www.youtube.com/watch?v=5X2hR8kV9jQ',
          'channel': 'Radhina Quants',
        },
        {
          'title': 'Time and Distance Shortcuts - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=7bX9v8kF5zU',
          'channel': 'Feel Free to Learn',
        },
      ],
    };

    final questionPapers = {
      'time_and_work': [
        {
          'title': ' Time and Work Questions',
          'url': 'https://www.geeksforgeeks.org/time-and-work/',
          'company': 'Geeks for Geeks',
        },
        {
          'title': ' Time and Work Questions',
          'url': 'https://www.faceprep.in/aptitude/time-and-work-problems/',
          'company': 'Facepreparation',
        },
      ],
      'percentage': [
        {
          'title': 'TCS Percentage Questions',
          'url': 'https://prepinsta.com/tcs/percentage/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Percentage Questions',
          'url': 'https://prepinsta.com/infosys/percentage/',
          'company': 'Infosys',
        },
        {
          'title': 'Wipro Percentage Questions',
          'url': 'https://prepinsta.com/wipro/percentage/',
          'company': 'Wipro',
        },
      ],
      'profit_and_loss': [
        {
          'title': 'TCS Profit and Loss Questions',
          'url': 'https://prepinsta.com/tcs/profit-and-loss/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Profit and Loss Questions',
          'url': 'https://prepinsta.com/infosys/profit-and-loss/',
          'company': 'Infosys',
        },
        {
          'title': 'Wipro Profit and Loss Questions',
          'url': 'https://prepinsta.com/wipro/profit-and-loss/',
          'company': 'Wipro',
        },
      ],
      'simple_interest': [
        {
          'title': 'TCS Simple Interest Questions',
          'url': 'https://prepinsta.com/tcs/simple-interest/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Simple Interest Questions',
          'url': 'https://prepinsta.com/infosys/simple-interest/',
          'company': 'Infosys',
        },
        {
          'title': 'Wipro Simple Interest Questions',
          'url': 'https://prepinsta.com/wipro/simple-interest/',
          'company': 'Wipro',
        },
      ],
      'time_and_distance': [
        {
          'title': 'TCS Time and Distance Questions',
          'url': 'https://prepinsta.com/tcs/time-speed-and-distance/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Time and Distance Questions',
          'url': 'https://prepinsta.com/infosys/time-speed-and-distance/',
          'company': 'Infosys',
        },
        {
          'title': 'Wipro Time and Distance Questions',
          'url': 'https://prepinsta.com/wipro/time-speed-and-distance/',
          'company': 'Wipro',
        },
      ],
    };

    final String topicName = topicNames[topic] ?? 'Unknown Topic';
    final List<Map<String, String>> videos = videoLinks[topic] ?? [];
    final List<Map<String, String>> papers = questionPapers[topic] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$topicName References',
          style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YouTube Video Links',
                          style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                        ),
                        SizedBox(height: 8),
                        if (videos.isEmpty)
                          Text(
                            'No videos available for this topic.',
                            style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                          )
                        else
                          ...videos.map((video) => ListTile(
                                leading: Icon(Icons.video_library, color: Colors.blue[900]),
                                title: Text(
                                  video['title']!,
                                  style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                                ),
                                subtitle: Text(
                                  video['channel']!,
                                  style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[500]),
                                ),
                                onTap: () async {
                                  final url = Uri.parse(video['url']!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not open the video')),
                                    );
                                  }
                                },
                              )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company Question Papers',
                          style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                        ),
                        SizedBox(height: 8),
                        if (papers.isEmpty)
                          Text(
                            'No question papers available for this topic.',
                            style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                          )
                        else
                          ...papers.map((paper) => ListTile(
                                leading: Icon(Icons.description, color: Colors.blue[900]),
                                title: Text(
                                  paper['title']!,
                                  style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                                ),
                                subtitle: Text(
                                  paper['company']!,
                                  style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[500]),
                                ),
                                onTap: () async {
                                  final url = Uri.parse(paper['url']!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not open the question paper')),
                                    );
                                  }
                                },
                              )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}