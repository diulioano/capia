# Validar a configuração inicial do Capia

Guia de validação da funcionalidade 002. O ambiente, a conexão do iPhone e a instalação
são os mesmos do Get Started; consulte `specs/001-get-started/quickstart.md` para preparar
o WSL, o `USBMUXD_SOCKET_ADDRESS` e o pareamento. Registre resultados em `validation.md`.

## Preparar recursos

No PowerShell, na raiz do repositório:

```powershell
python scripts/prepare-design-assets.py
python scripts/prepare-design-assets.py --check
```

Esperado: código zero e `CalmCapybara.png` presente com origem e hash em
`ios/Capia/Sources/Capia/Resources/SOURCES.md`, além dos recursos do Get Started.

## Testar o comportamento e compilar

No Bash do Ubuntu, na raiz do repositório:

```bash
swift test --package-path ios/CapiaFlow
cd ios/Capia && xtool dev build
```

Esperado: todos os testes de [data-model.md](data-model.md) passam (Get Started, centavos,
fluxo e gravação); o `.app` é gerado sem erros. Anote o caminho real.

## Instalar

```bash
cd ios/Capia
USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015 xtool dev run --usb
```

Gerar pacote não comprova instalação. Nunca versionar credenciais de assinatura.
Para começar do zero, remova o Capia do iPhone antes de instalar: reinstalar por cima
mantém o espaço guardado.

## Percursos de aceitação

Execute sem rede. Compare com o quadro "Configuração inicial" e com
[o contrato](contracts/initial-setup-ui.md).

| Percurso | Ações | Resultado esperado |
|----------|-------|--------------------|
| Entrada | Pular em cada etapa da apresentação; Voltar | Etapa 1 de 6; Voltar retorna à etapa de origem |
| Nome | Vazio, "D", " Diuli Vargas " | Continuar inativo, "Só mais uma letrinha.", depois ativo; título seguinte "Diuli, o que te trouxe aqui?" |
| Objetivos | Marcar e desmarcar | Estado visível e anunciado; Continuar só com um marcado |
| Conta | Corrente vazio, "B", "Banco Aurora"; Carteira vazio | Inativo, inativo, ativo; Carteira avança e vira "Carteira" |
| Saldo | Digitar 123456; apagar; atalhos | R$ 1.234,56; R$ 123,45; somas exatas; zero avança |
| Sem cartão | "Agora não", Continuar | Conclusão sem datas; "Sem cartão por enquanto." |
| Com cartão | "Sim", dias 3/10, depois 10/10, depois 5/12 | Aviso verde; erro e Continuar inativo; conclusão com "Fecha dia 5 · vence dia 12" e "Separado" |
| Voltar | Voltar de cada etapa e da conclusão | Valores preservados; sem contas duplicadas ao avançar de novo |
| Outra conta | "Adicionar outra conta", Poupança "Banco Aurora", sem cartão | Resumo com as duas contas e o cartão anterior |
| Cancelar outra conta | "Adicionar outra conta", Voltar | Volta à conclusão, sem mudanças |
| Ver meu mês | Acionar e "Voltar ao resumo" | Destino provisório; retorno ao mesmo resumo |
| Reabertura | Encerrar o app na conclusão e reabrir | Destino do mês; resumo idêntico, mesmos centavos |
| Interrupção | Remover o app, reinstalar, sair na etapa 4, reabrir | Boas-vindas, sem dados parciais |
| Toques rápidos | Continuar repetido durante a troca | Sem salto de etapa ou item duplicado |

Registre o tempo de uma conclusão com conta e cartão (SC-001, até dois minutos).

## Acessibilidade e composição

1. VoiceOver: percorra tudo; confira progresso "etapa N de 6", estado selecionado, ação
   indisponível, foco no título e resumo lido item a item.
2. Reduzir Movimento: sem confete, tremor ou transições; tudo alcançável sem espera.
3. Maior tamanho de texto: conteúdo, dias e Continuar alcançáveis, sem sobreposição.
4. Teclado aberto: campo e Continuar visíveis em nome, conta e saldo.
5. Compare cada etapa e a conclusão com o HTML no tamanho base e no aparelho; registre
   adaptações (área segura, Voltar na conclusão, destino provisório, aviso de gravação).

## Registrar a evidência

`specs/002-initial-setup/validation.md`: data, revisão, versões, comandos, resultado de
cada percurso como passou, falhou ou pendente, com motivo. Não marcar como concluído o
que não foi observado no aparelho.
