# Pesquisa técnica: Configuração inicial do espaço

Pesquisa concluída em 2026-11-06, com inspeção do quadro "Configuração inicial" do HTML,
do código do Get Started e do SDK Darwin instalado no WSL. Nada foi compilado nesta fase.

## 1. Onde guardar o espaço configurado

**Decisão**: Documento JSON único, `Codable`, com `schemaVersion: 1`, em
`Application Support/Capia/space.json`, gravado com `Data.write(options: [.atomic,
.completeFileProtectionUntilFirstUserAuthentication])`. A leitura acontece uma vez na
abertura do app; a gravação, ao chegar à conclusão.

**Motivo**: O SDK cruzado usado pelo xtool traz `SwiftData.framework`, mas não o plugin
de macros `SwiftDataMacros`; os plugins disponíveis são apenas SwiftUI, Previews,
FoundationModels e Observation. Sem o plugin, `@Model` não expande. Um arquivo JSON usa só
Foundation, roda igual no Linux e no iPhone e pode ser testado com `swift test` em um
diretório temporário. O documento é pequeno e lido inteiro.

**Alternativas consideradas**: SwiftData (macro indisponível); Core Data com modelo
programático (verboso, sem ganho para um documento pequeno); `UserDefaults` (feito para
preferências, não para entidades do domínio); Keychain (inadequado para dados não secretos).

**Evidência**: busca em `~/.swiftpm/swift-sdks/darwin.artifactbundle`:
`OpenAppleMacrosPlugins/` contém `libFoundationModelsMacros.so`, `libPreviewsMacros.so` e
`libSwiftUIMacros.so`; o toolchain contém `libObservationMacros.dylib`; não há
`SwiftDataMacros`. SDK `epoch=4, darwinTools=1.1.0, oam=1.4.1`, iPhoneOS 27.3.

## 2. Caminho para o iCloud depois

**Decisão**: Não usar iCloud nesta entrega. Manter identificadores `UUID` estáveis e o
documento versionado, para permitir migração futura a CloudKit ou a um documento iCloud.

**Motivo**: Sincronização exige o entitlement iCloud, que depende do Apple Developer
Program pago, ainda não confirmado pelo usuário. Application Support entra no backup do
iCloud do aparelho por padrão; isso não é sincronização e não é prometido na interface.

**Alternativas consideradas**: `NSUbiquitousKeyValueStore` (limite de 1 MB e mesma
exigência de entitlement); CloudKit agora (fora do escopo decidido).

## 3. Dinheiro em centavos e formato brasileiro

**Decisão**: `Int64` de centavos, entre 0 e 99.999.999.999 (11 algarismos, como no design).
Formatação própria e determinística: `R$ 1.234,56`, ponto como separador de milhar,
vírgula decimal, espaço normal depois de `R$`. Atalhos rotulados `+ R$ 500`, `+ R$ 1.000`
e `+ R$ 2.500` (o design remove `,00`). Soma de atalho satura no limite.

**Motivo**: `FormatStyle` e `NumberFormatter` dependem dos dados de localidade, que diferem
entre Foundation do Linux e do iOS (por exemplo, espaço inseparável). A spec exige o mesmo
valor do início ao fim, sem arredondamento (SC-004). `Double` é rejeitado.

**Entrada do saldo**: `TextField` com teclado `.numberPad` ligado ao texto formatado. A
cada mudança, extrair os algarismos, descartar zeros à esquerda, limitar a 11 e recalcular
os centavos. Apagar remove o último algarismo, como no design.

## 4. Fluxo e estado

**Decisão**: `SetupFlow` puro em `CapiaFlow`, com enumeração `SetupStep` e um rascunho
(`SetupDraft`). Ações de navegação carregam a etapa de origem, como no Get Started, para
ignorar toques antigos. Edições de campo são métodos diretos que não mudam a etapa.
A validade de Continuar e o humor da capivara são derivados, não armazenados.

**Motivo**: Reaproveita o padrão validado no Get Started (origem obrigatória, ações
incompatíveis sem efeito, sem pilha), cobre FR-005 e FR-013 em testes no Linux e evita
booleanos de tela conflitantes como `s0`…`s5` do HTML.

**Raiz do app**: `AppRootView` lê o `SpaceStore` uma vez. Com espaço guardado, abre o
destino provisório de "Ver meu mês"; sem espaço, abre o Get Started. `GetStartedScreen`
troca `configurationEntry(origin:)` por `setup(origin:)`.

## 5. Recursos visuais

**Decisão**: Reutilizar `ThinkingCapybara`, `HappyCapybara` e `CelebratingCapybara`.
Preparar `CalmCapybara.png` da célula (0, 0) da folha `assets/capybara-expressions-sheet-3x2.png`
(ordem documentada no prompt: calma, feliz, pensando, ouvindo, comemora, surpresa), pelo
mesmo método de recorte usado no Get Started, e registrar origem e hash em `SOURCES.md`.

**Motivo**: O componente Capivara do HTML aceita os humores `calma`, `feliz`, `pensando`,
`ouvindo`, `comemora` e `surpresa`, com padrão `calma`; os blobs dessas poses não estão
embutidos no HTML exportado, como já registrado no Get Started.

**Ícones das opções**: os traços SVG do quadro (banco, cofrinho, carteira, cartão, círculo
com traço) serão desenhados como `Path`/`Shape` SwiftUI a partir dos mesmos comandos, em
vez de SF Symbols, para preservar o desenho da referência. Sem imagens novas.

## 6. Teclado, foco e acessibilidade

**Decisão**: Ação Continuar em `safeAreaInset(edge: .bottom)`, que acompanha o teclado.
Foco automático no campo de texto ao entrar nas etapas de nome, conta e saldo; `submitLabel`
"Continuar" e `onSubmit` avançando só com etapa válida. Ação indisponível usa
`.disabled` visualmente com as cores do design (`#DDD3C4`/`#6B6258`) e é anunciada como
indisponível. Opções com `.isSelected`; barra de progresso como valor "Etapa N de 6";
balão da dica lido como texto; confete oculto à leitura assistiva e omitido com
redução de movimento. Dias em `ScrollView(.horizontal)` com rótulos "Dia N".

**Motivo**: Cumpre FR-015, FR-017 e FR-018 com componentes nativos, mantendo a aparência.
O nome usa `.textContentType(.givenName)`, `.textInputAutocapitalization(.words)` e
`.autocorrectionDisabled()`, como os atributos do HTML.

## 7. Falha ao gravar

**Decisão**: Se a gravação falhar, a conclusão continua exibida com o espaço da sessão e
um aviso discreto: "Não consegui guardar no aparelho. Seus dados ficam só até fechar o app."
com "Tentar de novo". Arquivo ilegível ou de versão desconhecida na abertura: tratar como
ausente (abrir boas-vindas) e não apagar o arquivo até uma nova gravação bem-sucedida.

**Motivo**: Evita perder dados em silêncio e evita encerramento inesperado. Estado
complementar ao design, registrado no contrato.

## Resultado da pesquisa

Não há decisão técnica em aberto. Compilação, instalação e percursos no iPhone são
verificações planejadas, não resultados desta fase.
