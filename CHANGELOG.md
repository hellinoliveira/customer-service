# Customer Service Flow - Changelog

## [2026-01-05] - UX Simplification: Silent Attendant Handoff

### Summary
Simplified the flow to only show 2 bot messages: **Main Menu** and **Promo Groups**. Removed confusing "attendant will come" message.

### Changes
1. **Changed trigger:** "1" → Promo Groups (was "2")
2. **Silent handoff:** Any message except "1" → Attendant (no bot message)
3. **Clearer copy:** New main menu message is more direct

### New User Flow

```
User: [Any message/audio]
Bot:  Main Menu (with options)

User: "1"
Bot:  [Promo group links] → State cleared

User: [Anything else]
Bot:  [Silent] → State = ATTENDANT → Human takes over
```

### Main Menu Copy (New)
```
Olá, {name}! 👋

Seja bem-vindo à Pedalando Ali! 🚴‍♂️

Somos especialistas em encontrar as melhores ofertas para você.

🎯 Acesse nossos Grupos de Promoções
   Responda 1 para receber os links

💬 Precisa de Ajuda?
   Digite sua dúvida que um atendente irá responder
```

---

## [2026-01-05] - Bug Fix: Main Menu Loop

### Problem
Users who sent messages other than "1" or "2" while in MAIN_MENU would get stuck in a loop, repeatedly receiving the main menu message.

### Root Cause
The selection mapping logic left `final_selection` empty for unknown inputs, causing the Switch to fall into the `defaults` case which reset to MAIN_MENU, creating an infinite loop.

### Solution
Changed the logic so that **any message in MAIN_MENU except "2" goes to ATTENDANT mode**.

### Changes Made

#### 1. Flow Logic ([customer-service-flow.yaml:130-135](customer-service/kestra/customer-service-flow.yaml#L130-L135))

**Before:**
```python
if current_menu == 'MAIN_MENU':
    if msg == '1':
        final_selection = 'ATTENDANT'
    elif msg == '2':
        final_selection = 'PROMO_GROUPS'
    # Empty final_selection → defaults → loop
```

**After:**
```python
if current_menu == 'MAIN_MENU':
    if msg == '2':
        final_selection = 'PROMO_GROUPS'
    else:
        # Any message other than "2" goes to attendant
        final_selection = 'ATTENDANT'
```

#### 2. User-Facing Messages

Updated the main menu text to clarify the new behavior:

**Before:**
```
1️⃣ Falar com Atendente
   Tire dúvidas ou peça ajuda personalizada

2️⃣ Grupos de Promoções
   Receba ofertas exclusivas no WhatsApp

👇 Responda com o número da opção desejada.
```

**After:**
```
🔹 Grupos de Promoções
   Responda 2 para receber links dos grupos exclusivos

🔹 Falar com Atendente
   Qualquer outra mensagem te conecta com nosso time

👉 Digite 2 para grupos ou mande qualquer mensagem para falar conosco!
```

#### 3. Tests Updated

- [test_flow_logic.py](tests/test_flow_logic.py) - Added test for "any text except 2 → ATTENDANT"
- [test_flow_integration.py](tests/test_flow_integration.py) - Updated simulation logic
- [customer-service-flow.test.yaml](kestra/tests/customer-service-flow.test.yaml) - Updated test cases

### State Machine Behavior

| State | User Input | Next Action | Next State |
|-------|-----------|-------------|------------|
| NONE | Any | Show main menu | MAIN_MENU |
| MAIN_MENU | "2" | Send promo groups | (cleared) |
| MAIN_MENU | **Anything else** | Connect to attendant | ATTENDANT |
| ATTENDANT | Any | Skip (human handling) | ATTENDANT |

### Deployment

1. Update flow on Kestra:
   - Via UI: Upload updated `customer-service-flow.yaml`
   - Via API: `POST /api/v1/flows`
   - Via restart: `docker-compose restart kestra`

2. Test the fix:
   ```bash
   # User should NOT get stuck in loop anymore
   User: oi
   Bot: [Main Menu]

   User: help
   Bot: [Connects to attendant] ✓

   User: qualquer coisa
   Bot: [Connects to attendant] ✓

   User: 2
   Bot: [Shows promo groups] ✓
   ```

### Related Issues
- Fixes: Main menu infinite loop
- Improves: User experience (easier to reach attendant)
- Simplifies: State machine (fewer branches)
