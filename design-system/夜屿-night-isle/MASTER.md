# 夜屿 Night Isle — UI 决策源（UI UX Pro Max）

> **唯一依据**：本文件只收录通过 **UI UX Pro Max** 技能可复核的来源——`SKILL.md` 工作流、`data/*.csv` 的 `search.py` 检索结果，以及技能内嵌 **Pre-Delivery Checklist / Common Rules**。  
> **不收录**：个人主观「好看」、未写入下文的第三方审美偏好。

**技能路径**：`~/.cursor/skills/ui-ux-pro-max/`  
**检索命令范式**：`python3 "$HOME/.cursor/skills/ui-ux-pro-max/scripts/search.py" "<query>" --domain <ux|product|style|color|web> ...`  
**栈补充**：`--stack html-tailwind`（技能默认栈；本项目映射为 **手写 CSS + 语义 HTML**，不引入 Tailwind 运行时）。

---

## 1. 技能工作流（必须遵守）

摘自 `SKILL.md`：

1. **分析需求**：产品类型、风格关键词、行业、栈（本项目固定为 html 单文件，映射 `html-tailwind` 指南）。
2. **设计系统**：`--design-system` 作首轮参考。
3. **补充检索**：按需 `--domain ux | web | product | style | color`。
4. **栈指南**：`--stack html-tailwind`。

---

## 2. 自动 `--design-system` 与产品不一致时的裁决规则

**现象**：对「mental health / chat / dark」等查询，自动 `--design-system` 可能命中 **App Store 落地页 + 浅色紫系**（`products` / `styles` 评分链路的副作用），与 **夜屿实际形态（深色、全屏对话 H5）** 冲突。

**裁决**（本项目约定，仍基于技能数据源）：

| 优先级 | 来源 | 用途 |
|--------|------|------|
| P0 | `--domain product "mental health app"` → **Mental Health App**（`products.csv`） | 产品类型、伦理关键词（calming、trust、accessibility、crisis 资源意识） |
| P1 | `--domain style "dark mode OLED calm"` → **Dark Mode (OLED)**（`styles.csv`） | 深色底、高可读、**可见焦点**、克制光晕、避免大面积纯白 |
| P2 | `--design-system` 的 **Pre-Delivery Checklist** + **Anti-Patterns**（`SKILL.md`） | 图标、指针、过渡、对比、焦点、减动效 |
| P3 | `--domain ux` / `--domain web` / `--stack html-tailwind` | 具体 Do/Don't 与 Severity |

**浅色盘（如 #FAF5FF）**：仅当自动设计系统输出与 P0+P1 冲突时 **不采用**；记录在本文档即视为技能流程内的「冲突消解」，而非绕过技能。

---

## 3. 已采纳的检索结论（可复跑命令）

### 3.1 产品类型（`--domain product "mental health app"`）

- **Mental Health App**：Accessible & Ethical、Calm Pastels + Trust（语义上映射到深色下的 **trust 色 + 低刺激**，而非强制浅色界面）。
- **关键考量**（csv 原文方向）：Calming aesthetics · Privacy-first · Crisis resources · Progress tracking · **Accessibility mandatory**

### 3.2 风格壳层（`--domain style "dark mode OLED calm"`）

- **Dark Mode (OLED)**：深黑/深灰底、**高对比**、**可见焦点**、最小光晕、夜间与 OLED 友好。
- **实现清单方向**（csv）：Text contrast 7:1+（技能在 OLED 条目中强调高可读；本项目正文至少满足 WCAG 对正常文本的 **4.5:1**，并优先更高）。

### 3.3 UX 域（`--domain ux`，合并多条）

| 主题 | 技能要求（摘要） | Severity |
|------|------------------|----------|
| Color Contrast | 正常文本对比度足够 | High |
| Focus States | 可见焦点，勿移除 outline 而无替代 | High |
| Reduced Motion | `prefers-reduced-motion` | High |
| Loading States | 异步须有骨架/指示，勿冻结界面 | High |
| Touch Target | 触控目标足够大 | High |
| Touch Spacing | 相邻可点区域间距 ≥8px 量级 | Medium |
| Duration | 微交互约 **150–300ms** | Medium |
| Hover vs Tap | 主流程不得仅依赖 hover | High |
| Continuous Animation | 无限动画仅宜用于加载类 | Medium |
| Tap Delay | `touch-action: manipulation` 等 | Medium |
| Pull to Refresh | `overscroll-behavior: contain` 等场景 | Low |

### 3.4 Web 域（`--domain web "aria focus keyboard semantic"`）

| 主题 | 技能要求 | Severity |
|------|----------|----------|
| Semantic HTML | 交互优先 `button` / `a` / `label`，避免 div 冒充按钮 | High–Critical |
| Visible Focus | `:focus-visible` + ring/outline 替代 | Critical |
| Icon-only 控件 | 必须 `aria-label`（或可访问名） | Critical |
| 动态内容 | 适当时 `aria-live`（如对话流更新） | Medium |
| Decorative SVG | `aria-hidden="true"` | Medium |

### 3.5 HTML + Tailwind 栈指南（`--stack html-tailwind`）

- 移动端触控目标 **≥44×44px**（映射到 `.send-btn`、主按钮等）。
- 语义色命名（本项目用 `:root` **CSS 变量** 表达 primary / surface / border，与「勿遍地硬编码色」同向）。

---

## 4. 与 `index.html` 的映射表（实现即证据）

| 技能条目 | 实现位置（概念） |
|----------|------------------|
| Focus Visible + 勿裸 `outline-none` | `:focus-visible` 与 ring 阴影（按钮、输入框、列表项等） |
| Touch 44px | 发送钮 52px；既有 44px 控件保留 |
| touch-action | `html, body { touch-action: manipulation; }` |
| prefers-reduced-motion | 光球、骨架、消息入场、chip hover 位移等 |
| safe-area | `env(safe-area-inset-*)` 与顶栏/底栏/抽屉脚 |
| Loading | chip skeleton、thinking 态 |
| 语义按钮 | 返回、发送、`aria-label`；菜单/新建对话由 **div → button** |
| 动态对话 | `#messages` 设 `aria-live="polite"` |
| 误下拉刷新 | `.phone { overscroll-behavior: contain; }` |
| 禁用 emoji 作图标 | 行动卡片/抽屉图标用 **SVG** 替代装饰符号 ✦（技能：No emoji as icons → 用 SVG） |

---

## 5. Pre-Delivery Checklist（技能原文方向）

发版前对照 `SKILL.md`：

- [ ] 不用 emoji 当 UI 图标（用 SVG）
- [ ] 可点击元素有 `cursor-pointer`（或 button 默认行为）
- [ ] Hover 过渡约 **150–300ms**（触控主流程不依赖 hover）
- [ ] **深色模式**：正文/辅助文字对比度满足 **4.5:1** 起（目标向 OLED 条目的高可读靠拢）
- [ ] 键盘焦点可见
- [ ] `prefers-reduced-motion`
- [ ] 375 / 768 / 1024 / 1440 无横向溢出（H5 主宽 480 内）

---

## 6. 后续新界面怎么加

1. 运行 `search.py` 拉取与本页相关的 `ux` + `web` 行。  
2. 将结论追加到 `design-system/夜屿-night-isle/pages/<page>.md`（若存在则 **覆盖** Master 对应条）。  
3. 再改 `index.html`，并在 page 文件里写 **检索命令 + 日期**。

---

*最后更新：2026-03-28 — 与自动生成的浅色 MASTER 冲突部分已按第 2 节裁决替换。*
