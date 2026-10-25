# Leveling Consumables

[English](#english) · [简体中文](#简体中文)

## English

**Keep food, drinks, and potions on the same four buttons as you level.**

As you level, food, drinks, and potions keep changing. Leveling Consumables updates four dedicated macros to match your level and the supplies in your bags, saving you from repeatedly replacing items on your action bars or using them from your inventory.

**Tested and working in WoW Forever Beta.**

### Set up once, keep using

Open `/macro`, find these account-wide macros, and drag them onto each character's action bar once:

| Macro | Use |
|---|---|
| `LCF` | Food |
| `LCD` | Drinks |
| `LCH` | Healing potions |
| `LCM` | Mana potions |

The selected items update when your supplies run out, your bags change, you level up, or you switch characters. Keep using the same familiar buttons.

- **Use lower tiers first.** Within the same tier, prioritizes items you have fewer of in your bags.
- **See your current item at a glance.** Icons and tooltips follow the selected consumable.
- **Choose buff food yourself.** Foods with recognized eating-buff effects are excluded from the recovery macros.
- **Keep your macros stable in combat.** Bag changes are applied after combat ends.

No configuration is needed for everyday use. Type `/lc` for optional commands. Automatic food and drink detection supports English and Simplified Chinese item tooltips.

When upgrading, the addon handles old generated macros and removes obsolete buff-food macros. A chat message lets you know if anything needs your attention.

## 简体中文

**四个宏放进技能栏，升级路上少换图标、少翻背包。**

升级途中，食物、饮料和药水会一档档更换。Leveling Consumables 帮你省去反复拖动消耗品、打开背包寻找物品的操作：把四个宏放到熟悉的技能栏位置，插件就会根据角色等级和背包物品，自动更新可用的恢复消耗品。

**已在 WoW Forever Beta 中完成实际测试，可正常使用。**

### 放一次，持续用

进入游戏后，在 `/macro` 的“通用宏”栏找到以下四个宏，每个角色按需拖到技能栏一次即可：

| 宏 | 用途 |
|---|---|
| `LCF` | 食物 |
| `LCD` | 饮料 |
| `LCH` | 治疗药水 |
| `LCM` | 法力药水 |

背包里的物品用完、角色升级或切换角色后，宏会自动更新，你继续使用原来的按键就好。

- **先用低等级恢复品。** 同档物品优先消耗背包总数量较少的那种，减少零散物品。
- **图标和提示跟随物品更新。** 鼠标移到技能栏，即可查看当前会使用的消耗品。
- **增益食物留给你自己选。** 普通恢复宏会排除识别到的进食增益食物，方便你按职业和需求选择属性加成。
- **战斗中保持稳定。** 战斗期间的背包变化会在脱战后更新。

日常使用无需配置；输入 `/lc` 可查看可选命令。食物和饮料的自动识别支持简体中文与英文物品提示。

从旧版升级时，插件会自动处理旧宏并清理遗留的增益食物宏；遇到需要手动处理的情况，会在聊天栏提示。

---

**Author / 作者：Ballyh (B站八厉害)** · [MIT License / 开源许可](LICENSE)
