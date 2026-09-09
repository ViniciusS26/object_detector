# Detector de objetos por TCP

Aplicacao Android em Flutter que captura uma foto e envia a imagem para um
servidor Python via socket TCP. O servidor usa OpenCV e YOLO para detectar
objetos e devolve os resultados em JSON.

## Estrutura

```text
client/   Aplicativo Flutter Android
server/   Servidor Python TCP e dependencias
```
# Como executar
## Servidor

Execute a partir da raiz do projeto:
projeto a 
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

Sim. Dá para manter **exatamente essa arquitetura e protocolo**, mas trocar os nomes das mensagens retornadas pelo servidor para sinônimos mais naturais, sem alterar o funcionamento.

### Versão adaptada

**2. Servidor (Python):**

* Recebe o cabeçalho de 4 bytes e lê exatamente os `N` bytes da imagem.
* Salva a foto recebida na pasta `capturas/` com timestamp (`captura_YYYYMMDD_HHMMSS.jpg`).
* Decodifica a imagem utilizando **OpenCV** (`cv2.imdecode`).
* Realiza a inferência utilizando **YOLOv8n** (`ultralytics`).
* Salva uma cópia da imagem com as marcações/bounding boxes em `capturas/anotadas/`.
* Retorna via socket TCP uma mensagem contendo os **elementos identificados na imagem**, utilizando descrições como:

  * **Indivíduo identificado**
  * **Assento identificado**
  * **Bolsa identificada**
  * **Mesa identificada**
  * **Veículo identificado**
  * **Animal identificado**
  * **Objeto identificado**
* Caso nenhum elemento seja reconhecido, o servidor retorna **“Nenhum elemento identificado”**.


Claro. Mantendo **o mesmo modelo, estrutura e comandos**, você pode trocar apenas as expressões por sinônimos mais naturais e profissionais:

### 🚀 Como Executar o Servidor Python

### 1. Requisitos Necessários

* Python 3.10 ou versão superior instalado no computador.


## 🚀 Como Executar o Servidor Python

### 🐧 Linux

#### 1. Abrir o terminal

Abra o terminal e acesse a pasta onde o projeto está localizado:

```bash
cd caminho/do/projeto
```

Exemplo:

```bash
cd ~/trab2-sd-flutter
```

#### 2. Verificar a versão do Python

Execute:

```bash
python3 --version
```

O projeto requer **Python 3.10 ou superior**.

#### 3. Criar o ambiente virtual

Caso a pasta `.venv` ainda não exista, crie o ambiente virtual:

```bash
python3 -m venv .venv
```

#### 4. Ativar o ambiente virtual

Execute:

```bash
source .venv/bin/activate
```

Após a ativação, o terminal normalmente apresentará algo semelhante a:

```text
(.venv) usuario@computador:~/trab2-sd-flutter$
```

#### 5. Atualizar o `pip`

```bash
python3 -m pip install --upgrade pip
```

#### 6. Instalar as dependências

Com o ambiente virtual ativado:

```bash
pip install -r requirements.txt
```

Aguarde a conclusão da instalação das bibliotecas necessárias.

#### 7. Executar o servidor

Após instalar as dependências:

```bash
python3 server.py
```

O servidor será iniciado e ficará disponível para receber as imagens enviadas pelo aplicativo.

---

### 🪟 Windows

#### 1. Abrir o PowerShell ou Prompt de Comando

Abra o **PowerShell** ou o **Prompt de Comando (CMD)**.

Acesse a pasta do projeto:

```powershell
cd caminho\do\projeto
```

Exemplo:

```powershell
cd C:\Users\Usuario\trab2-sd-flutter
```

#### 2. Verificar a versão do Python

Execute:

```powershell
python --version
```

O projeto requer **Python 3.10 ou superior**.

#### 3. Criar o ambiente virtual

Caso a pasta `.venv` ainda não exista:

```powershell
python -m venv .venv
```

#### 4. Ativar o ambiente virtual

No **PowerShell**, execute:

```powershell
.venv\Scripts\Activate.ps1
```

No **CMD**, utilize:

```cmd
.venv\Scripts\activate.bat
```

Após a ativação, deverá aparecer algo semelhante a:

```text
(.venv) C:\Users\Usuario\trab2-sd-flutter>
```

#### 5. Atualizar o `pip`

```powershell
python -m pip install --upgrade pip
```

#### 6. Instalar as dependências

```powershell
pip install -r requirements.txt
```

Aguarde até que todas as bibliotecas sejam instaladas.

#### 7. Executar o servidor

```powershell
python server.py
```

O servidor ficará ativo aguardando as imagens enviadas pelo aplicativo Flutter.

---

### ⚠️ Caso o PowerShell bloqueie a ativação da `.venv`

Se aparecer uma mensagem informando que a execução de scripts está bloqueada, abra o PowerShell e execute:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Depois, tente novamente:

```powershell
.venv\Scripts\Activate.ps1
```

---

### 🔄 Comandos resumidos

#### Linux

```bash
cd ~/trab2-sd-flutter
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
pip install -r requirements.txt
python3 server.py
```

#### Windows

```powershell
cd C:\Users\Usuario\trab2-sd-flutter
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
python server.py
```

### ✅ Quando o servidor estiver funcionando

O terminal deverá permanecer aberto enquanto o aplicativo Flutter estiver sendo utilizado. O servidor ficará aguardando uma conexão do dispositivo Android para receber a fotografia, processá-la e retornar o resultado da análise.


##  Como Configurar e Executar o Aplicativo Flutter

### 1. Conectar o Dispositivo e Executar o Aplicativo

Com o dispositivo Android conectado ao computador por **USB** ou utilizando **depuração via Wi-Fi**, e após autorizar a conexão, execute no terminal:

```bash
flutter run
```

### 2. Definir o Endereço IP e a Porta do Servidor

1. Na parte superior direita da tela do aplicativo, toque no **ícone de configurações** ⚙️ ou no **painel de status** localizado no topo.
2. Informe o **endereço IP** apresentado pelo servidor `server.py` e mantenha a **porta `5000`**.
3. Selecione a opção **“Verificar Conexão”** para confirmar se o dispositivo Android consegue estabelecer comunicação com o computador através da rede local.
4. Após a confirmação, toque em **“Gravar Configurações”** para armazenar os dados informados.



##  Roteiro de Demonstração — Etapas de Execução

1. **Executar o Servidor:**

   * Inicie o servidor utilizando `python server.py`.
   * O terminal ficará disponível para novas solicitações e apresentará a mensagem **“Aguardando o recebimento de uma imagem...”**.

2. **Utilizar o Aplicativo:**

   * Verifique se o **endereço IP** e a **porta do servidor** estão configurados corretamente.
   * Pressione o botão principal **“Capturar e Analisar”**.
   * Fotografe um ou mais elementos, como **pessoa, cadeira, garrafa ou mochila**, e confirme a captura.

3. **Processamento no Servidor:**

   * O servidor recebe os dados enviados pelo aplicativo, armazena a imagem na pasta `capturas/` e inicia o processamento utilizando o **YOLO**.
   * Após a análise, o servidor apresenta no terminal os elementos reconhecidos e encaminha o resultado para o aplicativo.

4. **Apresentação do Resultado:**

   * O aplicativo apresenta etiquetas (**badges**) contendo os nomes dos elementos identificados, por exemplo: **“Indivíduo identificado”** ou **“Bolsa identificada”**.
   * Quando nenhum elemento reconhecível for encontrado, será apresentada a mensagem **“Nenhum elemento identificado”**.

5. **Realizar uma Nova Captura:**

   * Pressione novamente o botão **“Capturar e Analisar”** para registrar uma nova imagem.
   * O resultado da análise anterior será substituído automaticamente pelo novo resultado.





### Exemplo de resposta do servidor

Em vez de:

```text
Pessoa detectada
Cadeira detectada
Mochila detectada
```

pode retornar:

```text
Indivíduo identificado
Assento identificado
Bolsa identificada
```

Ou, quando houver vários objetos:

```text
Elementos identificados:
- Indivíduo
- Assento
- Bolsa
- Mesa
```

E quando não houver detecção:

```text
Nenhum elemento identificado
```

**Importante:** se isso for para o seu trabalho de **Android/Flutter + servidor Python**, eu manteria o protocolo dos **4 bytes + N bytes JPEG** exatamente como está, porque trocar apenas as mensagens de resultado não interfere na comunicação TCP.







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
