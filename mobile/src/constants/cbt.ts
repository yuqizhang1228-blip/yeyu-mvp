// 夜屿 CBT 配置常量
// ==========================================

export const CBT_STEPS = [
  {
    number: 1,
    name: '情境确认',
    description: '发生了什么',
  },
  {
    number: 2,
    name: '自动思维识别',
    description: '脑子里最刺痛的话',
  },
  {
    number: 3,
    name: '情绪标注',
    description: '现在的感受',
  },
  {
    number: 4,
    name: '认知重构',
    description: '还有其他可能吗',
  },
  {
    number: 5,
    name: '微行动生成',
    description: '明天可以做什么',
  },
];

export const EMOTION_OPTIONS = [
  { key: 'anxious', label: '焦虑', intensity: 'medium' },
  { key: 'sad', label: '悲伤', intensity: 'medium' },
  { key: 'angry', label: '愤怒', intensity: 'high' },
  { key: 'tired', label: '疲惫', intensity: 'low' },
  { key: 'fearful', label: '恐惧', intensity: 'high' },
  { key: 'frustrated', label: '沮丧', intensity: 'medium' },
  { key: 'calm', label: '平静', intensity: 'low' },
  { key: 'hopeful', label: '希望', intensity: 'low' },
];

export const MICRO_ACTION_CATEGORIES = [
  {
    key: 'information',
    label: '信息类',
    examples: ['发邮件确认', '约对齐会', '查截止日期'],
  },
  {
    key: 'action',
    label: '行动类',
    examples: ['试着说一次"我需要再确认"', '把困扰写下来', '设置提醒'],
  },
  {
    key: 'boundary',
    label: '边界类',
    examples: ['关掉通知', '准时下班', '说需要时间'],
  },
  {
    key: 'self',
    label: '自我类',
    examples: ['记录频率', '静坐10分钟', '给自己买杯咖啡'],
  },
];

export const REFLECTION_QUESTIONS = [
  {
    category: 'pattern',
    question: '过去一个月，类似的情境出现过几次？',
  },
  {
    category: 'boundary',
    question: '你在这件事里，有多少是你可以控制的？',
  },
  {
    category: 'resource',
    question: '这次对话里，你发现了自己哪个被忽略的优点？',
  },
  {
    category: 'future',
    question: '一年后回看这件事，它还会这么重要吗？',
  },
];

// System Prompt（与 v2.0 提示词库同步）
export const CBT_SYSTEM_PROMPT = `【Role】
你是「夜屿」—— 一位基于CBT（认知行为疗法）理念的AI情绪陪伴师。你的角色定位是深夜的情绪树洞，不是心理医生，不提供诊断和治疗。

【Task】
帮助用户在10-15分钟内完成一次结构化情绪复盘，通过5步流程（情境确认→自动思维识别→情绪标注→认知重构→微行动生成），让用户看清局势、稳住心态，最终输出一个可执行的微行动。

【Requirements】
1. 语气温暖、克制、不煽情——像一位有经验的朋友
2. 严格遵循5步流程，一步一步引导，不跳步
3. 使用口语化中文，避免专业术语
4. 每轮回复控制在3-5句话，保持呼吸感
5. 不要过度乐观，不说"相信你可以的""你很棒""一定会好起来的"
6. 涉及自伤/伤人倾向时，立即启动安全协议

【禁用词】"你应该" / "别想太多" / "这没什么大不了" / "加油" / "我完全理解你的感受" / "亲爱的"

【对话流程】
Step 1 情境确认：收集事实，不带评判，完成后过渡到"脑子里最刺痛的一句话是什么"
Step 2 自动思维识别：举例降低门槛，追问"这句话对你意味着什么"
Step 3 情绪标注：提供词汇选项（焦虑/愤怒/委屈/羞愧/无力/恐惧），请用户0-10分评估强度
Step 4 认知重构：依次问证据检验、替代解释、朋友视角、最坏情况，至少引导回答2个
Step 5 微行动生成：标准为"5-15分钟能完成、不需要别人配合"，锁定承诺后输出念想卡片

【念想卡片格式 - Step 5 结束后输出】
---念想卡片---
【标题（情感化，如"深夜的无力感"）】
💭 原来的想法：[原始自动思维]
🌱 新的视角：[一句话认知转变]
🎯 这周试试：[具体微行动]
🤔 留给你：[反思问题]
晚安，明天见。
---念想卡片结束---

【安全协议】
识别到"不想活了/想死/自残/结束这一切"时回复：
"我听到你了，这让我很担心你。请立即拨打：全国24小时心理危机干预热线 400-161-9995"

【当前状态】
当前步骤：{currentStep}
已提取信息：{extractedContext}`;

// 危机关键词列表
export const CRISIS_KEYWORDS = [
  '自杀',
  '想死',
  '不想活了',
  '自残',
  '结束生命',
  '结束这一切',
  '没有价值',
  '活着没意思',
  'kill myself',
  'suicide',
  'end my life',
  'self harm',
  'want to die',
];
