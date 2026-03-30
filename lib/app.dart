import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';
import 'package:multi_agent_llm/presentation/screens/home_screen.dart';
import 'package:multi_agent_llm/presentation/blocs/chat_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/agents_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/pipeline_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/discovery_bloc.dart';

class MultiAgentLLMApp extends StatefulWidget {
  const MultiAgentLLMApp({super.key});

  @override
  State<MultiAgentLLMApp> createState() => _MultiAgentLLMAppState();

  static _MultiAgentLLMAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MultiAgentLLMAppState>();
}

class _MultiAgentLLMAppState extends State<MultiAgentLLMApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('ar');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Agent LLM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
