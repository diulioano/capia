# Pesquisa técnica: Get Started do Capia

Pesquisa concluída em 2026-11-06, com inspeção somente leitura do ambiente, do design
e da documentação primária. As decisões abaixo resolvem o contexto técnico do plano.
Nenhum app, fonte ou ícone foi gerado durante esta pesquisa.

## 1. Compilar no Ubuntu do WSL

**Decisão**: Usar o Ubuntu existente pelo Bash, Swift 6.4.2 e xtool 1.24.0. O SDK Darwin
já está instalado em `/home/diuli/.swiftpm/swift-sdks/darwin.artifactbundle`, flavor slim,
epoch 4, darwinTools 1.1.0, oam 1.4.1. O projeto fica disponível em
`/mnt/c/Users/Diuli/.t3/projects/i-dont-the-name-yet`.

**Motivo**: Reutiliza o ambiente do usuário. Swift e xtool estão disponíveis no Ubuntu,
não no PATH nativo do Windows. A execução com `bash -lc` funcionou; `sh -lc` falhou ao
carregar o ambiente do swiftly com "Bad substitution", portanto o guia usa Bash.

**Alternativas consideradas**: Instalar outra toolchain no Windows; exigir Mac; repetir
o teste do app padrão. Nenhuma é necessária para esta entrega.

**Evidência**: `swift --version`, `xtool --version` e `xtool sdk status` executados.
O usuário já confirmou a execução do app padrão no iPhone. A pesquisa de dispositivos
com `xtool devices --no-wait` não listou aparelho naquele momento; isso não comprova
conexão atual nem invalida o teste anterior.

Os subcomandos locais `xtool dev build`, `xtool dev build --sign --ipa` e `xtool dev run`
foram conferidos no help, mas não foram executados para o Capia. O tutorial oficial
explica a estrutura library e a instalação pelo xtool. [Tutorial oficial](https://github.com/xtool-org/xtool/blob/main/Documentation/xtool.docc/First-app.tutorial).

## 2. App como library e testes de navegação separados

**Decisão**: Pacote `ios/Capia` com produto library Capia, empacotado pelo xtool, e pacote
local `ios/CapiaFlow` para o estado puro. Adotar Swift tools 6.0, modo Swift 6 e iOS 17
como alvo mínimo inicial. Não são necessárias APIs posteriores.

**Motivo**: O formato library corresponde à seleção do produto feita pelo xtool.
O segundo pacote permite executar XCTest no Linux com `swift test --package-path ios/CapiaFlow`, sem importar SwiftUI. O fluxo não precisa de persistência ou serviços.

**Alternativas consideradas**: Um único pacote para tudo, manifestos condicionais ao host
e roteador global. Selecionar testes por filtro não garante excluir o target do app da
compilação; um pacote puro evita essa dependência sem introduzir arquitetura de produção.

**Fontes**: [Planner do xtool](https://github.com/xtool-org/xtool/blob/main/Sources/PackLib/Planner.swift),
[documentação swift test](https://github.com/swiftlang/swift-package-manager/blob/main/Sources/PackageManagerDocs/Documentation.docc/SwiftTest.md).

## 3. Empacotar imagens, fontes e ícone sem asset catalog

**Decisão**: Recursos de tela declarados no SwiftPM e acessados por `Bundle.module`.
Fontes TTF completas registradas via Core Text no escopo do processo antes do primeiro
texto. Ícone no bundle principal por `iconPath: Resources/AppIcon.png` em `xtool.yml`;
metadados adicionais por `infoPath: Resources/Info.plist`. Produto e nome exibido Capia;
identificador inicial planejado `com.diuli.capia`, a confirmar no registro da assinatura.
Não inserir equipe, conta Apple ou credenciais na configuração versionada.

**Motivo**: O schema do xtool aceita `iconPath` PNG e o empacotador copia o ícone ao
bundle principal. Os bundles SwiftPM acompanham as dependências. Registrar fontes
por URL evita presumir que `UIAppFonts` no bundle principal resolva arquivos em outro bundle.
A confirmação final de fontes, ícone e metadados será feita no app instalado.

**Alternativas consideradas**: Asset catalog que exija ferramentas Xcode no Linux;
WOFF2 fragmentados do HTML; downloads em execução; tratar ícone como imagem comum do
bundle SwiftPM. Não atendem à mesma previsibilidade de empacotamento e execução offline.

**Fontes**: [Schema xtool.yml](https://github.com/xtool-org/xtool/blob/main/Sources/PackLib/PackSchema.swift),
[Packer](https://github.com/xtool-org/xtool/blob/main/Sources/PackLib/Packer.swift),
[recursos SwiftPM na Apple](https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package),
[registro Core Text](https://developer.apple.com/documentation/coretext/ctfontmanagerregisterfontsforurl(_:_:_:)).

## 4. Preservar os recursos e a composição do primeiro quadro

**Decisão**: Reutilizar `assets/onsen-wallpaper-1170x2532.png` como fundo. Extrair do
primeiro bundle do HTML o recurso WEBP `c98bf460-1310-48cf-b12a-570d347b97de` para a
capivara da welcome. Converter apenas seu formato para PNG se necessário ao carregamento,
sem recriar o desenho. O ícone parte de `assets/capybara-onsen.png`, conforme a spec.

**Motivo**: O fundo existente tem 1170 × 2532 e corresponde ao JPEG da referência com
diferenças de compressão. O mascote embutido mede 480 × 410; a imagem do ícone mede
1312 × 1199 e tem outro enquadramento. Substituir um pelo outro alteraria a composição.
A preparação será reproduzível, com verificação da origem e preservação do HTML.

**Alternativas consideradas**: Redesenhar a cena ou reutilizar a imagem do ícone em
todas as posições. O quadro já fornece o recurso que precisa ser preservado.

**Referência**: `design/App de finanças onsen — protótipo iPhone.html`, quadro
`d017ec14-a843-4b61-ab79-5bedc20a48eb`. A impressão SHA-256 observada do HTML UTF-8 foi
`ccf7cb799ad297d0a7765b5c943f9fc1d125f9c4dbdf65bcc0596321133bbdee`.

Para as outras poses da apresentação, reutilizar as imagens referenciadas pelo componente
Capivara do mesmo bundle. A preparação deve registrar a correspondência entre pose e
recurso. A folha de expressões em `assets/` é alternativa apenas se corresponder à pose
original, sem redesenho desnecessário.

## 5. Fontes locais e acessibilidade

**Decisão**: Figtree nos textos e controles; Zen Maru Gothic Bold nos títulos. Obter TTFs
completos nos repositórios oficiais, guardar a revisão de origem e as licenças OFL.
Escalar fontes em relação aos estilos semânticos. Reservar as áreas seguras e permitir
rolagem em alturas menores ou tamanhos de texto ampliados.

**Motivo**: O HTML contém apenas um WOFF2 de Figtree no primeiro bundle e depende de
URLs para Zen Maru Gothic. Isso não fornece, por si só, fontes nativas completas e offline.
A composição de 390 × 844 é a referência base; não pode congelar a acessibilidade.

**Alternativas consideradas**: Usar apenas fonte do sistema ou comprimir todo o layout
como uma imagem. Ambas prejudicam a referência ou a leitura acessível.

As animações consultam `accessibilityReduceMotion`. O foco assistivo muda para o título
da nova etapa; a mensagem da capivara é anunciada sem prender o foco. Decorações ficam
fora da árvore acessível. O ícone será PNG opaco 1024 × 1024, sem máscara arredondada
pré-aplicada, preservando rosto e toalha em tamanho de uso.

**Fontes**: [Figtree](https://github.com/google/fonts/tree/main/ofl/figtree),
[Zen Maru Gothic](https://github.com/google/fonts/tree/main/ofl/zenmarugothic),
[fontes customizadas e Dynamic Type](https://developer.apple.com/documentation/swiftui/applying-custom-fonts-to-text),
[redução de movimento](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion),
[foco acessível](https://developer.apple.com/documentation/swiftui/accessibilityfocusstate),
[ícones de apps](https://developer.apple.com/design/human-interface-guidelines/app-icons).

## 6. Navegação finita e feedback local

**Decisão**: Uma enumeração de tela com etapa válida e origem obrigatória para a entrada
provisória. Transições puras no pacote CapiaFlow; raiz SwiftUI com `@State`. Feedback de
1,9 segundo mantido localmente na welcome, com cancelamento em novos toques e ao sair.

**Motivo**: Reproduz os quatro estados originais e o destino provisório exigido pela
spec sem booleanos conflitantes, pilha duplicada ou sincronização remota.

**Alternativas consideradas**: Persistir conclusão, criar banco de dados ou implementar
cadastro junto da apresentação. Todas ampliam o escopo confirmado.

## Resultado da pesquisa

Não há decisão técnica em aberto para iniciar as tarefas. Compilação, assinatura do
bundle escolhido, instalação, inspeção visual e testes de aceitação são verificações
planejadas, não resultados obtidos nesta fase. Os links de código upstream apontam para
`main`; os comandos foram também conferidos na versão instalada do xtool.
