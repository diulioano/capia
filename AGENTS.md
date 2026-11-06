# Instruções para desenvolvimento

Estas instruções se aplicam a todo o repositório.

## Referência de design

- Baseie todo desenvolvimento na pasta `design/`. A referência atual é `design/App de finanças onsen — protótipo iPhone.html`, exportada do Claude.
- Antes de implementar ou alterar uma tela, consulte o protótipo e identifique o fluxo correspondente. Preserve sua composição, cores, tipografia, espaçamentos, componentes, mascote e comportamento das interações.
- Adapte o design aos componentes nativos do iOS e à acessibilidade, incluindo redução de movimento. Confira o resultado com a referência ao concluir uma tela.
- Para fluxos ou estados ausentes do protótipo, siga o mesmo sistema visual e as regras de produto documentadas. Registre as decisões que precisarem complementar o design.
- Preserve o HTML original e os avisos de licença incorporados. Atualize a referência quando o usuário fornecer uma nova versão do design.
- O nome do produto é Capia, escolhido pelo usuário em 2026-11-06. Use esse nome na identificação do app. O nome da pasta, o título do HTML e os textos anteriores do protótipo não substituem essa escolha. Preserve o HTML original.

## Produto e implementação

- Leia `CONTEXT.md`, `docs/descoberta.md` e `docs/prototipo.md` antes de desenvolver funcionalidades.
- Desenvolva o app nativo para iPhone em Swift com SwiftUI. O HTML em `design/` é a referência de interface; ele não altera a tecnologia escolhida.
- A primeira entrega é um protótipo navegável com dados de exemplo e sem backend. Valide a compilação e a instalação de um app mínimo pelo xtool antes de construir as telas.
- Se houver necessidade de backend próprio, a tecnologia escolhida é Java com Spring Boot.
- Use os recursos existentes em `assets/` quando corresponderem ao design. Mantenha as distinções financeiras definidas em `CONTEXT.md`.
- Uma instrução posterior do usuário prevalece sobre estas orientações. Atualize a documentação afetada quando uma decisão mudar.
