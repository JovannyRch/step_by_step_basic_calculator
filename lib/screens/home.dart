import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

enum Operation { add, subtract, multiply, divide }

enum InputField { a, b }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _aCtrl = TextEditingController(text: '12');
  final _bCtrl = TextEditingController(text: '34');
  final _formKey = GlobalKey<FormState>();

  Operation _op = Operation.add;
  InputField _focus = InputField.a;

  // ===== Validaciones =====
  bool get _validA => _isValidInt(_aCtrl.text.trim());
  bool get _validB => _isValidInt(_bCtrl.text.trim());

  bool _isValidInt(String v) => RegExp(r'^-?[0-9]{1,12}$').hasMatch(v);

  bool _isValidForOp(Operation op) {
    if (!_validA || !_validB) return false;
    if (op == Operation.divide) {
      final b = int.tryParse(_bCtrl.text.trim());
      if (b == null || b == 0) return false; // División por cero
    }
    return true;
  }

  String get _opSymbol {
    switch (_op) {
      case Operation.add:
        return '+';
      case Operation.subtract:
        return '−';
      case Operation.multiply:
        return '×';
      case Operation.divide:
        return '÷';
    }
  }

  void _selectOp(Operation o) {
    if (_isValidForOp(o)) {
      setState(() => _op = o);
    }
  }

  void _append(String s) {
    final ctrl = _focus == InputField.a ? _aCtrl : _bCtrl;
    final text = ctrl.text;
    // Evitar ceros adelante innecesarios (excepto "0" solo)
    String next = text + s;
    // Límite de 12 dígitos efectivos (ignorando '-')
    final digits = next.replaceAll('-', '');
    if (digits.length > 12) return;
    ctrl.text = next;
    ctrl.selection = TextSelection.fromPosition(
      TextPosition(offset: ctrl.text.length),
    );
    setState(() {});
  }

  void _backspace() {
    final ctrl = _focus == InputField.a ? _aCtrl : _bCtrl;
    if (ctrl.text.isEmpty) return;
    ctrl.text = ctrl.text.substring(0, ctrl.text.length - 1);
    ctrl.selection = TextSelection.fromPosition(
      TextPosition(offset: ctrl.text.length),
    );
    setState(() {});
  }

  void _clear() {
    final ctrl = _focus == InputField.a ? _aCtrl : _bCtrl;
    ctrl.clear();
    setState(() {});
  }

  void _toggleSign() {
    final ctrl = _focus == InputField.a ? _aCtrl : _bCtrl;
    final t = ctrl.text.trim();
    if (t.isEmpty) {
      ctrl.text = '-';
    } else if (t.startsWith('-')) {
      ctrl.text = t.substring(1);
    } else {
      ctrl.text = '-$t';
    }
    ctrl.selection = TextSelection.fromPosition(
      TextPosition(offset: ctrl.text.length),
    );
    setState(() {});
  }

  void _goSteps() {
    if (!_isValidForOp(_op)) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => StepsPage(
              a: _aCtrl.text.trim(),
              b: _bCtrl.text.trim(),
              operation: _op,
              autoPlay: false,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equalEnabled = _isValidForOp(_op);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1F3D35),
                Color(0xFF162B26),
              ], // Verde oscuro tipo pizarrón
            ),
          ),
          child: Column(
            children: [
              // Marco tipo pizarrón
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF203A34),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 18,
                        color: Colors.black26,
                        offset: Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF0F201D),
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título estilo clase
                      Row(
                        children: const [
                          Icon(Icons.calculate, color: Colors.white70),
                          SizedBox(width: 8),
                          Text(
                            'Calculadora educativa',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // "Pantalla" tipo calculadora/notebook
                      _Display(
                        a: _aCtrl.text,
                        b: _bCtrl.text,
                        opSymbol: _opSymbol,
                        focus: _focus,
                        onFocusA: () => setState(() => _focus = InputField.a),
                        onFocusB: () => setState(() => _focus = InputField.b),
                      ),
                      const SizedBox(height: 12),
                      // Botones de operación (deshabilitados si inválidos)
                      _OperationBar(
                        current: _op,
                        isEnabled: (op) => _isValidForOp(op),
                        onSelect: _selectOp,
                        onSolve: _goSteps,
                        solveEnabled: equalEnabled,
                      ),
                    ],
                  ),
                ),
              ),

              // Keypad (fuera del marco para dar sensación de mesa/banco)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0E201C), // Borde inferior más oscuro
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: _Keypad(
                    onTap: _append,
                    onBackspace: _backspace,
                    onClear: _clear,
                    onToggleSign: _toggleSign,
                  ),
                ),
              ),
              /* const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tip: el botón = inicia la explicación paso a paso',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}

class _Display extends StatelessWidget {
  final String a;
  final String b;
  final String opSymbol;
  final InputField focus;
  final VoidCallback onFocusA;
  final VoidCallback onFocusB;
  const _Display({
    required this.a,
    required this.b,
    required this.opSymbol,
    required this.focus,
    required this.onFocusA,
    required this.onFocusB,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle big = const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    TextStyle faded = const TextStyle(fontSize: 14, color: Colors.white54);

    BoxDecoration slot(bool active) => BoxDecoration(
      color: active ? const Color(0xFF2B5E56) : const Color(0xFF1B3934),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: active ? const Color(0xFF86EBD1) : const Color(0xFF0D2A26),
        width: active ? 2 : 1,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onFocusA,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: slot(focus == InputField.a),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Número A', style: faded),
                  const SizedBox(height: 4),
                  Text(
                    a.isEmpty ? '—' : a,
                    style: big,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(opSymbol, style: big),
        ),
        Expanded(
          child: InkWell(
            onTap: onFocusB,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: slot(focus == InputField.b),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Número B', style: faded),
                  const SizedBox(height: 4),
                  Text(
                    b.isEmpty ? '—' : b,
                    style: big,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OperationBar extends StatelessWidget {
  final Operation current;
  final bool Function(Operation) isEnabled;
  final void Function(Operation) onSelect;
  final VoidCallback onSolve;
  final bool solveEnabled;
  const _OperationBar({
    required this.current,
    required this.isEnabled,
    required this.onSelect,
    required this.onSolve,
    required this.solveEnabled,
  });

  @override
  Widget build(BuildContext context) {
    Widget opBtn(Operation op, String label) {
      final enabled = isEnabled(op);
      final selected = current == op;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton.tonal(
            onPressed: enabled ? () => onSelect(op) : null,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (!enabled) return const Color(0xFF2A3F3B);
                if (selected) return const Color(0xFF2F7C6F);
                return const Color(0xFF28574F);
              }),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 14),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            opBtn(Operation.add, '+'),
            opBtn(Operation.subtract, '−'),
            opBtn(Operation.multiply, '×'),
            opBtn(Operation.divide, '÷'),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: solveEnabled ? onSolve : null,
          icon: const Icon(Icons.play_circle_fill),
          label: const Text('Obtener resultado'),
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (!solveEnabled) return const Color(0xFF374B47);
              return const Color(0xFF2A7A7B);
            }),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onToggleSign;
  const _Keypad({
    required this.onTap,
    required this.onBackspace,
    required this.onClear,
    required this.onToggleSign,
  });

  Widget _btn(String txt, {VoidCallback? onPressed}) {
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF224C45)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      child: Text(
        txt,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = SizedBox(height: 10, width: 10);
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Números (3x4)
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _btn('7', onPressed: () => onTap('7')),
                            ),
                            gap,
                            Expanded(
                              child: _btn('8', onPressed: () => onTap('8')),
                            ),
                            gap,
                            Expanded(
                              child: _btn('9', onPressed: () => onTap('9')),
                            ),
                          ],
                        ),
                        gap,
                        Row(
                          children: [
                            Expanded(
                              child: _btn('4', onPressed: () => onTap('4')),
                            ),
                            gap,
                            Expanded(
                              child: _btn('5', onPressed: () => onTap('5')),
                            ),
                            gap,
                            Expanded(
                              child: _btn('6', onPressed: () => onTap('6')),
                            ),
                          ],
                        ),
                        gap,
                        Row(
                          children: [
                            Expanded(
                              child: _btn('1', onPressed: () => onTap('1')),
                            ),
                            gap,
                            Expanded(
                              child: _btn('2', onPressed: () => onTap('2')),
                            ),
                            gap,
                            Expanded(
                              child: _btn('3', onPressed: () => onTap('3')),
                            ),
                          ],
                        ),
                        gap,
                        Row(
                          children: [
                            Expanded(
                              child: _btn('0', onPressed: () => onTap('0')),
                            ),
                            gap,
                            Expanded(
                              child: _btn('00', onPressed: () => onTap('00')),
                            ),
                            gap,
                            Expanded(
                              child: _btn('000', onPressed: () => onTap('000')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Funciones
                  Expanded(
                    child: Column(
                      children: [
                        _btn('⌫', onPressed: onBackspace),
                        gap,
                        _btn('C', onPressed: onClear),
                        gap,
                        _btn('±', onPressed: onToggleSign),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================
// LÓGICA DE PASOS (igual que la versión anterior, con pequeños ajustes)
// =============================================================

class StepMark {
  final Set<int> colsRight; // columnas a subrayar (desde la derecha)
  final Color color; // color del subrayado / fondo
  final String? tag; // etiqueta para vincular con el texto
  final int? lineIndex; // 0-based en step.lines; null = todas las líneas

  const StepMark({
    required this.colsRight,
    required this.color,
    this.tag,
    this.lineIndex,
  });
}

class CalcStep {
  final List<String> lines;
  final Set<int> highlightColsRight;
  final String explanation;

  // ✅ nuevo: marcas de color para subrayar celdas/columnas
  final List<StepMark> marks;

  CalcStep({
    required this.lines,
    required this.explanation,
    this.highlightColsRight = const {},
    this.marks = const [], // <- por defecto vacío
  });
}

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

String _withSign(String s, String sign, int len) {
  final trimmed = s.trim();
  final withoutSign = trimmed.startsWith('-') ? trimmed.substring(1) : trimmed;
  final isNeg = trimmed.startsWith('-');
  final prefix = isNeg ? '-' : sign;
  final raw = '$prefix$withoutSign';
  return raw.padLeft(len);
}

String _tagAtRight(String s, int rightIndex, String tag) {
  final i = s.length - 1 - rightIndex; // 0 = último carácter (unidades)
  if (i < 0 || i >= s.length) return s;
  final ch = s[i];
  return '${s.substring(0, i)}[$tag]$ch[/$tag]${s.substring(i + 1)}';
}

List<CalcStep> _buildAddSteps(String a, String b) {
  final isNegA = a.trim().startsWith('-');
  final isNegB = b.trim().startsWith('-');
  if (isNegA || isNegB) {
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
      CalcStep(
        lines: lines,
        explanation: 'Suma de enteros (incluye signos).',
        marks: const [
          StepMark(colsRight: <int>{}, color: Colors.amber, tag: 'a'),
          StepMark(colsRight: <int>{}, color: Colors.cyan, tag: 'b'),
          StepMark(colsRight: <int>{}, color: Colors.lightGreen, tag: 'sum'),
        ],
      ),
    ];
  }

  final A = a.trim();
  final B = b.trim();
  final len = (A.length > B.length ? A.length : B.length) + 2;
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

    // Base sin tags
    final baseCarry = carry.join('').padLeft(len - 1).padLeft(len);
    final baseResult = (' ${result.join('')}').padLeft(len);

    // Taguear la columna actual y el posible acarreo
    String carryLineT = baseCarry;
    if (newCarry > 0 && i > 0) {
      // el acarreo se coloca una columna a la izquierda
      carryLineT = _tagAtRight(carryLineT, idxRight + 1, 'carry');
    }

    final aLineT = _tagAtRight(aLine, idxRight, 'a');
    final bLineT = _tagAtRight(bLine, idxRight, 'b');
    final resultLineT = _tagAtRight(baseResult, idxRight, 'digit');

    // Líneas con tags (el parser del BoardView quitará los tags y pintará la celda)
    final linesTagged = <String>[carryLineT, aLineT, bLineT, bar, resultLineT];

    // Texto con tags para _Explanation
    final carryOutText =
        newCarry == 0 ? '' : ' y el acarreo es [carry]$newCarry[/carry]';
    final explanationMain =
        'Paso ${idxRight + 1}: [a]$d1[/a] + [b]$d2[/b]'
        '${c > 0 ? ' + [c]$c (acarreo)[/c]' : ''}'
        ' = $s → escribe [digit]$digit[/digit]$carryOutText';

    // Paleta de colores por tag (no hace falta colsRight)
    final marks = <StepMark>[
      const StepMark(colsRight: {}, color: Colors.amber, tag: 'a'),
      const StepMark(colsRight: {}, color: Colors.cyan, tag: 'b'),
      const StepMark(colsRight: {}, color: Colors.lightGreen, tag: 'digit'),
      const StepMark(colsRight: {}, color: Colors.purple, tag: 'c'),
      if (newCarry > 0 && i > 0)
        const StepMark(colsRight: {}, color: Colors.pinkAccent, tag: 'carry'),
    ];

    if (d1 != 0 && d2 != 0) {
      steps.add(
        CalcStep(
          lines: linesTagged,
          explanation: explanationMain,
          highlightColsRight: const {}, // ← ahora usamos solo tags
          marks: marks,
        ),
      );
      c = newCarry;
    } else if (c != 0) {
      steps.add(
        CalcStep(
          lines: linesTagged,
          explanation:
              'Paso ${idxRight + 1}: Bajar el [c]acarreo final $c[/c] → escribe [digit]$digit[/digit]',
          highlightColsRight: const {},
          marks: const [
            StepMark(colsRight: {}, color: Colors.purple, tag: 'c'),
            StepMark(colsRight: {}, color: Colors.lightGreen, tag: 'digit'),
          ],
        ),
      );
    }
  }

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
      marks: const [
        StepMark(colsRight: <int>{}, color: Colors.lightGreen, tag: 'sum'),
      ],
    ),
  );

  return steps;
}

List<CalcStep> _buildSubtractSteps(String a, String b) {
  // Resta por columnas con préstamo (A - B)
  final ai = int.parse(a);
  final bi = int.parse(b);
  if (ai < bi) {
    // Resultado negativo: calculamos B − A y luego anteponemos el signo −
    final stepsPos = _buildSubtractSteps(bi.toString(), ai.toString());
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

  int carryBorrow = 0;
  final steps = <CalcStep>[];

  for (int i = da.length - 1, idxRight = 0; i >= 0; i--, idxRight++) {
    final rawTop = da[i];
    final bot = db[i];

    int top = rawTop - carryBorrow;

    String reason;
    String previewExpr;
    int newBorrow = 0;

    String lastDigitOfTop = (top % 10).toString();
    String lastDigitOfRawTop = (rawTop % 10).toString();

    String carryBorrowReason =
        carryBorrow == 1
            ? ' $lastDigitOfRawTop prestó 1 en el paso anterior, $lastDigitOfRawTop → $top. $top − $bot.'
            : '';

    if (top < bot) {
      top += 10;
      newBorrow = 1;
      reason =
          'Como $lastDigitOfTop es menor que $bot, tomamos 1 de la columna izquierda. $lastDigitOfTop → $top.';
      previewExpr = '$top − $bot = ${top - bot}';
    } else {
      reason = '';
      previewExpr = '$top − $bot = ${top - bot}';
    }

    final d = top - bot;
    result[i] = d.toString();

    // ===== Render/tag de líneas por celda =====

    // 1) Línea de préstamo (solo si hubo préstamo nuevo en este paso)
    String? carryLineT;
    if (newBorrow == 1 && i > 0) {
      final borrowLine = List<String>.filled(len - 1, ' ');
      borrowLine[i - 1] = '1';
      final baseBorrow = borrowLine.join('').padLeft(len - 1).padLeft(len);
      // el '1' va una columna a la izquierda de la actual
      carryLineT = _tagAtRight(baseBorrow, idxRight + 1, 'borrow');
    }

    // 2) Línea A, línea B, resultado parcial → tag en la celda activa
    final baseResult = (' ${result.join('')}').padLeft(len);
    final aLineT = _tagAtRight(aLine, idxRight, 'a');
    final bLineT = _tagAtRight(bLine, idxRight, 'b');
    final resultLineT = _tagAtRight(baseResult, idxRight, 'digit');

    // 3) Empaqueta líneas (si no hay préstamo, esa línea no se agrega)
    final linesTagged = <String>[
      if (carryLineT != null) carryLineT,
      aLineT,
      bLineT,
      bar,
      resultLineT,
    ];

    // 4) Explicación con tags que coinciden con el tablero
    final carryBorrowReasonT =
        carryBorrow == 1
            ? ' [borrow]$lastDigitOfRawTop[/borrow] prestó 1 en el paso anterior, '
                '$lastDigitOfRawTop → $top. $top − $bot.'
            : '';

    final reasonT =
        top - (newBorrow == 1 ? 10 : 0) < bot
            ? ' Como [a]$lastDigitOfTop[/a] es menor que [b]$bot[/b], tomamos [borrow]1[/borrow] de la columna izquierda. '
                '$lastDigitOfTop → $top.'
            : (reason.isEmpty ? '' : ' $reason');

    final previewExprT = ' $previewExpr';
    final explanationT =
        'Paso ${idxRight + 1} [[a]$rawTop[/a] − [b]$bot[/b]]:$carryBorrowReasonT$reasonT$previewExprT → escribe [digit]$d[/digit].';

    // 5) Paleta de colores por tag (solo por tag; lineIndex y colsRight no son necesarios)
    const marks = <StepMark>[
      StepMark(colsRight: {}, color: Colors.amber, tag: 'a'), // dígito de A
      StepMark(colsRight: {}, color: Colors.cyan, tag: 'b'), // dígito de B
      StepMark(
        colsRight: {},
        color: Colors.lightGreen,
        tag: 'digit',
      ), // dígito resultado
      StepMark(
        colsRight: {},
        color: Colors.pinkAccent,
        tag: 'borrow',
      ), // préstamo
    ];

    // 6) Agrega el paso (conserva tu lógica original)
    if (rawTop != 0 && bot != 0) {
      steps.add(
        CalcStep(
          lines: linesTagged,
          explanation: explanationT,
          highlightColsRight:
              const {}, // el resaltado ahora lo controlan los tags
          marks: marks,
        ),
      );
    } else if (carryBorrow != 0) {
      steps.add(
        CalcStep(
          lines: linesTagged,
          explanation:
              'Paso ${idxRight + 1}: Se aplica el [borrow]préstamo[/borrow] previo → escribe [digit]$d[/digit].',
          highlightColsRight: const {},
          marks: marks,
        ),
      );
    }

    carryBorrow = newBorrow;
  }

  // Paso final
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
  // Multiplicación larga (A × B) construyendo cada línea parcial dígito a dígito
  final isNeg = (a.trim().startsWith('-')) ^ (b.trim().startsWith('-'));
  final A = a.trim().replaceAll('-', '');
  final B = b.trim().replaceAll('-', '');

  // Ancho suficiente para mostrar parciales y resultado final
  final maxLenNeeded = (A.length + B.length) + 4;
  final len = maxLenNeeded;

  final top = _withSign(A, ' ', len);
  final bottom = _withSign(B, '×', len);
  final bar = ''.padLeft(len, '—');

  final steps = <CalcStep>[];
  final partials =
      <String>[]; // líneas parciales ya finalizadas (strings de ancho len-1)

  final aDigits = A.split('').map((e) => int.parse(e)).toList();
  final bDigits = B.split('').map((e) => int.parse(e)).toList();

  // Helper: renderiza una línea parcial intermedia con espacios en los dígitos aún no calculados
  String renderPartialProgress(List<String> core, int shift) {
    final coreStr = core.join('');
    final shifted =
        coreStr +
        ''.padRight(
          shift,
          '0',
        ); // desplazamiento por posición del dígito del multiplicador
    return shifted.padLeft(len - 1);
  }

  for (int jb = bDigits.length - 1; jb >= 0; jb--) {
    final d2 = bDigits[jb];
    final shift = (bDigits.length - 1 - jb); // ceros a la derecha
    int carry = 0;

    // Núcleo de la parcial (tamaño A.length + 1 para posible acarreo final extra)
    final core = List<String>.filled(aDigits.length + 1, ' ');
    // Índice de escritura en el núcleo contado desde la derecha (0 = última posición del núcleo)
    int coreRightIndex = 0;

    for (int ia = aDigits.length - 1; ia >= 0; ia--) {
      final d1 = aDigits[ia];
      final prod = d1 * d2 + carry;
      final digit = prod % 10;
      carry = prod ~/ 10;

      // Posición de escritura (desde la derecha) dentro del núcleo
      // coreRightIndex 0 corresponde al dígito menos significativo de A×d2 (antes del shift)
      core[core.length - 1 - coreRightIndex] = digit.toString();
      coreRightIndex++;

      // Calcula en qué columna global (desde la derecha) cayó este dígito ya desplazado
      final posRight = shift + (aDigits.length - 1 - ia);

      // Construye líneas: encabezado, parciales ya finalizados, y la parcial en progreso
      final lines = <String>[
        top,
        bottom,
        bar,
        ...partials.map((p) => (' $p').padLeft(len)),
        (' ${renderPartialProgress(core, shift)}').padLeft(len),
      ];

      steps.add(
        CalcStep(
          lines: lines,
          explanation:
              'Fila por $d2: $d1 × $d2 + acarreo = $prod → escribe $digit (acarreo nuevo: $carry).',
          highlightColsRight: {posRight},
        ),
      );
    }

    // Si quedó acarreo al terminar la fila, agregarlo al inicio del núcleo y mostrar un paso más
    if (carry > 0) {
      // mueve el acarreo al extremo izquierdo disponible
      final leftSlot = core.indexWhere((c) => c == ' ');
      final idx = (leftSlot == -1) ? 0 : leftSlot;
      core[idx] = carry.toString();

      final lines = <String>[
        top,
        bottom,
        bar,
        ...partials.map((p) => (' $p').padLeft(len)),
        (' ${renderPartialProgress(core, shift)}').padLeft(len),
      ];

      // El dígito cae en la columna global siguiente a la más a la izquierda construida
      final posRightCarry =
          shift +
          aDigits.length; // inmediatamente a la izquierda del último escrito
      steps.add(
        CalcStep(
          lines: lines,
          explanation:
              'Añade el acarreo restante $carry al inicio de la línea parcial.',
          highlightColsRight: {posRightCarry},
        ),
      );
    }

    // Finaliza la línea parcial: rellena espacios no usados con ' ' (ya están) y congélala
    final finalPartial = renderPartialProgress(core, shift);
    partials.add(finalPartial);
  }

  // Paso final: sumar las líneas parciales (igual que antes)
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

// =============================================================
// PANTALLA DE PASOS (sin cambios visuales de pizarrón aún)
// =============================================================
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
      await Future.delayed(const Duration(milliseconds: 5000));
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
                      marks: steps[idx].marks,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _Explanation(
                text: steps[idx].explanation,
                marks: steps[idx].marks,
              ),
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
            const SizedBox(width: 56),
            /* FilledButton.tonalIcon(
              onPressed: onPlayPause,
              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              label: Text(playing ? 'Pausar' : 'Reproducir'),
            ),*/
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
  final List<StepMark> marks; // paleta de colores por tag

  const _BoardView({
    super.key,
    required this.step,
    required this.pulse,
    this.marks = const [],
  });

  Color? _colorForTag(String? tag, int lineIndex) {
    if (tag == null) return null;
    for (final m in marks) {
      if (m.tag == tag && (m.lineIndex == null || m.lineIndex == lineIndex)) {
        return m.color;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 1) Parsear todas las líneas para medir longitud visible máxima
    final parsed = <List<_CellToken>>[];
    int maxLen = 0;
    for (final line in step.lines) {
      final toks = _parseTaggedLine(line); // sin pad
      parsed.add(toks);
      if (toks.length > maxLen) maxLen = toks.length;
    }

    // 2) Render con padding uniforme
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int li = 0; li < parsed.length; li++)
          _MonoRow(
            lineIndex: li,
            cells: _parseTaggedLine(step.lines[li], padLeftTo: maxLen),
            maxLen: maxLen,
            pulse: pulse,
            colorForTag: (tag) => _colorForTag(tag, li),
          ),
      ],
    );
  }
}

class _MonoRow extends StatelessWidget {
  final int lineIndex;
  final List<_CellToken> cells; // celdas ya alineadas (long = maxLen)
  final int maxLen;
  final Animation<double> pulse;
  final Color? Function(String? tag) colorForTag;

  const _MonoRow({
    super.key,
    required this.lineIndex,
    required this.cells,
    required this.maxLen,
    required this.pulse,
    required this.colorForTag,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < cells.length; i++)
          Builder(
            builder: (_) {
              final token = cells[i];
              final color = colorForTag(token.tag); // color por tag
              final pulseThisCell =
                  token.tag != null; // palpita si está tagueada
              return _Cell(
                ch: token.ch,
                pulseHighlight: pulseThisCell,
                borderColor: color,
                pulse: pulse,
              );
            },
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  final String ch;
  final bool pulseHighlight;
  final Color? borderColor;
  final Animation<double> pulse;

  const _Cell({
    super.key,
    required this.ch,
    required this.pulseHighlight,
    required this.borderColor,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleMedium!.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return ScaleTransition(
      scale:
          pulseHighlight
              ? Tween<double>(
                begin: 1,
                end: 1.07,
              ).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut))
              : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          border:
              borderColor != null
                  ? Border.all(color: borderColor!, width: 2)
                  : null, // 👈 borde SOLO si hay tag
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(ch, style: base),
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  final String text;
  final List<StepMark> marks; // se usa para obtener color por tag

  const _Explanation({required this.text, required this.marks});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium!;
    final paletteByTag = <String, Color>{
      for (final m in marks)
        if (m.tag != null) m.tag!: m.color,
    };

    final spans = _parseWithUnderline(text, paletteByTag, base);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: spans,
        style: base.copyWith(color: Colors.black),
      ),
    );
  }

  List<InlineSpan> _parseWithUnderline(
    String input,
    Map<String, Color> palette,
    TextStyle base,
  ) {
    final regex = RegExp(r'\[(\w+)\](.*?)\[/\1\]', dotAll: true);

    final spans = <InlineSpan>[];
    int last = 0;
    debugPrint(
      RegExp(
        r'\[(\w+)\](.*?)\[/\1\]',
        dotAll: true,
      ).allMatches(input).map((m) => m.group(0)).toList().toString(),
    );
    for (final m in regex.allMatches(input)) {
      if (m.start > last) {
        spans.add(TextSpan(text: input.substring(last, m.start)));
      }
      final tag = m.group(1)!;
      final content = m.group(2)!;
      final color = palette[tag];

      if (color != null) {
        spans.add(
          TextSpan(
            text: content,
            style: base.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: color,
              decorationThickness: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(text: content, style: base),
        ); // si no hay color para ese tag
      }
      last = m.end;
    }

    if (last < input.length) {
      spans.add(TextSpan(text: input.substring(last)));
    }
    return spans;
  }
}

class _CellToken {
  final String ch; // carácter visible en la celda (1 char)
  final String? tag; // tag opcional: 'a', 'b', 'digit', etc.
  const _CellToken(this.ch, this.tag);
}

List<_CellToken> _parseTaggedLine(String line, {int? padLeftTo}) {
  // Patrón: [tag]contenido[/tag]
  final re = RegExp(r'\[(\w+)\](.*?)\[/\1\]', dotAll: true);
  final tokens = <_CellToken>[];

  int last = 0;
  for (final m in re.allMatches(line)) {
    // texto normal previo
    if (m.start > last) {
      final plain = line.substring(last, m.start);
      for (final ch in plain.characters) {
        tokens.add(_CellToken(ch, null));
      }
    }
    // contenido tagueado
    final tag = m.group(1)!;
    final content = m.group(2)!;
    for (final ch in content.characters) {
      tokens.add(_CellToken(ch, tag));
    }
    last = m.end;
  }
  // resto sin tag
  if (last < line.length) {
    final plain = line.substring(last);
    for (final ch in plain.characters) {
      tokens.add(_CellToken(ch, null));
    }
  }

  // padding a la izquierda hasta padLeftTo (en celdas visibles)
  if (padLeftTo != null && tokens.length < padLeftTo) {
    final missing = padLeftTo - tokens.length;
    final pad = List<_CellToken>.generate(
      missing,
      (_) => const _CellToken(' ', null),
    );
    return [...pad, ...tokens];
  }
  return tokens;
}
