import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

late Map<String, dynamic> ed, sd, pk, sm;

Future<Map<String, dynamic>> _load(String n) async =>
    jsonDecode(await rootBundle.loadString('assets/data/$n.json'))
        as Map<String, dynamic>;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ed = await _load('edhiridai');
  sd = await _load('sadhaga');
  pk = await _load('pathaka');
  sm = await _load('samayam');
  runApp(const App());
}

const kDeep = Color(0xFF2B1B5A);
const kMid = Color(0xFF5B2A86);
const kBg = Color(0xFFF5F1FB);
const kHead = [kDeep, kMid, Color(0xFFB0307A)];

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
                    colors: [Color(0xFFEDE4FA), Color(0xFFFCE9E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: child),
        home: const Home(),
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
          const [Color(0xFFFF8F1F), Color(0xFFE53935)], const EdhiridaiPage()),
      Tile('சாதக தாரை', 'சாதக நட்சத்திரங்கள்', Icons.auto_awesome_rounded,
          const [Color(0xFF2E9E5B), Color(0xFF0E7C86)], const SadhagaPage()),
      Tile('பாதக தாரை', 'காரகன் · பாசகன்', Icons.shield_moon_rounded,
          const [Color(0xFF7B3FA0), Color(0xFFD81B8A)], const PathakaPage()),
      Tile('சமயம்', '12 லக்னங்கள்', Icons.schedule_rounded,
          const [Color(0xFF3F7FD6), Color(0xFF2B1B5A)], const SamayamPage()),
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
          child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.stars_rounded, color: Color(0xFFFFC857), size: 38),
                SizedBox(height: 10),
                Text('நட்சத்திர குறிப்பு',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('ஜோதிட அட்டவணை · விரைவு தேடல்',
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
                                Text(t.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(t.sub,
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
          title: Text(title,
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
      child: Text(t,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
    );

Widget chips(List<String> items, String v, ValueChanged<String> f,
        {bool colored = true}) =>
    Wrap(spacing: 8, runSpacing: 8, children: [
      for (final e in items)
        ChoiceChip(
          label: Text(e),
          selected: e == v,
          showCheckmark: false,
          selectedColor: colored ? gColor(e) : kMid,
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
                          items[i] == v ? kMid : const Color(0xFFEDE7F6),
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              color: items[i] == v ? Colors.white : kMid))),
                  title: Text(items[i],
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
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD9CCEE), width: 1.5)),
        child: Row(children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFF8F1F)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(v,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800))),
          const Icon(Icons.keyboard_arrow_down_rounded, color: kMid),
        ]),
      ),
    );

Widget resultCard(String k, String v, Color col) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white,
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
                    child: Text(k,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54))),
                Text(v,
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
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gFull[p] ?? p,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: gColor(p))),
                  const SizedBox(height: 8),
                  if ((r[p] as List).isEmpty)
                    const Text('–', style: TextStyle(fontSize: 18))
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
                            Text('$n',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: gColor(p))),
                            Text(names[(n as int) - 1],
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
