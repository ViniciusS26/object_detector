# Detector de objetos por TCP

Aplicacao Android em Flutter que captura uma foto e envia a imagem para um
servidor Python via socket TCP. O servidor usa OpenCV e YOLO para detectar
objetos e devolve os resultados em JSON.

## Estrutura

```text
client/   Aplicativo Flutter Android
server/   Servidor Python TCP e dependencias
```

## Servidor

Execute a partir da raiz do projeto:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r server\requirements.txt
python server\server.py
```

Sempre ative o `.venv` antes de iniciar o servidor. Alternativamente, execute
diretamente `\.venv\Scripts\python.exe server\server.py` sem ativar o ambiente.

O modelo `yolo11n.pt` e baixado automaticamente pelo Ultralytics na primeira
execucao. Ele e ignorado pelo Git por ser um arquivo grande.

## Cliente Android

Em outro terminal, execute a partir da pasta `client`:

```powershell
cd client
flutter pub get
flutter run
```

No emulador Android padrao, informe `10.0.2.2` no campo IP do servidor. Em um
celular fisico, informe o IP do computador na mesma rede Wi-Fi e libere a porta
`5000` no firewall.

O cliente permite tirar uma foto pela camera ou selecionar uma imagem existente
pela galeria. As duas opcoes usam o mesmo processamento e reconhecimento.

## Protocolo TCP

1. O cliente envia 4 bytes sem sinal com o tamanho da imagem em big-endian.
2. O cliente envia os bytes da foto em JPEG, qualidade 80 e largura maxima de
   1280 px.
3. O servidor responde uma linha JSON, por exemplo:

```json
{"objects": [{"label": "person", "confidence": 0.91}]}
```