# Changelog

## 0.2.1 — 2026-10-25

- Shorten macro names to LCF, LCD, LCH and LCM.
- Rename unchanged, plugin-generated account macros in place through the game's EditMacro API.
- Re-find macros after each rename because names determine their sorted indices.
- Disable leftover generated old-name macros when an in-place migration cannot complete, and prompt the user to use the new macros.
- Preserve custom macros and name conflicts; disable generated early character macros in favor of the current account-wide macros.
- Remove unchanged generated LC_Buff macros from both account and current-character scope out of combat.

## 0.2.0 — 2026-10-25

- Retain four account-wide macros: LC_Food, LC_Drink, LC_Heal and LC_Mana.
- Remove LC_Buff selection, attribute checks and the old buff-food ID exceptions.
- Leave foods with recognized eating-buff clauses for manual use, including foods granting Intellect, spell power or attack power.
- Remove unchanged, plugin-generated legacy LC_Buff macros out of combat; preserve custom macros.
- Set the author to Ballyh (B站八厉害) and release the code under MIT.
