import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'কুইজ গেম',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _score = 0;
  int _currentQuestionIndex = 0;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // আপনার দেওয়া আসল Ad Unit ID
  final String _adUnitId = 'ca-app-pub-7396878722273025/9581510928';

  final List<Map<String, Object>> _questions = [
    {
      'question': 'বাংলাদেশের জাতীয় খেলার নাম কী?',
      'answers': ['ফুটবল', 'ক্রিকেট', 'হাডুডু', 'ব্যাডমিন্টন'],
      'correctIndex': 2,
    },
    {
      'question': 'বিশ্বের সর্ববৃহৎ ম্যানগ্রোভ বন কোনটি?',
      'answers': ['আমাজন', 'সুন্দরবন', 'ব্ল্যাক ফরেস্ট', 'টাইগা'],
      'correctIndex': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == _questions[_currentQuestionIndex]['correctIndex']) {
      _score++;
    }

    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('কুইজ সমাপ্ত!'),
        content: Text('আপনার মোট স্কোর: $_score / ${_questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _score = 0;
                _currentQuestionIndex = 0;
              });
            },
            child: const Text('আবার খেলুন'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var q = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('কুইজ খেলে আয় করুন')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'প্রশ্ন ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    q['question'] as String,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ...(q['answers'] as List<String>).asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                        onPressed: () => _answerQuestion(entry.key),
                        child: Text(entry.value, style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          // নিচে ব্যানার অ্যাড দেখানোর অংশ
          if (_isAdLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
