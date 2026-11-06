<img src="ios/Capia/Resources/AppIcon.png" width="64" height="64" alt="Ícone do Capia">

# Capia

App nativo de finanças pessoais para iPhone, com uma capivara como mascote. Nome escolhido pelo usuário em 2026-11-06.

## Design e desenvolvimento

Todo desenvolvimento deve se basear no protótipo em [`design/`](design/). O HTML exportado do Claude é a referência para as telas e os fluxos. Abra o arquivo `.html` dessa pasta em um navegador para consultar o protótipo.

As instruções para os agentes estão em [AGENTS.md](AGENTS.md). A implementação usa Swift com SwiftUI. A primeira entrega será um protótipo navegável com dados de exemplo, conforme [o plano do protótipo](docs/prototipo.md).

## Estrutura atual

- `design/`: protótipo de referência exportado do Claude.
- `assets/`: imagens, ícone e prompts usados na exploração visual.
- `ios/Capia/`: app SwiftUI e configuração do xtool.
- `ios/CapiaFlow/`: navegação pura e testes XCTest.
- `scripts/`: preparação e conferência reproduzível dos recursos.
- [CONTEXT.md](CONTEXT.md): vocabulário financeiro do app.
- [docs/descoberta.md](docs/descoberta.md): decisões e questões de produto.
- [docs/prototipo.md](docs/prototipo.md): escopo e caminho técnico da primeira entrega.

## Estado do projeto

O Get Started está concluído e validado no iPhone na build 5: boas-vindas com carinho na capivara, três introduções, entrada provisória da configuração e ícone próprio. O app funciona sem rede e mantém o estado somente durante a sessão. Cadastro, contas e demais fluxos financeiros continuam fora desta funcionalidade.

Consulte os [comandos de preparação, teste e instalação](specs/001-get-started/quickstart.md) e o [registro de validação](specs/001-get-started/validation.md). Compilação e seis testes automatizados passaram; os percursos nativos foram aprovados pelo usuário, incluindo texto ampliado, VoiceOver, redução de movimento, uso sem rede, ícone e reabertura.

## Spec Kit

O Spec Kit está inicializado para o Codex, com scripts PowerShell. A configuração, os templates e o workflow estão em `.specify/`; as skills estão em `.agents/skills/`.

Em uma sessão do Codex que carregue as skills deste projeto, siga a sequência:

1. `$speckit-constitution`: manter os princípios registrados na [constituição](.specify/memory/constitution.md), a partir de `AGENTS.md` e das decisões existentes.
2. `$speckit-specify`: especificar a entrega com base em `design/` e na documentação do produto.
3. `$speckit-plan`: preparar o plano de implementação.
4. `$speckit-tasks`: gerar as tarefas.
5. `$speckit-implement`: executar as tarefas.
