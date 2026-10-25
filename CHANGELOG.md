# Changelog

## 0.2.3 — 2026-10-25

- Delete generated old-name recovery macros instead of leaving disabled entries in the macro list.
- Reconnect their action-bar buttons to LCF, LCD, LCH and LCM; keep existing short macros and custom macro content.
- Wait until combat ends and the cursor is empty before migrating macros and action buttons.

- 自动删除旧版生成的恢复宏，避免宏列表中残留无法使用的旧宏。
- 将旧恢复宏的技能栏按钮接续到 LCF、LCD、LCH、LCM，保留已有短宏和用户自定义内容。
- 在脱战且鼠标未拖动物品时执行迁移与清理。

## 0.2.2 — 2026-10-25

- Fix old generated macros being missed after the game saves a trailing newline or platform-specific line endings.
- Apply the same normalization when updating short macros, avoiding repeated edits and false custom-macro conflicts.
- If short macros already exist, disable old generated recovery macros and remove generated LC_Buff macros; preserve custom edits.

- 修复游戏保存后的末尾换行或不同平台换行格式导致旧宏未被识别、迁移和清理的问题。
- 新旧宏已共存时，停用旧恢复宏并删除插件生成的 LC_Buff；保留用户自定义内容。

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
