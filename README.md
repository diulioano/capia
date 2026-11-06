<img src="assets/icon.svg" width="64" height="64" alt="">

# App de finanças pessoais

App nativo para iPhone, com uma capivara como mascote. O nome do produto ainda é provisório.

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

O repositório contém o design, os recursos visuais e a documentação. A implementação do app ainda não começou. O próximo passo técnico é validar a compilação e a instalação de um app mínimo no iPhone pelo xtool, a partir do Windows.
