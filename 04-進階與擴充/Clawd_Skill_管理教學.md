# 📘 Clawd 技能（Skill）安裝與管理教學 SOP

適用於：Clawd / ClawdBot / Claude Code Orchestrator

---

## 🧠 一、Clawd 技能是什麼？

Clawd 的「技能（Skill）」就是擴充功能模組，  
所有技能都存放在：

```
~/clawd/skills
```

每一個資料夾 = 一個技能。

---

## 📁 二、查看目前已安裝技能

在終端機執行：

```bash
ls ~/clawd/skills
```

---

## ⬇️ 三、從 ClawdHub 安裝新技能

```bash
npx clawdhub install 技能名稱
npx clawdhub sync
```

---

## ▶️ 四、啟動 Clawd

```bash
npx clawd
```

---

## 📂 五、打開技能資料夾

```bash
open ~/clawd/skills
```

---

## 🗑 六、移除技能

```bash
rm -rf ~/clawd/skills/技能名稱
npx clawdhub sync
```

---

## ❗ 常見錯誤

```bash
npx clawdhub login
```
