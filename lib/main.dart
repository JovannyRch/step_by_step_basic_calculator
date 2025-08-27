import 'package:flutter/material.dart';

void main() {
  runApp(const StepCalcApp());
}

class StepCalcApp extends StatelessWidget {
  const StepCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora paso a paso',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A7A7B)),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: const HomePage(),
    );
  }
}

enum Operation { add, subtract, multiply, divide }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _aCtrl = TextEditingController(text: '1234');
  final _bCtrl = TextEditingController(text: '567');
  Operation _op = Operation.add;
  bool _autoPlay = true;

  String? _validate(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    final s = v.trim();
    /*  if (!RegExp(r'^-?\d{1,12}\$').hasMatch(s)) {
      return 'Usa enteros (±12 dígitos)';
    } */
    return null;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora educativa')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Ingresa dos números enteros y elige la operación. La app mostrará el procedimiento paso a paso con animaciones.',
              ),
              const SizedBox(height: 16),
              SegmentedButton<Operation>(
                segments: const [
                  ButtonSegment(value: Operation.add, label: Text('Suma (+)')),
                  ButtonSegment(
                    value: Operation.subtract,
                    label: Text('Resta (−)'),
                  ),
                  ButtonSegment(
                    value: Operation.multiply,
                    label: Text('Multiplicación (×)'),
                  ),
                  ButtonSegment(
                    value: Operation.divide,
                    label: Text('División (÷)'),
                  ),
                ],
                selected: {_op},
                onSelectionChanged: (s) => setState(() => _op = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Número A'),
                validator: _validate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Número B'),
                validator: _validate,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Reproducir automáticamente'),
                value: _autoPlay,
                onChanged: (v) => setState(() => _autoPlay = v),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Resolver paso a paso'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => StepsPage(
                              a: _aCtrl.text.trim(),
                              b: _bCtrl.text.trim(),
                              operation: _op,
                              autoPlay: _autoPlay,
                            ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              const _TipsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Consejos', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Usa números enteros de hasta 12 dígitos.'),
            Text(
              '• En multiplicación se muestran líneas parciales y la suma final.',
            ),
            Text(
              '• En división se ilustra la división larga con cociente y residuo.',
            ),
          ],
        ),
      ),
    );
  }
}

// ======== MODELOS DE PASOS ======== //
class CalcStep {
  final List<String> lines; // Todas del mismo largo (monoespaciado)
  final Set<int> highlightColsRight; // índices desde la derecha
  final String explanation;
  CalcStep({
    required this.lines,
    required this.explanation,
    this.highlightColsRight = const {},
  });
}

// ======== GENERADORES DE PASOS ======== //
List<CalcStep> buildSteps(String a, String b, Operation op) {
  switch (op) {
    case Operation.add:
      return _buildAddSteps(a, b);
    case Operation.subtract:
      return _buildSubtractSteps(a, b);
    case Operation.multiply:
      return _buildMultiplySteps(a, b);
    case Operation.divide:
      return _buildDivideSteps(a, b);
  }
}

String _padLeft(String s, int len) => s.padLeft(len);

String _withSign(String s, String sign, int len) {
  final trimmed = s.trim();
  final withoutSign = trimmed.startsWith('-') ? trimmed.substring(1) : trimmed;
  final isNeg = trimmed.startsWith('-');
  final prefix = isNeg ? '-' : sign;
  final raw = '$prefix$withoutSign';
  return raw.padLeft(len);
}

List<CalcStep> _buildAddSteps(String a, String b) {
  // Suma por columnas con acarreo
  final isNegA = a.trim().startsWith('-');
  final isNegB = b.trim().startsWith('-');
  if (isNegA || isNegB) {
    // Para mantener el ejemplo simple: convertir a resta si aplica
    final ai = int.parse(a);
    final bi = int.parse(b);
    final res = ai + bi;
    final len = res.toString().replaceAll('-', '').length + 2;
    final lines = [
      _withSign(a, ' ', len),
      _withSign(b, '+', len),
      ''.padLeft(len, '—'),
      _withSign(res.toString(), ' ', len),
    ];
    return [
      CalcStep(lines: lines, explanation: 'Suma de enteros (incluye signos).'),
    ];
  }

  final A = a.trim();
  final B = b.trim();
  final len =
      (A.length > B.length ? A.length : B.length) +
      2; // espacio para signo y posibles llevadas
  final aLine = _withSign(A, ' ', len);
  final bLine = _withSign(B, '+', len);
  final bar = ''.padLeft(len, '—');

  final da = A.padLeft(len - 1).split('');
  final db = B.padLeft(len - 1).split('');
  final result = List<String>.filled(len - 1, ' ');
  final carry = List<String>.filled(len - 1, ' ');

  var c = 0;
  final steps = <CalcStep>[];

  for (int i = da.length - 1, idxRight = 0; i >= 0; i--, idxRight++) {
    final d1 = int.tryParse(da[i]) ?? 0;
    final d2 = int.tryParse(db[i]) ?? 0;
    final s = d1 + d2 + c;
    final digit = s % 10;
    final newCarry = s ~/ 10;

    result[i] = digit.toString();
    if (newCarry > 0 && i > 0) {
      carry[i - 1] = newCarry.toString();
    }

    final lines = <String>[
      carry.join('').padLeft(len - 1).padLeft(len),
      aLine,
      bLine,
      bar,
      (' ${result.join('')}').padLeft(len),
    ];

    steps.add(
      CalcStep(
        lines: lines,
        explanation:
            'Columna ${idxRight + 1}: $d1 + $d2 + acarreo $c = $s → escribe $digit y el acarreo es $newCarry.',
        highlightColsRight: {idxRight},
      ),
    );

    c = newCarry;
  }

  // Paso final (si queda acarreo a la izquierda ya se colocó en la línea de carry)
  steps.add(
    CalcStep(
      lines: [
        carry.join('').padLeft(len - 1).padLeft(len),
        aLine,
        bLine,
        bar,
        (' ${result.join('')}').padLeft(len),
      ],
      explanation: 'Resultado final.',
      highlightColsRight: const {},
    ),
  );

  return steps;
}

List<CalcStep> _buildSubtractSteps(String a, String b) {
  // Resta por columnas con préstamo (A - B)
  final ai = int.parse(a);
  final bi = int.parse(b);
  if (ai < bi) {
    // Mantenerlo educativo: mostramos que el resultado será negativo y luego restamos bi - ai
    final stepsPos = _buildSubtractSteps((bi).toString(), (ai).toString());
    // Insertar una explicación inicial
    final len = (b.length > a.length ? b.length : a.length) + 2;
    final intro = CalcStep(
      lines: [
        _withSign(a, ' ', len),
        _withSign(b, '−', len),
        ''.padLeft(len, '—'),
        _withSign('-(resultado)', ' ', len),
      ],
      explanation:
          'Como A < B, el resultado será negativo. Calculamos B − A y luego anteponemos el signo −.',
    );
    return [intro, ...stepsPos];
  }

  final A = a.trim();
  final B = b.trim();
  final len = (A.length > B.length ? A.length : B.length) + 2;
  final aLine = _withSign(A, ' ', len);
  final bLine = _withSign(B, '−', len);
  final bar = ''.padLeft(len, '—');

  final da =
      A.padLeft(len - 1).split('').map((e) => int.tryParse(e) ?? 0).toList();
  final db =
      B.padLeft(len - 1).split('').map((e) => int.tryParse(e) ?? 0).toList();
  final result = List<String>.filled(len - 1, ' ');

  int borrow = 0;
  final steps = <CalcStep>[];

  for (int i = da.length - 1, idxRight = 0; i >= 0; i--, idxRight++) {
    int top = da[i] - borrow;
    final bot = db[i];
    borrow = 0;
    if (top < bot) {
      top += 10;
      borrow = 1;
    }
    final d = top - bot;
    result[i] = d.toString();

    final borrowLine = List<String>.filled(len - 1, ' ');
    if (borrow == 1 && i > 0) borrowLine[i - 1] = '1';

    final lines = <String>[
      borrowLine.join('').padLeft(len - 1).padLeft(len),
      aLine,
      bLine,
      bar,
      (' ${result.join('')}').padLeft(len),
    ];

    steps.add(
      CalcStep(
        lines: lines,
        explanation:
            'Columna ${idxRight + 1}: ${da[i]} − ${db[i]} con préstamo ${borrow == 1 ? '(se toma 1 → 10)' : '0'} → escribe $d.',
        highlightColsRight: {idxRight},
      ),
    );
  }

  steps.add(
    CalcStep(
      lines: [
        ''.padLeft(len),
        aLine,
        bLine,
        bar,
        (' ${result.join('')}').padLeft(len),
      ],
      explanation: 'Resultado final.',
    ),
  );

  return steps;
}

List<CalcStep> _buildMultiplySteps(String a, String b) {
  final isNeg = (a.trim().startsWith('-')) ^ (b.trim().startsWith('-'));
  final A = a.trim().replaceAll('-', '');
  final B = b.trim().replaceAll('-', '');
  final len =
      (A.length > B.length ? A.length : B.length) +
      4; // margen para signos y desplazamientos

  final top = _withSign(A, ' ', len);
  final bottom = _withSign(B, '×', len);
  final bar = ''.padLeft(len, '—');

  final steps = <CalcStep>[];
  final partials = <String>[];

  // Por cada dígito del multiplicador B (de derecha a izquierda), construimos una línea parcial
  final bDigits = B.split('').map((e) => int.parse(e)).toList();
  final aDigits = A.split('').map((e) => int.parse(e)).toList();

  for (int jb = bDigits.length - 1, idxRight = 0; jb >= 0; jb--, idxRight++) {
    final d2 = bDigits[jb];
    int carry = 0;
    final partial = List<int>.filled(aDigits.length, 0);

    for (int ia = aDigits.length - 1; ia >= 0; ia--) {
      final prod = aDigits[ia] * d2 + carry;
      partial[ia] = prod % 10;
      carry = prod ~/ 10;
    }

    final partialStr = (carry > 0 ? carry.toString() : '') + partial.join('');
    final shifted = partialStr + ''.padRight(bDigits.length - 1 - jb, '0');
    final shiftedPadded = shifted.padLeft(len - 1);

    partials.add(shiftedPadded);

    final lines = <String>[
      top,
      bottom,
      bar,
      ...partials.map((p) => (' $p').padLeft(len)),
    ];

    steps.add(
      CalcStep(
        lines: lines,
        explanation:
            'Multiplica por $d2 y escribe la línea parcial (acarreo: $carry).',
        highlightColsRight: {idxRight},
      ),
    );
  }

  // Sumar líneas parciales → podemos mostrar un último paso con el resultado final
  // Para simplicidad, usamos BigInt para el cálculo exacto
  final ai = BigInt.parse(A);
  final bi = BigInt.parse(B);
  var res = ai * bi;
  if (isNeg) res = -res;

  final resultLine = _withSign(res.toString(), ' ', len);
  final linesFinal = <String>[
    top,
    bottom,
    bar,
    ...partials.map((p) => (' $p').padLeft(len)),
    ''.padLeft(len, '—'),
    resultLine,
  ];

  steps.add(
    CalcStep(
      lines: linesFinal,
      explanation: 'Suma las líneas parciales para obtener el producto final.',
    ),
  );

  return steps;
}

List<CalcStep> _buildDivideSteps(String a, String b) {
  // División larga (enteros) con cociente y residuo
  final divisor = int.tryParse(b.trim());
  final dividendStr = a.trim();
  if (divisor == null || divisor == 0) {
    final len = dividendStr.length + 6;
    return [
      CalcStep(
        lines: [
          _withSign(dividendStr, ' ', len),
          _withSign(b, '÷', len),
          ''.padLeft(len, '—'),
          'Divisor inválido'.padLeft(len),
        ],
        explanation:
            'No se puede dividir entre 0. Ingresa un divisor distinto de cero.',
      ),
    ];
  }

  final isNeg = (a.trim().startsWith('-')) ^ (b.trim().startsWith('-'));
  final A = a.trim().replaceAll('-', '');
  final len = (A.length + 8);

  final steps = <CalcStep>[];
  final sbQuot = StringBuffer();
  int remainder = 0;

  for (int i = 0; i < A.length; i++) {
    final digit = int.parse(A[i]);
    final current = remainder * 10 + digit;
    final qd = current ~/ divisor;
    remainder = current % divisor;
    sbQuot.write(qd.toString());

    final lines = <String>[
      _withSign(A, ' ', len),
      _withSign(b, '÷', len),
      ''.padLeft(len, '—'),
      ('cociente parcial: ${sbQuot.toString()}').padLeft(len),
      ('resto actual: $remainder').padLeft(len),
    ];

    steps.add(
      CalcStep(
        lines: lines,
        explanation:
            'Baja el dígito ${A[i]} → $current. ¿Cuántas veces cabe $divisor? $qd veces. Resto = $remainder.',
        highlightColsRight: {A.length - 1 - i},
      ),
    );
  }

  var qStr = sbQuot.toString();
  // Quitar ceros a la izquierda del cociente
  qStr = qStr.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  if (qStr.isEmpty) qStr = '0';
  if (isNeg && qStr != '0') qStr = '-$qStr';

  final finalLines = <String>[
    _withSign(A, ' ', len),
    _withSign(b, '÷', len),
    ''.padLeft(len, '—'),
    ('cociente: $qStr').padLeft(len),
    ('residuo: $remainder').padLeft(len),
  ];

  steps.add(
    CalcStep(lines: finalLines, explanation: 'Resultado final de la división.'),
  );
  return steps;
}

// ======== PANTALLA DE PASOS ======== //
class StepsPage extends StatefulWidget {
  final String a;
  final String b;
  final Operation operation;
  final bool autoPlay;
  const StepsPage({
    super.key,
    required this.a,
    required this.b,
    required this.operation,
    this.autoPlay = true,
  });

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage>
    with SingleTickerProviderStateMixin {
  late final List<CalcStep> steps;
  int idx = 0;
  bool playing = false;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    steps = buildSteps(widget.a, widget.b, widget.operation);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _ctrl.reverse();
      }
    });
    if (widget.autoPlay) {
      playing = true;
      _tick();
    }
  }

  Future<void> _tick() async {
    while (mounted && playing) {
      _ctrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted || !playing) break;
      setState(() {
        idx = (idx + 1).clamp(0, steps.length - 1);
        if (idx == steps.length - 1) playing = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get opLabel {
    switch (widget.operation) {
      case Operation.add:
        return 'Suma';
      case Operation.subtract:
        return 'Resta';
      case Operation.multiply:
        return 'Multiplicación';
      case Operation.divide:
        return 'División';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$opLabel paso a paso')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: _BoardView(
                      key: ValueKey(idx),
                      step: steps[idx],
                      pulse: _ctrl,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(steps[idx].explanation, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              _Controls(
                index: idx,
                total: steps.length,
                playing: playing,
                onPlayPause: () {
                  setState(() => playing = !playing);
                  if (playing) _tick();
                },
                onPrev:
                    () => setState(
                      () => idx = (idx - 1).clamp(0, steps.length - 1),
                    ),
                onNext:
                    () => setState(
                      () => idx = (idx + 1).clamp(0, steps.length - 1),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final int index;
  final int total;
  final bool playing;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPlayPause;
  const _Controls({
    required this.index,
    required this.total,
    required this.playing,
    required this.onPrev,
    required this.onNext,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (index + 1) / total;
    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: index > 0 ? onPrev : null,
              icon: const Icon(Icons.skip_previous),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: onPlayPause,
              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              label: Text(playing ? 'Pausar' : 'Reproducir'),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: index < total - 1 ? onNext : null,
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
      ],
    );
  }
}

class _BoardView extends StatelessWidget {
  final CalcStep step;
  final Animation<double> pulse;
  const _BoardView({super.key, required this.step, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final maxLen = step.lines
        .map((e) => e.length)
        .fold<int>(0, (p, c) => c > p ? c : p);
    final lines = step.lines.map((e) => e.padLeft(maxLen)).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          _MonoRow(
            text: line,
            maxLen: maxLen,
            highlightColsRight: step.highlightColsRight,
            pulse: pulse,
          ),
      ],
    );
  }
}

class _MonoRow extends StatelessWidget {
  final String text;
  final int maxLen;
  final Set<int> highlightColsRight;
  final Animation<double> pulse;
  const _MonoRow({
    required this.text,
    required this.maxLen,
    required this.highlightColsRight,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final chars = text.padLeft(maxLen).characters.toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < chars.length; i++)
          _Cell(
            ch: chars[i],
            highlight: _isHighlighted(i, maxLen, highlightColsRight),
            pulse: pulse,
          ),
      ],
    );
  }

  bool _isHighlighted(int leftIndex, int maxLen, Set<int> rightIdxs) {
    final rightIndex = maxLen - 1 - leftIndex;
    return rightIdxs.contains(rightIndex);
  }
}

class _Cell extends StatelessWidget {
  final String ch;
  final bool highlight;
  final Animation<double> pulse;
  const _Cell({required this.ch, required this.highlight, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleMedium!.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final color =
        highlight ? Colors.amber.withOpacity(0.4) : Colors.transparent;
    return ScaleTransition(
      scale:
          highlight
              ? Tween<double>(
                begin: 1,
                end: 1.07,
              ).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut))
              : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        color: color,
        child: Text(ch, style: base),
      ),
    );
  }
}
