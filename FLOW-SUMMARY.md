# Customer Service Flow - Summary

## Current Behavior (After Simplification)

### Bot Messages (Only 2!)

1. **Main Menu** - Shown to new users or on reset
2. **Promo Groups** - Links to all WhatsApp groups

**That's it!** No "waiting for attendant" or "catalog" messages.

---

## User Journeys

### Journey 1: Want Promo Groups
```
User: "oi"
Bot:  [Main Menu]

User: "1"
Bot:  [All group links]
      State = CLEARED
```

### Journey 2: Want Human Help (Silent Handoff)
```
User: "oi"
Bot:  [Main Menu]

User: "preciso de ajuda"  (or ANY text except "1")
Bot:  [SILENT - no message]
      State = ATTENDANT (24h TTL)

→ Human attendant takes over
→ User can send messages/audio freely
→ Bot stays silent for 24 hours
```

### Journey 3: Already in Attendant Mode
```
User: [Any message]
Bot:  [SILENT]
      State remains ATTENDANT

→ All messages go to human
→ Bot never interrupts
```

---

## State Machine

| Current State | User Input | Bot Action | Next State |
|---------------|-----------|------------|------------|
| NONE | Any | Send main menu | MAIN_MENU |
| MAIN_MENU | "1" | Send promo groups | (cleared) |
| MAIN_MENU | Anything else | **Silent** | ATTENDANT |
| ATTENDANT | Any | **Silent** | ATTENDANT |

---

## Technical Details

### Redis State
```json
{
  "current_menu": "MAIN_MENU" | "ATTENDANT",
  "push_name": "User Name",
  "last_interaction": "2026-01-05T12:00:00"
}
```

### TTL Values
- Normal state: **30 minutes** (1800s)
- ATTENDANT state: **24 hours** (86400s)

### Kestra Switch Cases
```
NONE_ → Send main menu
MAIN_MENU_PROMO_GROUPS → Send groups + clear state
MAIN_MENU_ATTENDANT → Set ATTENDANT state (no message)
defaults → Send main menu (reset)
```

---

## Why This Design?

### ✅ Advantages
1. **Less confusing** - No "wait for attendant" message that confuses users
2. **Natural flow** - Users just type their question and get help
3. **Fewer messages** - Only 2 bot messages in total
4. **Simple choice** - "Want groups? Type 1. Want help? Just ask."

### 🎯 User Psychology
- Most users will naturally type their question
- "1" is an easy escape hatch for promo groups
- Silence = human is handling it (expected behavior)

---

## Testing

Run tests:
```bash
cd customer-service/tests
pytest test_flow_logic.py -v
```

Test manually:
```
1. Send "oi" → Should get main menu
2. Send "help" → Should get NO response (attendant mode)
3. Send "1" → Should get promo groups
```
