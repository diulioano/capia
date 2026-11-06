# Validar o Get Started do Capia

US1 aceita no iPhone na build 3, com os relatos de validação registrados. A build 4
implementa as três introduções e a entrada provisória da configuração; os testes de
navegação passaram e seu aceite no aparelho está pendente. O ícone final ainda não existe.
Consulte [validation.md](validation.md) antes de executar os cenários de aceite final.

## Preparar o ambiente

Use a distribuição Ubuntu no WSL. Ela já tem Swift 6.4.2, xtool 1.24.0 e SDK Darwin.
O teste do app padrão no iPhone já foi confirmado pelo usuário e não precisa ser repetido.
Para instalar o Capia, mantenha o iPhone desbloqueado, com pareamento, modo de
desenvolvimento e assinatura configurados. Nesta máquina, o caminho validado usa
Apple Devices no Windows e sua porta local 27015, acessível pelo WSL em modo mirrored.
O encaminhamento direto por usbipd falhou durante a transferência, mesmo listando o aparelho.

No PowerShell, entre no Bash:

```powershell
wsl -d Ubuntu -- bash -l
```

Dentro do Bash, confira o ambiente e a conexão:

```bash
cd /mnt/c/Users/Diuli/.t3/projects/i-dont-the-name-yet
export USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015
swift --version
xtool --version
xtool sdk status
xtool devices --no-wait
```

Se nenhum aparelho aparecer, a compilação e os testes de estado podem continuar;
a validação de instalação deve ficar pendente até conectar o aparelho. Não registrar
sucesso de instalação a partir da geração de um pacote.

Se o aparelho estiver associado ao usbipd com `Shared (forced)`, libere-o no PowerShell
como administrador com `usbipd unbind --busid <BUSID-do-iPhone>`. Consulte `usbipd list`
para obter o BUSID atual. Depois confira `xtool devices --no-wait` com a variável acima.
O socket local existente foi suficiente nesta máquina, sem configurar encaminhamento
de portas ou regras de firewall. Outros modos de rede WSL precisam de configuração própria.
Referência: [issue do xtool sobre a etapa Connecting](https://github.com/xtool-org/xtool/issues/19).

## Preparar e conferir os recursos

O script `scripts/prepare-design-assets.py` prepara os recursos US1 e US2 e oferece `--check`
para verificar presença, dimensões, licenças e correspondência dos recursos sem escrita
nem rede. Instale as dependências Python no Windows. Para regenerar recursos, o modo
sem argumentos baixa fontes da revisão oficial fixada e preserva `design/`.

No PowerShell, a partir da raiz do repositório:

```powershell
python -m pip install -r scripts/requirements-design-assets.txt
python scripts/prepare-design-assets.py
python scripts/prepare-design-assets.py --check
```

O resultado esperado é código de saída zero e nenhum recurso obrigatório ausente.
Neste estágio, confira o mascote extraído do HTML, as três poses preparadas da folha
de expressões (os blobs dessas poses não estão embutidos no HTML), o fundo existente, as fontes TTF
completas e seus avisos OFL. A ferramenta registra caminhos, hashes e origem em
`ios/Capia/Sources/Capia/Resources/SOURCES.md`. O ícone opaco 1024 × 1024 e os recursos
finais serão exigidos pelo modo de conferência quando a US3 for implementada.

## Testar as transições e compilar

No Bash, na raiz do repositório:

```bash
swift test --package-path ios/CapiaFlow
cd ios/Capia
xtool dev build
```

Resultados esperados: todos os testes de [data-model.md](data-model.md) passam;
o xtool gera o `.app` sem falhas de Swift ou recursos. Anote o caminho real informado
pelo build. Inspecione o pacote gerado: produto Capia, identificador configurado,
ícone no bundle principal e bundle SwiftPM com imagens e fontes.

A compilação inicial do esqueleto deve ser feita antes do acabamento das telas.
A compilação final repete esse passo após a implementação completa do fluxo.

## Instalar no iPhone

Ainda em `ios/Capia`, com o aparelho disponível:

```bash
USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015 xtool dev run --usb
```

Se for necessário um arquivo para instalação separada:

```bash
xtool dev build --sign --ipa
```

O segundo comando produz um IPA assinado; não comprova instalação. Use o caminho
real produzido com `xtool install` apenas quando optar pela instalação separada.
Nunca registre conta Apple, senha, token, certificado ou perfil de assinatura no Git.

Resultado final esperado após US3: Capia aparece na tela inicial, com o ícone da capivara.
Na US1 atual, o ícone final ainda não existe. Abra o app
pelo ícone e confirme as boas-vindas. Registre modelo do aparelho, versão do iOS,
identificador do bundle e versão do build. O alvo mínimo planejado é iOS 17.

## Executar os percursos de aceitação

Execute com rede indisponível durante o uso. Confronte as telas com o primeiro quadro
do HTML original e com [o contrato de interface](contracts/get-started-ui.md).

| Percurso | Ações | Resultado esperado |
|----------|-------|--------------------|
| Boas-vindas | Abrir, ler, tocar capivara, esperar | Proposta e Começar visíveis; mensagem aparece e some após aproximadamente 1,9 segundo |
| Renovação do carinho | Tocar, esperar cerca de um segundo, tocar novamente | Um único balão permanece pelo novo intervalo; tarefa antiga não o esconde |
| Saída durante carinho | Tocar e imediatamente Começar; voltar | Apresentação abre sem espera; welcome volta sem mensagem antiga |
| Apresentação completa | Começar, Continuar, Continuar | Registro, resumo, metas; progresso Etapa 1, 2 e 3 de 3 |
| Retornos | Voltar de cada etapa | Retorna à etapa anterior; da primeira volta às boas-vindas |
| Pular | Em cada uma das três etapas, Pular e Voltar à apresentação | Entrada provisória única; retorno à etapa de origem correta |
| Final da apresentação | Configurar meu espaço e Voltar à apresentação | Mesmo destino de Pular; retorno a metas |
| Toques rápidos | Acionar repetidamente a mesma ação durante a mudança | Sem tela duplicada, origem perdida ou salto provocado por eventos antigos |
| Nova execução | Encerrar o processo e reabrir pelo ícone | Boas-vindas novamente; sem conclusão persistida |
| Offline | Percorrer o conjunto sem rede | Mesmos conteúdos, imagens e fontes, sem pedido de login ou permissões |

Registre se uma pessoa consegue identificar a proposta e começar em até 15 segundos
e percorrer a apresentação em até um minuto, conforme SC-001 e SC-002. Esses tempos são
critérios de aceitação para a sessão observada, não uma estimativa de desempenho geral.

## Conferir acessibilidade e composição

1. Ative VoiceOver e percorra boas-vindas, três apresentações e entrada provisória.
   Confira o foco no título ao trocar de tela, nomes de ações e progresso anunciado
   uma única vez. Toque na capivara e confira o anúncio do feedback.
2. Ative Reduzir Movimento. Repita o percurso e confirme cena estática, gráficos já
   preenchidos e todas as ações disponíveis sem espera.
3. Use o maior tamanho de texto de acessibilidade no aparelho. Confirme que todo o
   conteúdo e as ações continuam alcançáveis por rolagem, sem truncamento ou sobreposição.
4. Compare composição e poses com o HTML no tamanho base 390 × 844 e na dimensão real
   do aparelho. Registre adaptações de área segura e texto ampliado.
5. Confira o ícone em tamanho normal na tela inicial. Rosto e toalha devem permanecer
   reconhecíveis, com nome Capia e sem bordas transparentes ou máscara duplicada.

A geometria 390 × 844 pode ser conferida em preview nativo quando disponível. Em Windows
sem preview nativo, registre a diferença de tamanho do aparelho e a inspeção correspondente;
uma captura do HTML não substitui a validação da tela SwiftUI.

## Registrar a evidência real

Na implementação, criar `specs/001-get-started/validation.md` com data, revisão testada,
versões efetivas, comandos, resultados dos percursos e capturas nativas quando disponíveis.
Cada verificação deve constar como passou, falhou ou pendente, com motivo. Identificar
adaptações visuais, sem marcar como concluído o que não foi observado no aparelho.

## Estado no fim do planejamento

Ferramentas e SDK conferidos em 2026-11-06; relato do app padrão preservado. Testes,
compilação do Capia, assinatura deste bundle, instalação e percursos acima ainda não
executados. Nenhum hook de planejamento está configurado em `.specify/extensions.yml`.
