# Pedalando Ali - Copywriting Guide

## Tom de Voz

- **Personalidade**: Amigável, eficiente, prestativo
- **Linguagem**: Informal mas profissional (você, não tu/senhor)
- **Emojis**: Usar com moderação, apenas para dar personalidade
- **Objetivo**: Customer Obsessed - resolver rápido, sem enrolação

---

## Mensagens do Bot

### 1. Saudação + Menu Principal

```
Olá, {nome}! 👋

Seja muito bem-vindo(a) à Pedalando Ali! 🚴‍♂️

Somos especialistas em encontrar as melhores ofertas para você. Como posso te ajudar hoje?
```

**Botão**: "Ver Opções"
**Rodapé**: "Pedalando Ali - Seu caçador de ofertas"

**Opções do Menu**:
| ID | Título | Descrição |
|---|---|---|
| ATTENDANT | 💬 Falar com Atendente | Tire dúvidas ou peça ajuda personalizada |
| PROMO_GROUPS | 🔥 Grupos de Promoções | Receba ofertas exclusivas no WhatsApp |

---

### 2. Resposta "Falar com Atendente"

#### Para o Cliente:
```
Perfeito, {nome}! 🙌

Já avisei nosso time e em breve alguém vai te chamar por aqui mesmo.

Enquanto isso, que tal dar uma olhada no nosso catálogo? Tem muita coisa boa! 👇

🛒 *Catálogo:* https://pedalandoali.com.br/catalogo

Se precisar de algo mais, é só mandar um "oi" que a gente recomeça! 😉
```

#### Notificação Interna (Atendente):
```
🔔 *Nova Solicitação de Atendimento*

👤 *Cliente:* {nome}
📱 *Telefone:* {telefone}
⏰ *Horário:* {horario}

_Responda diretamente ao cliente pelo número acima._
```

---

### 3. Menu de Nichos (Grupos de Promoções)

```
Massa! 🎯

Temos grupos exclusivos para cada estilo. Escolha o seu e receba as melhores ofertas direto no WhatsApp:
```

**Botão**: "Ver Nichos"
**Rodapé**: "Escolha quantos quiser!"

**Opções**:
| ID | Título | Descrição |
|---|---|---|
| NICHE_CYCLING | 🚴 Ciclismo | Bikes, peças, acessórios e vestuário |
| NICHE_HOME | 🏠 Casa | Decoração, eletroportáteis e utilidades |
| NICHE_FASHION | 👗 Moda e Beleza | Roupas, calçados e cosméticos |
| NICHE_AUTOMOTIVE | 🚗 Automotivo | Acessórios, peças e ferramentas |
| NICHE_RUNNING | 🏃 Corrida e Fitness | Tênis, roupas e equipamentos |

---

### 4. Respostas por Nicho

#### Ciclismo
```
🚴 *Grupo de Ciclismo*

Excelente escolha! Aqui você vai encontrar ofertas de bikes, peças, acessórios e tudo para pedalar.

👉 *Entre no grupo:*
{LINK_CYCLING}

_Quer entrar em outro grupo também? Manda um "oi" que mostro as opções!_
```

#### Casa
```
🏠 *Grupo de Casa*

Ótima escolha! Aqui postamos ofertas de decoração, eletroportáteis, utilidades domésticas e muito mais.

👉 *Entre no grupo:*
{LINK_HOME}

_Quer entrar em outro grupo também? Manda um "oi" que mostro as opções!_
```

#### Moda e Beleza
```
👗 *Grupo de Moda e Beleza*

Arrasou na escolha! Aqui você encontra ofertas de roupas, calçados, cosméticos e acessórios.

👉 *Entre no grupo:*
{LINK_FASHION}

_Quer entrar em outro grupo também? Manda um "oi" que mostro as opções!_
```

#### Automotivo
```
🚗 *Grupo Automotivo*

Mandou bem! Aqui postamos ofertas de acessórios para carro, peças, ferramentas e muito mais.

👉 *Entre no grupo:*
{LINK_AUTOMOTIVE}

_Quer entrar em outro grupo também? Manda um "oi" que mostro as opções!_
```

#### Corrida e Fitness
```
🏃 *Grupo de Corrida e Fitness*

Boa escolha, atleta! Aqui você encontra ofertas de tênis, roupas esportivas e equipamentos de treino.

👉 *Entre no grupo:*
{LINK_RUNNING}

_Quer entrar em outro grupo também? Manda um "oi" que mostro as opções!_
```

---

## Variáveis Disponíveis

| Variável | Descrição | Exemplo |
|---|---|---|
| `{nome}` | Nome do contato (pushName) | João |
| `{telefone}` | Número do telefone | 5562999999999 |
| `{horario}` | Timestamp da mensagem | 2024-01-15 14:30 |
| `{LINK_*}` | Links dos grupos | https://chat.whatsapp.com/... |

---

## Notas de Implementação

1. **Personalização**: Sempre usar o nome do cliente quando disponível
2. **Fallback**: Se nome não disponível, usar "Cliente"
3. **Emojis**: Manter consistência - não exagerar
4. **Links**: Sempre em negrito (*) para destacar
5. **CTA Final**: Sempre indicar como recomeçar o fluxo ("manda um oi")
