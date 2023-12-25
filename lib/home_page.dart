import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant_app/feature_box.dart';
import 'package:voice_assistant_app/openai_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ochobot'),
        leading: const Icon(CupertinoIcons.line_horizontal_3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/bot.png',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // chat bubble
            Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                  top: 30,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    generatedContent == null
                        ? 'Hello master, what task can I do for you?'
                        : generatedContent!,
                    style: TextStyle(
                      fontSize: generatedContent == null ? 25 : 18,
                    ),
                  ),
                ),
              ),
            ),

            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),

            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(
                  top: 10,
                  left: 20,
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // feature list
            Visibility(
              visible: generatedContent == null,
              child: const Column(
                children: [
                  FeatureBox(
                    color: Colors.green,
                    header: 'ChatGPT',
                    description:
                        'A smarter way to stay organized and informed with ChatGPT',
                  ),
                  FeatureBox(
                    color: Colors.pink,
                    header: 'Dall-E',
                    description:
                        'Get inspired and stay creative with your personal assistant powered by Dall-E',
                  ),
                  FeatureBox(
                    color: Colors.blue,
                    header: 'Smart Voice Assistant',
                    description:
                        'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            final speech = await openAIService.isArtPromptAPI(lastWords);
            if (speech.contains('https')) {
              generatedImageUrl = speech;
              generatedContent = null;
              setState(() {});
            } else {
              generatedImageUrl = null;
              generatedContent = speech;
              setState(() {});
              await systemSpeak(speech);
            }
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: Icon(
          speechToText.isListening ? CupertinoIcons.stop : CupertinoIcons.mic,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
