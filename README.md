<img src="assets/icon.svg" width="64" height="64" alt="">

# Capia

App nativo de finanças pessoais para iPhone, com uma capivara como mascote. Nome escolhido pelo usuário em 2026-11-06.

## Design e desenvolvimento

Todo desenvolvimento deve se basear no protótipo em [`design/`](design/). O HTML exportado do Claude é a referência para as telas e os fluxos. Abra o arquivo `.html` dessa pasta em um navegador para consultar o protótipo.

As instruções para os agentes estão em [AGENTS.md](AGENTS.md). A implementação usa Swift com SwiftUI. A primeira entrega será um protótipo navegável com dados de exemplo, conforme [o plano do protótipo](docs/prototipo.md).

## Estrutura atual

- `design/`: protótipo de referência exportado do Claude.
- `assets/`: imagens, ícone e prompts usados na exploração visual.
- [CONTEXT.md](CONTEXT.md): vocabulário financeiro do app.
- [docs/descoberta.md](docs/descoberta.md): decisões e questões de produto.
- [docs/prototipo.md](docs/prototipo.md): escopo e caminho técnico da primeira entrega.

## Estado do projeto

O repositório contém o design, os recursos visuais e a documentação. A implementação do app ainda não começou. O usuário confirmou a execução de um app padrão no iPhone em 2026-11-06, validando o caminho inicial com xtool. A primeira funcionalidade especificada é o [Get Started com ícone do app](specs/001-get-started/spec.md).

## Spec Kit

O Spec Kit está inicializado para o Codex, com scripts PowerShell. A configuração, os templates e o workflow estão em `.specify/`; as skills estão em `.agents/skills/`.

Em uma sessão do Codex que carregue as skills deste projeto, siga a sequência:

1. `$speckit-constitution`: manter os princípios registrados na [constituição](.specify/memory/constitution.md), a partir de `AGENTS.md` e das decisões existentes.
2. `$speckit-specify`: especificar a entrega com base em `design/` e na documentação do produto.
3. `$speckit-plan`: preparar o plano de implementação.
4. `$speckit-tasks`: gerar as tarefas.
5. `$speckit-implement`: executar as tarefas.
