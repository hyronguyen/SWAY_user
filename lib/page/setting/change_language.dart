import 'package:flutter/material.dart';

class LanguageModel {
  final String name;
  final String nativeName;
  final String flagCode;
  bool isSelected; // Removed final

  LanguageModel({
    required this.name,
    required this.nativeName,
    required this.flagCode,
    this.isSelected = false,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<LanguageModel> languages = [
    LanguageModel(name: 'English', nativeName: 'English', flagCode: 'us', isSelected: true),
    LanguageModel(name: 'Hindi', nativeName: 'Hindi', flagCode: 'in'),
    LanguageModel(name: 'Arabic', nativeName: 'Arabic', flagCode: 'ae'),
    LanguageModel(name: 'French', nativeName: 'French', flagCode: 'fr'),
    LanguageModel(name: 'German', nativeName: 'German', flagCode: 'de'),
    LanguageModel(name: 'Portuguese', nativeName: 'Portuguese', flagCode: 'pt'),
    LanguageModel(name: 'Turkish', nativeName: 'Turkish', flagCode: 'tr'),
    LanguageModel(name: 'Dutch', nativeName: 'Nederlands', flagCode: 'nl'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đổi ngôn ngữ',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 30,
                      height: 20,
                      child: Image.asset(
                        'assets/flags/${languages[index].flagCode}.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      languages[index].name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      languages[index].nativeName,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    trailing: languages[index].isSelected
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        for (var lang in languages) {
                          lang.isSelected = false;
                        }
                        languages[index].isSelected = true;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle save language selection
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // Updated from primary to backgroundColor
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Lưu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
