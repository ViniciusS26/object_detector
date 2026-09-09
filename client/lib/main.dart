import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(DetectorApp(cameras: cameras));
}

class DetectorApp extends StatelessWidget {
  const DetectorApp({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detector TCP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0b6e69)),
        useMaterial3: true,
      ),
      home: DetectionPage(cameras: cameras),
    );
  }
}

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  CameraController? _cameraController;
  final _imagePicker = ImagePicker();
  final _hostController = TextEditingController(text: '10.0.2.2');
  final _portController = TextEditingController(text: '5000');
  List<DetectedObject> _objects = [];
  Uint8List? _photoBytes;
  String _status = 'Iniciando camera...';
  bool _busy = false;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      setState(() => _status = 'Nenhuma camera encontrada.');
      return;
    }
    final camera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => widget.cameras.first,
    );
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _status = 'Pronto para detectar';
      });
    } catch (error) {
      await controller.dispose();
      if (mounted) setState(() => _status = 'Erro ao abrir camera: $error');
    }
  }

  Future<void> _captureAndDetect() async {
    final controller = _cameraController;
    if (_busy || controller == null || !controller.value.isInitialized) return;

    final photo = await controller.takePicture();
    await _processPhoto(photo);
  }

  Future<void> _pickAndDetect() async {
    if (_busy) return;
    final photo = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (photo == null) return;
    await _processPhoto(photo);
  }

  Future<void> _processPhoto(XFile photo) async {
    if (_busy) return;

    try {
      final photoBytes = await photo.readAsBytes();
      setState(() {
        _busy = true;
        _status = 'Processando e enviando...';
        _objects = [];
        _hasResult = false;
        _photoBytes = photoBytes;
      });
      final jpeg = _prepareJpeg(photoBytes);
      final port = int.tryParse(_portController.text.trim());
      if (port == null || port < 1 || port > 65535) {
        throw const FormatException('Porta invalida');
      }
      final objects = await TcpDetectorClient(
        host: _hostController.text.trim(),
        port: port,
      ).detect(jpeg);
      if (!mounted) return;
      setState(() {
        _objects = objects;
        _hasResult = true;
        _status = objects.isEmpty ? 'Nada Detectado' : 'Deteccao concluida';
      });
    } catch (error) {
      if (mounted) setState(() => _status = 'Falha: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Uint8List _prepareJpeg(Uint8List bytes) {
    final decoded = image_lib.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Imagem JPEG invalida');
    final resized = decoded.width > 1280
        ? image_lib.copyResize(decoded, width: 1280)
        : decoded;
    return Uint8List.fromList(image_lib.encodeJpg(resized, quality: 80));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    const cameraPreviewHeight = 300.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Detector de objetos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: cameraPreviewHeight,
            child: _photoBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(_photoBytes!, fit: BoxFit.contain),
                  )
                : controller?.value.isInitialized == true
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: CameraPreview(controller),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 16),
          Text(_status, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'IP do servidor',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Porta',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _captureAndDetect,
                  icon: _busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                  label: const Text('Tirar foto'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _pickAndDetect,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Enviar da galeria'),
                ),
              ),
            ],
          ),
          if (_hasResult) ...[
            const SizedBox(height: 20),
            if (_objects.isEmpty)
              Text(
                'Nada Detectado',
                style: Theme.of(context).textTheme.titleLarge,
              )
            else ...[
              Text(
                'Objetos encontrados',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _objects
                    .map(
                      (object) => Chip(
                        avatar: const Icon(Icons.check_circle, size: 18),
                        label: Text(object.displayName),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class DetectedObject {
  const DetectedObject({required this.label, required this.confidence});

  final String label;
  final double confidence;

  static const _translations = <String, String>{
    'person': 'pessoa',
    'bicycle': 'bicicleta',
    'car': 'carro',
    'motorcycle': 'motocicleta',
    'airplane': 'aviao',
    'bus': 'onibus',
    'train': 'trem',
    'truck': 'caminhao',
    'boat': 'barco',
    'traffic light': 'semaforo',
    'fire hydrant': 'hidrante',
    'stop sign': 'placa de pare',
    'parking meter': 'parquimetro',
    'bench': 'banco',
    'bird': 'passaro',
    'cat': 'gato',
    'dog': 'cachorro',
    'horse': 'cavalo',
    'sheep': 'ovelha',
    'cow': 'vaca',
    'elephant': 'elefante',
    'bear': 'urso',
    'zebra': 'zebra',
    'giraffe': 'girafa',
    'backpack': 'mochila',
    'umbrella': 'guarda-chuva',
    'handbag': 'bolsa',
    'tie': 'gravata',
    'suitcase': 'mala',
    'frisbee': 'frisbee',
    'skis': 'esquis',
    'snowboard': 'snowboard',
    'sports ball': 'bola esportiva',
    'kite': 'pipa',
    'baseball bat': 'taco de beisebol',
    'baseball glove': 'luva de beisebol',
    'skateboard': 'skate',
    'surfboard': 'prancha de surfe',
    'tennis racket': 'raquete de tenis',
    'bottle': 'garrafa',
    'wine glass': 'taça de vinho',
    'cup': 'xícara',
    'fork': 'garfo',
    'knife': 'faca',
    'spoon': 'colher',
    'bowl': 'tigela',
    'banana': 'banana',
    'apple': 'maca',
    'sandwich': 'sanduiche',
    'orange': 'laranja',
    'broccoli': 'brocolis',
    'carrot': 'cenoura',
    'hot dog': 'cachorro-quente',
    'pizza': 'pizza',
    'donut': 'rosquinha',
    'cake': 'bolo',
    'chair': 'cadeira',
    'couch': 'sofa',
    'potted plant': 'planta em vaso',
    'bed': 'cama',
    'dining table': 'mesa de jantar',
    'toilet': 'vaso sanitario',
    'tv': 'televisao',
    'laptop': 'laptop',
    'mouse': 'mouse',
    'remote': 'controle remoto',
    'keyboard': 'teclado',
    'cell phone': 'celular',
    'microwave': 'micro-ondas',
    'oven': 'forno',
    'toaster': 'torradeira',
    'sink': 'pia',
    'refrigerator': 'geladeira',
    'book': 'livro',
    'clock': 'relogio',
    'vase': 'vaso',
    'scissors': 'tesoura',
    'teddy bear': 'urso de pelucia',
    'hair drier': 'secador de cabelo',
    'toothbrush': 'escova de dentes',
  };

  String get displayName {
    final normalizedLabel = label.toLowerCase();
    final translatedLabel = _translations[normalizedLabel] ?? normalizedLabel;
    return '$translatedLabel detectado';
  }

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      label: json['label'] as String? ?? 'desconhecido',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TcpDetectorClient {
  const TcpDetectorClient({required this.host, required this.port});

  final String host;
  final int port;

  Future<List<DetectedObject>> detect(Uint8List jpeg) async {
    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 8),
    );
    try {
      final header = ByteData(4)..setUint32(0, jpeg.length);
      socket.add(header.buffer.asUint8List());
      socket.add(jpeg);
      await socket.flush();
      final response = await _readLine(socket).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Servidor demorou demais'),
      );
      final decoded = jsonDecode(response) as Map<String, dynamic>;
      if (decoded['error'] != null) throw Exception(decoded['error']);
      return (decoded['objects'] as List<dynamic>? ?? [])
          .map((item) => DetectedObject.fromJson(item as Map<String, dynamic>))
          .toList();
    } finally {
      await socket.close();
    }
  }

  Future<String> _readLine(Socket socket) async {
    final completer = Completer<String>();
    final buffer = BytesBuilder();
    late final StreamSubscription<List<int>> subscription;
    subscription = socket.listen((chunk) {
      buffer.add(chunk);
      final bytes = buffer.toBytes();
      final newline = bytes.indexOf(10);
      if (newline >= 0 && !completer.isCompleted) {
        completer.complete(utf8.decode(bytes.sublist(0, newline)));
        subscription.cancel();
      }
    }, onError: completer.completeError);
    return completer.future;
  }
}
