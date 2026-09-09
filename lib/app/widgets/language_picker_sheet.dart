import 'package:flutter/material.dart';

Future<String?> showLanguagePickerSheet({
  required BuildContext context,
  required String title,
  required Iterable<String> languages,
  required String currentLanguage,
  required String Function(String language) languageLabel,
  required Color textColor,
  required Color accentColor,
  required Color unselectedBorderColor,
  required Color selectedFillColor,
  required Color unselectedFillColor,
  required Color selectedBorderColor,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return LanguagePickerSheet(
        title: title,
        languages: languages,
        currentLanguage: currentLanguage,
        languageLabel: languageLabel,
        textColor: textColor,
        accentColor: accentColor,
        unselectedBorderColor: unselectedBorderColor,
        selectedFillColor: selectedFillColor,
        unselectedFillColor: unselectedFillColor,
        selectedBorderColor: selectedBorderColor,
        onLanguageSelected: (language) => Navigator.pop(sheetContext, language),
      );
    },
  );
}

class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({
    super.key,
    required this.title,
    required this.languages,
    required this.currentLanguage,
    required this.languageLabel,
    required this.textColor,
    required this.accentColor,
    required this.unselectedBorderColor,
    required this.selectedFillColor,
    required this.unselectedFillColor,
    required this.selectedBorderColor,
    required this.onLanguageSelected,
  });

  final String title;
  final Iterable<String> languages;
  final String currentLanguage;
  final String Function(String language) languageLabel;
  final Color textColor;
  final Color accentColor;
  final Color unselectedBorderColor;
  final Color selectedFillColor;
  final Color unselectedFillColor;
  final Color selectedBorderColor;
  final ValueChanged<String> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DEE5),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 21),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((language) {
              final isSelected = language == currentLanguage;
              final label = languageLabel(language);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: isSelected ? selectedFillColor : unselectedFillColor,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => onLanguageSelected(language),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? selectedBorderColor
                              : unselectedBorderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.language_rounded,
                              color: accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: accentColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
