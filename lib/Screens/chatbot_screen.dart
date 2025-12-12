import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  int level = 0;
  List<String> messages = [
    'Hi! 👋 I’m your health assistant. How can I help you today?',
  ];

  final List<List<String>> questions = [
    [
      'Menstrual health',
      'Pregnancy care',
      'Fertility concerns',
      'General wellness',
    ],
    ['Irregular cycles', 'Painful periods', 'Heavy bleeding', 'Other'],
    [
      'First trimester tips',
      'Nutrition & diet',
      'Safe exercises',
      'Warning signs',
    ],
    ['Herbal supplements', 'Lifestyle guidance', 'Consult a doctor'],
  ];

  final Map<String, String> answers = {
    'Menstrual health':
        'Tracking cycles, stress management, and herbal teas may help regulate periods 🌿.',
    'Pregnancy care':
        'Prenatal vitamins, balanced diet, and regular checkups are essential 🤰.',
    'Fertility concerns':
        'Healthy weight, good nutrition, and stress management improve fertility chances.',
    'General wellness':
        'Yoga, meditation, and herbs support overall wellness ✨.',
    'Irregular cycles':
        'Can be stress or hormone-related. Herbs like Ashoka may help.',
    'Painful periods':
        'Warm compress, yoga, and herbal teas often relieve cramps.',
    'Heavy bleeding':
        'Consult a doctor if severe. Shatavari may help recovery.',
    'First trimester tips':
        'Rest, hydration, and prenatal supplements are key.',
    'Nutrition & diet':
        'Iron, calcium, and folic acid are vital during this phase.',
    'Safe exercises':
        'Light yoga and walking are safe unless advised otherwise.',
    'Warning signs':
        'Severe cramps, bleeding, or dizziness need immediate care 🚨.',
    'Herbal supplements': 'We provide 100% pure herbal supplements 🌱.',
    'Lifestyle guidance':
        'Balanced sleep, meditation, and yoga help maintain health.',
    'Consult a doctor': 'Would you like to book an appointment now? 📅',
  };

  void _sendResponse(String response) {
    setState(() {
      messages.add('You: $response');

      if (answers.containsKey(response)) {
        messages.add('Bot: ${answers[response]!}');
      }

      if (level < questions.length - 1) {
        level++;
        messages.add('Bot: Please choose an option below:');
      } else {
        messages.add('Bot: Thank you 🙏. Tap below to book an appointment.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Clinic Chatbot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isUser = messages[index].startsWith('You:');
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      messages[index],
                      style: TextStyle(
                        color: isUser ? Colors.black87 : Colors.black87,
                        fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (level < questions.length)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                children:
                    questions[level]
                        .map(
                          (q) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => _sendResponse(q),
                            child: Text(q),
                          ),
                        )
                        .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
