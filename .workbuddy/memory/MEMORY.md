# 项目长期记忆

## 项目概况
- 医学考研（西医综合306）刷题 Flutter App
- 纯离线，SQLite本地存储，无网络依赖
- 免费工具，无内购

## 技术栈
- Flutter（跨平台 iOS + Android）
- 状态管理：flutter_riverpod ^2.5.0（手写Provider，不用code generation）
- 数据库：sqflite ^2.3.0（4表：question/bookmark/note/quiz_session）
- 路由：go_router ^14.0.0
- 项目结构：Layer-First（models/dao/providers/screens/widgets/services/core）

## 关键约定
- 主色 #5C7B9A（蓝灰低饱和），正确绿 #66BB6A，错误红 #EF5350，收藏黄 #FFB74D
- 全局背景 #F5F7FA，卡片白底，边框 #E0E4E8
- 文字主色 #2C3E50，文字次要 #7B8A9B
- AppBar 白底深色前景+细阴影，卡片0阴影+细边框+12px圆角
- 选项统一用 OptionState 枚举 + optionStyleFor() 工厂驱动
- 多选答案格式：字符串"ABD"（排序后比较）
- 题型字段：type兼容"multiple"和"multi"两种写法
- Bookmark/Note的id为int?可空，插入由SQLite AUTOINCREMENT
- 题库JSON：assets/questions/default.json
- DB名称：medical_quiz.db，版本2（v2 新增 section 列）
- 成绩页不需要，答题完直接返回首页

## 题库信息
- 预置50题种子数据（生理学/病理学/内科学）
- 病理学题库：319道题，11个JSON分片（已有资源）
- 支持JSON导入（合并/替换模式）

## 题库分类体系（2026-06-17 完成数据重构）
- 6大学科：生理、生化、病理、内科、外科、医学人文
- **4级筛选**：学科(subject) → 系统(section) → 章节(chapter) → 考点(topic)
- JSON格式：subject用6学科名，section用"总论"/"各论"，chapter用正式章节名，topic存细粒度考点
- 新增字段 `section`（DB 版升级到 2，`onUpgrade` 自动加列）
- 数据已完成全部重构：855题按 MD 章节框架映射到正确 subject/section/chapter
- 内科呼吸系统→内科/呼吸系统疾病(3文件237题)
- 消化系统→内科/消化系统疾病(2文件188题)
- 泌尿系统→内科/泌尿系统疾病(1文件94题)
- 病理学→病理/总论+各论(4文件336题)

## 筛选 UI
- 4级 chip 选择器（SelectionCard），每级独立浅灰圆角卡片
- 选项：未选中白底灰边圆角按钮，选中浅蓝底深蓝字

## 视觉风格（2026-06-17）
- 主色 #5C7B9A（蓝灰低饱和），提色：primaryLight #E8EDF2, primaryDark #3D5A78
- 语义色低饱和：正确绿 #66BB6A, 错误红 #EF5350, 收藏黄 #FFB74D
- 全局背景 #F5F7FA, 卡片白底+1px边框(#E0E4E8)+12px圆角+弱阴影
- 文字：深蓝灰 #2C3E50（主），中灰 #7B8A9B（次）
- AppBar：白底深色前景+底部细阴影
- 选项样式：OptionState枚举 + optionStyleFor()工厂驱动

## Bug 修复记录
- 2026-06-16 修复多选选项点击闪烁：去掉 _pendingMultipleAnswers 双重状态，统一用 quizState.answers
- 2026-06-16 修复收藏按钮点不动：currentIsBookmarkedProvider 去掉 autoDispose + 用 bookmarkVersionProvider 触发刷新
- 2026-06-17 筛选 UI 重构：3级Dropdown → 4级Chip选择器(subject→section→chapter→topic)，DB v2 新增 section 列
- 2026-06-17 全App视觉风格重构：蓝灰低饱和色系、圆角卡片细边框弱阴影、OptionState枚举驱动选项样式（15文件修改）
- 2026-06-17 JSON题库数据重构：按MD章节框架映射855题到subject/section/chapter四级结构
