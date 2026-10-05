import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final langN = ValueNotifier<String>('ta');
final scaleN = ValueNotifier<double>(1.0);
Map<String, String> _en = {};
List<String> _enKeys = [];
final _tamil = RegExp(r'[\u0B80-\u0BFF]');

Future<void> loadEn() async {
  final m = jsonDecode(await rootBundle.loadString('assets/data/en.json'))
      as Map<String, dynamic>;
  _en = m.map((k, v) => MapEntry(k, v as String));
  _enKeys = _en.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
}

String tr(String s) {
  if (langN.value != 'en' || !_tamil.hasMatch(s)) return s;
  final e = s.trim();
  if (_en.containsKey(e)) return s.replaceFirst(e, _en[e]!);
  var o = s;
  for (final k in _enKeys) {
    if (o.contains(k)) o = o.replaceAll(k, _en[k]!);
  }
  return o;
}

class Tx extends StatelessWidget {
  final String s;
  final TextStyle? style;
  final TextAlign? align;
  const Tx(this.s, {super.key, this.style, this.align});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<String>(
      valueListenable: langN,
      builder: (_, l, __) => Text(tr(s), style: style, textAlign: align));
}

late Map<String, dynamic> ed, sd, pk, sm, kr, ad;

Future<Map<String, dynamic>> _load(String n) async =>
    jsonDecode(await rootBundle.loadString('assets/data/$n.json'))
        as Map<String, dynamic>;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ed = await _load('edhiridai');
  sd = await _load('sadhaga');
  pk = await _load('pathaka');
  sm = await _load('samayam');
  await loadEn();
  kr = await _load('karma');
  ad = await _load('aadhikkam');
  runApp(const App());
}

const kDeep = Color(0xFF4A0A16);
const kMid = Color(0xFF7A1424);
const kBg = Color(0xFFFBF1DC);
const kHead = [kDeep, kMid, Color(0xFF9B2335)];

const _gc = <String, Color>{
  'சூ': Color(0xFFF57C00),
  'சந்': Color(0xFF3F7FD6),
  'செ': Color(0xFFD32F2F),
  'பு': Color(0xFF2E9E5B),
  'வி': Color(0xFFE5A100),
  'கு': Color(0xFFE5A100),
  'சு': Color(0xFFD81B8A),
  'சனி': Color(0xFF455A9E),
  'ரா': Color(0xFF7B3FA0),
  'கே': Color(0xFF8D5A3B),
};

Color gColor(String s) {
  for (final e in _gc.entries) {
    if (s.startsWith(e.key)) return e.value;
  }
  return kMid;
}

const gFull = <String, String>{
  'சூ': 'சூரியன்',
  'சந்': 'சந்திரன்',
  'செ': 'செவ்வாய்',
  'பு': 'புதன்',
  'வி': 'வியாழன்',
  'சு': 'சுக்கிரன்',
  'சனி': 'சனி',
};

List<String> strs(dynamic l) => List<String>.from(l as List);

BoxDecoration grad(List<Color> cs, {double r = 0}) => BoxDecoration(
      gradient: LinearGradient(
          colors: cs, begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(r),
    );

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
        title: 'நட்சத்திர குறிப்பு',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: kMid,
            scaffoldBackgroundColor: Colors.transparent),
        builder: (c, child) => Container(
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFBF1DC), Color(0xFFF3E1B8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: ValueListenableBuilder<double>(
                valueListenable: scaleN,
                builder: (_, sc, __) => MediaQuery(
                    data: MediaQuery.of(c)
                        .copyWith(textScaler: TextScaler.linear(sc)),
                    child: child!))),
        home: const SplashPage(),
      );
}

class Tile {
  final String name, sub;
  final IconData icon;
  final List<Color> colors;
  final Widget page;
  const Tile(this.name, this.sub, this.icon, this.colors, this.page);
}

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext c) {
    final tiles = <Tile>[
      Tile('எதிரிடை', 'நட்சத்திர அட்டவணை', Icons.compare_arrows_rounded,
          const [Color(0xFFB3261E), Color(0xFF6D0F1F)], const EdhiridaiPage()),
      Tile('சாதக தாரை', 'சாதக நட்சத்திரங்கள்', Icons.auto_awesome_rounded,
          const [Color(0xFF2F6B3A), Color(0xFF16381F)], const SadhagaPage()),
      Tile('பாதக தாரை', 'காரகன் · பாசகன்', Icons.shield_moon_rounded,
          const [Color(0xFF5B2A6E), Color(0xFF2A1038)], const PathakaPage()),
      Tile('சமயம்', '12 லக்னங்கள்', Icons.schedule_rounded,
          const [Color(0xFF1F4E79), Color(0xFF0F2540)], const SamayamPage()),
      Tile('கர்ம பதிவு', 'கிரகம் வாரியாக', Icons.auto_stories_rounded,
          const [Color(0xFFC99A2E), Color(0xFF7A5412)],
          GrahaStarsPage('கர்ம பதிவு', kr)),
      Tile('கிரகங்களின் ஆதிக்கம்', 'ஆதிக்க நட்சத்திரங்கள்',
          Icons.brightness_7_rounded,
          const [Color(0xFFD9791C), Color(0xFF8A3B0A)],
          GrahaStarsPage('கிரகங்களின் ஆதிக்கம்', ad)),
    ];
    return Scaffold(
      body: Column(children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              24, MediaQuery.of(c).padding.top + 28, 24, 34),
          decoration: grad(kHead).copyWith(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32))),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Tx('🪔', style: TextStyle(fontSize: 38)),
                  _Gear(),
                ]),
                SizedBox(height: 10),
                Tx('ஜோதிட வழிகாட்டி',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Tx('ஜோதிட அட்டவணை · விரைவு தேடல்',
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
              ]),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.95,
            children: [
              for (final t in tiles)
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.push(
                      c, MaterialPageRoute(builder: (_) => t.page)),
                  child: Ink(
                    padding: const EdgeInsets.all(18),
                    decoration: grad(t.colors, r: 24).copyWith(boxShadow: [
                      BoxShadow(
                          color: t.colors.last.withOpacity(.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6))
                    ]),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(t.icon, color: Colors.white)),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Tx(t.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Tx(t.sub,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12.5)),
                              ]),
                        ]),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class Shell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const Shell(this.title, this.children, {super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: Tx(title,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(decoration: grad(kHead)),
        ),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: children),
      );
}

Widget label(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 0, 8),
      child: Tx(t,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
    );

Widget chips(List<String> items, String v, ValueChanged<String> f,
        {bool colored = true}) =>
    Wrap(spacing: 8, runSpacing: 8, children: [
      for (final e in items)
        ChoiceChip(
          label: Tx(e),
          selected: e == v,
          showCheckmark: false,
          selectedColor: colored ? gColor(e) : kMid,
          backgroundColor: const Color(0xFFFFFAF0),
          side: const BorderSide(color: Color(0xFFC99A2E)),
          labelStyle: TextStyle(
              color: e == v ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700),
          onSelected: (_) => f(e),
        ),
    ]);

Widget starPicker(
        BuildContext c, List<String> items, String v, ValueChanged<String> f) =>
    InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final r = await showModalBottomSheet<String>(
          context: c,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          builder: (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: .75,
            builder: (ctx, sc) => ListView(controller: sc, children: [
              for (var i = 0; i < items.length; i++)
                ListTile(
                  leading: CircleAvatar(
                      radius: 15,
                      backgroundColor:
                          items[i] == v ? kMid : const Color(0xFFF3E3B5),
                      child: Tx('${i + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              color: items[i] == v ? Colors.white : kMid))),
                  title: Tx(items[i],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.pop(ctx, items[i]),
                ),
            ]),
          ),
        );
        if (r != null) f(r);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFFFFFAF0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC99A2E), width: 1.5)),
        child: Row(children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFF8F1F)),
          const SizedBox(width: 12),
          Expanded(
              child: Tx(v,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800))),
          const Icon(Icons.keyboard_arrow_down_rounded, color: kMid),
        ]),
      ),
    );

Widget resultCard(String k, String v, Color col) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFFFFFAF0),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: col.withOpacity(.14),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: IntrinsicHeight(
        child: Row(children: [
          Container(
              width: 7,
              decoration: BoxDecoration(
                  color: col,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(18)))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Expanded(
                    child: Tx(k,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54))),
                Tx(v,
                    style: TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800, color: col)),
              ]),
            ),
          ),
        ]),
      ),
    );

class EdhiridaiPage extends StatefulWidget {
  const EdhiridaiPage({super.key});
  @override
  State<EdhiridaiPage> createState() => _EdState();
}

class _EdState extends State<EdhiridaiPage> {
  final tables = ed['tables'] as List;
  final stars = strs(ed['meta']['nakshatraOrder']);
  late String planet = tables.first['planet'];
  late String star = stars.first;
  @override
  Widget build(BuildContext c) {
    final t = tables.firstWhere((x) => x['planet'] == planet);
    final cols = strs(t['columns']);
    final res = strs(t['rows'][star]);
    return Shell('எதிரிடை', [
      label('கிரகம்'),
      chips([for (final x in tables) x['planet'] as String], planet,
          (v) => setState(() => planet = v)),
      label('நட்சத்திரம்'),
      starPicker(c, stars, star, (v) => setState(() => star = v)),
      label('முடிவு'),
      for (var i = 0; i < cols.length; i++)
        resultCard(cols[i], res[i], gColor(planet)),
    ]);
  }
}

class SadhagaPage extends StatefulWidget {
  const SadhagaPage({super.key});
  @override
  State<SadhagaPage> createState() => _SdState();
}

class _SdState extends State<SadhagaPage> {
  final tables = sd['tables'] as List;
  final stars = strs(sd['meta']['nakshatraOrder']);
  late String planet = tables.first['dasaNathan'];
  late String star = stars.first;
  @override
  Widget build(BuildContext c) {
    final t = tables.firstWhere((x) => x['dasaNathan'] == planet);
    final cols = strs(t['columns']);
    final res = strs(t['rows'][star]);
    return Shell('சாதக தாரை', [
      label('தசாநாதன்'),
      chips([for (final x in tables) x['dasaNathan'] as String], planet,
          (v) => setState(() => planet = v)),
      label('நின்ற நட்சத்திரம்'),
      starPicker(c, stars, star, (v) => setState(() => star = v)),
      label('${t['helperPlanets']} நின்ற நட்சத்திரங்கள்'),
      for (var i = 0; i < cols.length; i++)
        resultCard(cols[i], res[i], gColor(planet)),
    ]);
  }
}

class PathakaPage extends StatefulWidget {
  const PathakaPage({super.key});
  @override
  State<PathakaPage> createState() => _PkState();
}

class _PkState extends State<PathakaPage> {
  final rows = pk['rows'] as Map<String, dynamic>;
  late String planet = rows.keys.first;
  @override
  Widget build(BuildContext c) {
    final r = rows[planet] as Map<String, dynamic>;
    return Shell('பாதக தாரை', [
      label('கிரகம்'),
      chips(rows.keys.toList(), planet, (v) => setState(() => planet = v)),
      label('முடிவு'),
      for (final e in r.entries)
        resultCard(e.key, e.value as String, gColor(e.value as String)),
    ]);
  }
}

class SamayamPage extends StatefulWidget {
  const SamayamPage({super.key});
  @override
  State<SamayamPage> createState() => _SmState();
}

class _SmState extends State<SamayamPage> {
  final rows = sm['rows'] as Map<String, dynamic>;
  final planets = strs(sm['planetColumns']);
  final names = strs(sm['lagnaOrder']);
  late String lagna = rows.keys.first;
  @override
  Widget build(BuildContext c) {
    final r = rows[lagna] as Map<String, dynamic>;
    final none = r.containsKey('இல்லை');
    return Shell('சமயம்', [
      label('லக்னம்'),
      chips(rows.keys.toList(), lagna, (v) => setState(() => lagna = v),
          colored: false),
      label('கிரகம் வாரியாக'),
      if (none)
        resultCard(lagna.split(' ').last, 'இல்லை', kMid)
      else
        for (final p in planets)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFFAF0), borderRadius: BorderRadius.circular(18)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tx(gFull[p] ?? p,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: gColor(p))),
                  const SizedBox(height: 8),
                  if ((r[p] as List).isEmpty)
                    const Tx('–', style: TextStyle(fontSize: 18))
                  else
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final n in (r[p] as List))
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: gColor(p).withOpacity(.12),
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [
                            Tx('$n',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: gColor(p))),
                            Tx(names[(n as int) - 1],
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black54)),
                          ]),
                        ),
                    ]),
                ]),
          ),
    ]);
  }
}

class GrahaStarsPage extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  const GrahaStarsPage(this.title, this.data, {super.key});
  @override
  State<GrahaStarsPage> createState() => _GsState();
}

class _GsState extends State<GrahaStarsPage> {
  late final Map<String, dynamic> rows =
      widget.data['rows'] as Map<String, dynamic>;
  late String planet = rows.keys.first;
  @override
  Widget build(BuildContext c) {
    final st = strs(rows[planet]);
    return Shell(widget.title, [
      label('கிரகம்'),
      chips(rows.keys.toList(), planet, (v) => setState(() => planet = v)),
      label('நட்சத்திரங்கள்'),
      if (st.isEmpty)
        resultCard(planet, 'இல்லை', gColor(planet))
      else
        for (var i = 0; i < st.length; i++)
          resultCard('${i + 1}', st[i], gColor(planet)),
    ]);
  }
}

// ---------- Stage 1: opening, language, login, settings, plans ----------
const kGold = Color(0xFFC99A2E);
const kGoldL = Color(0xFFF2D27A);
const kCream = Color(0xFFFFFAF0);

void toHome(BuildContext c) => Navigator.pushAndRemoveUntil(
    c, MaterialPageRoute(builder: (_) => const Home()), (r) => false);

class DivineHeader extends StatelessWidget {
  final String title, sub;
  final bool plain;
  const DivineHeader(this.title, this.sub, {super.key, this.plain = false});
  Widget t(String s, TextStyle st) => plain
      ? Text(s, style: st, textAlign: TextAlign.center)
      : Tx(s, style: st, align: TextAlign.center);
  @override
  Widget build(BuildContext c) => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(c).padding.top + 34, 20, 36),
        decoration: grad(kHead).copyWith(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(40))),
        child: Column(children: [
          const Text('🪔', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 6),
          t(title,
              const TextStyle(
                  color: kGoldL, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          t(sub, const TextStyle(color: Colors.white70, fontSize: 14)),
        ]),
      );
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SpState();
}

class _SpState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LangPage()));
      }
    });
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: RadialGradient(
                  colors: [Color(0xFF7A1424), Color(0xFF2A0610)], radius: 1.0)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(44),
                child: Image.asset('assets/icon/icon.png', width: 210)),
            const SizedBox(height: 18),
            const Text('ஜோதிட அட்டவணை · விரைவு தேடல்',
                style: TextStyle(color: kGoldL, fontSize: 15)),
          ]),
        ),
      );
}

class LangPage extends StatelessWidget {
  const LangPage({super.key});
  Widget card(BuildContext c, String name, String sub, String code) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          langN.value = code;
          Navigator.pushReplacement(
              c, MaterialPageRoute(builder: (_) => const LoginPage()));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [kCream, Color(0xFFF6E2A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              border: Border.all(color: kGold, width: 2),
              borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            Text(sub,
                style: const TextStyle(
                    fontSize: 14, color: kMid, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
  @override
  Widget build(BuildContext c) => Scaffold(
        body: Column(children: [
          const DivineHeader('மொழி · Language',
              'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்\nChoose your language',
              plain: true),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(children: [
              card(c, 'தமிழ்', 'Tamil', 'ta'),
              card(c, 'English', 'ஆங்கிலம்', 'en'),
              const SizedBox(height: 6),
              const Text(
                  'பின்னர் அமைப்புகளில் மாற்றலாம்\nYou can change this later in Settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
        ]),
      );
}

class GoldBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool alt;
  const GoldBtn(this.text, this.onTap, {super.key, this.alt = false});
  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
                gradient: alt
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFD9A937), Color(0xFF8A6212)]),
                color: alt ? kCream : null,
                border: alt ? Border.all(color: kGold, width: 1.5) : null,
                borderRadius: BorderRadius.circular(14)),
            child: Center(
                child: Tx(text,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: alt ? kMid : Colors.white))),
          ),
        ),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LgState();
}

class _LgState extends State<LoginPage> {
  bool otp = false;
  InputDecoration deco(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: kCream,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kGold, width: 1.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kGold, width: 1.5)));
  @override
  Widget build(BuildContext c) => Scaffold(
        body: Column(children: [
          DivineHeader('வணக்கம்',
              otp ? 'உங்கள் OTP-ஐ உள்ளிடவும்' : 'தொடர உள்நுழையவும்'),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(22), children: [
              label(otp ? 'OTP எண்' : 'மொபைல் எண்'),
              TextField(
                  keyboardType: TextInputType.number,
                  decoration: deco(otp ? '• • • • • •' : '+91  98765 43210')),
              if (otp) ...[
                GoldBtn('உள்நுழை', () => toHome(c)),
                TextButton(
                    onPressed: () => setState(() => otp = false),
                    child: const Tx('← எண்ணை மாற்று',
                        style: TextStyle(color: kMid))),
              ] else ...[
                GoldBtn('OTP அனுப்பு', () => setState(() => otp = true)),
                GoldBtn('Google மூலம் தொடரவும்', () => toHome(c), alt: true),
                TextButton(
                    onPressed: () => toHome(c),
                    child: const Tx('விருந்தினராகத் தொடரவும்',
                        style: TextStyle(
                            color: kMid, fontWeight: FontWeight.w700))),
              ],
              const SizedBox(height: 10),
              const Tx('காட்சிக்காக மட்டும் – உள்நுழைவு இன்னும் செயல்படாது',
                  align: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
        ]),
      );
}

class _Gear extends StatelessWidget {
  const _Gear();
  @override
  Widget build(BuildContext c) => InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.push(
            c, MaterialPageRoute(builder: (_) => const SettingsPage())),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
              border: Border.all(color: kGold)),
          child: const Icon(Icons.settings_rounded, color: kGoldL, size: 20),
        ),
      );
}

Widget grp(List<Widget> rows) => Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
          color: kCream,
          border: Border.all(color: const Color(0xFFE6D3A3)),
          borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: Color(0xFFECDCB4)),
          rows[i],
        ]
      ]),
    );

Widget srow(IconData i, String t,
        {String? trail, VoidCallback? onTap, Widget? end}) =>
    InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(i, color: kMid),
          const SizedBox(width: 12),
          Expanded(
              child: Tx(t, style: const TextStyle(fontWeight: FontWeight.w600))),
          if (end != null) end,
          if (trail != null)
            Tx(trail, style: const TextStyle(color: Colors.black54)),
        ]),
      ),
    );

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext c) => Shell('அமைப்புகள்', [
        label('கணக்கு'),
        grp([
          srow(Icons.person_outline, 'சுயவிவரம்', trail: 'விருந்தினர்'),
          srow(Icons.workspace_premium_outlined, 'சந்தா நிலை',
              trail: 'இலவசம்',
              onTap: () => Navigator.push(
                  c, MaterialPageRoute(builder: (_) => const PlansPage()))),
          srow(Icons.logout_rounded, 'வெளியேறு',
              onTap: () => Navigator.pushAndRemoveUntil(
                  c,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (r) => false)),
        ]),
        label('மொழி'),
        ValueListenableBuilder<String>(
            valueListenable: langN,
            builder: (_, l, __) => grp([
                  srow(Icons.language_rounded, 'தமிழ்',
                      trail: l == 'ta' ? '✓' : '',
                      onTap: () => langN.value = 'ta'),
                  srow(Icons.translate_rounded, 'English',
                      trail: l == 'en' ? '✓' : '',
                      onTap: () => langN.value = 'en'),
                ])),
        label('தோற்றம்'),
        grp([
          srow(Icons.text_fields_rounded, 'எழுத்து அளவு',
              end: ValueListenableBuilder<double>(
                  valueListenable: scaleN,
                  builder: (_, v, __) => Row(children: [
                        for (final e in const {'A': 1.0, 'A+': 1.1, 'A++': 1.2}
                            .entries)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ChoiceChip(
                                label: Text(e.key),
                                selected: v == e.value,
                                showCheckmark: false,
                                selectedColor: kMid,
                                labelStyle: TextStyle(
                                    color: v == e.value
                                        ? Colors.white
                                        : Colors.black87),
                                onSelected: (_) => scaleN.value = e.value),
                          ),
                      ]))),
          srow(Icons.palette_outlined, 'தீம்', trail: 'பாரம்பரியம்'),
        ]),
        label('உதவி'),
        grp([
          srow(Icons.menu_book_outlined, 'பயன்படுத்தும் முறை'),
          srow(Icons.chat_outlined, 'தொடர்பு கொள்ள', trail: 'WhatsApp'),
          srow(Icons.mail_outline, 'கருத்து தெரிவிக்க'),
        ]),
        label('பற்றி'),
        grp([
          srow(Icons.info_outline, 'பதிப்பு', trail: '1.0'),
          srow(Icons.lock_outline, 'தனியுரிமைக் கொள்கை'),
          srow(Icons.description_outlined, 'விதிமுறைகள்'),
          srow(Icons.share_outlined, 'செயலியைப் பகிர்'),
        ]),
      ]);
}

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});
  Widget plan(String title, List<String> feats,
          {bool price = false, bool hi = false}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: hi
                ? const LinearGradient(
                    colors: [Color(0xFFFFF6DC), Color(0xFFF6E2A8)])
                : null,
            color: hi ? null : kCream,
            border: Border.all(color: kGold, width: 1.5),
            borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Tx(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: kMid)),
          if (price)
            const Tx('விலை விரைவில்',
                style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          for (final f in feats) Tx('•  $f'),
          if (price) const GoldBtn('விரைவில்', _none),
        ]),
      );
  static void _none() {}
  @override
  Widget build(BuildContext c) => Shell('சந்தா திட்டங்கள்', [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: kMid, borderRadius: BorderRadius.circular(12)),
          child: const Tx('விரைவில் – தற்போது காட்சிக்காக மட்டும்',
              align: TextAlign.center,
              style: TextStyle(color: kGoldL, fontWeight: FontWeight.w700)),
        ),
        plan('இலவசம்', ['தேர்ந்தெடுத்த பிரிவுகள்', 'அடிப்படை தேடல்']),
        plan('மாதாந்திரம்',
            ['அனைத்து 6 பிரிவுகளும்', 'புதிய அட்டவணைகள் உடனடியாக'],
            price: true, hi: true),
        plan('ஆண்டுத் திட்டம்', ['அனைத்தும் + சிறப்பு சலுகை'], price: true),
      ]);
}
