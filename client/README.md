# Detector de objetos por TCP

O app Flutter captura uma foto, redimensiona a largura para no maximo 1280 px, codifica em JPEG com qualidade 80 e envia para um servidor Python.

## Servidor Python

Na pasta do projeto, crie um ambiente virtual e instale as dependencias:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python server.py
```

O modelo `yolo11n.pt` e baixado automaticamente na primeira execucao. A porta padrao e `5000`, mas pode ser alterada com `--port 5001`.

## Aplicativo Flutter

```powershell
flutter pub get
flutter run
```

Na tela do app, informe o IP do computador que executa o servidor e a porta. Para o emulador Android padrao, use `10.0.2.2`; em um celular fisico, use o IP local do computador na mesma rede Wi-Fi. Libere a porta 5000 no firewall se necessario.

## Protocolo

1. O cliente envia 4 bytes sem sinal com o tamanho da imagem, em big-endian.
2. O cliente envia os bytes do JPEG.
3. O servidor responde uma linha JSON, por exemplo:

```json
{"objects": [{"label": "person", "confidence": 0.91}]}
```
