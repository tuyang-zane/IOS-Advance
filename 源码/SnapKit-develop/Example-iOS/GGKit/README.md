#  Tour

SnapKit/
├── Core/                     # 约束核心模型层（存储约束数据）
│   ├── Constraint.swift               # 最终约束对象，对应系统NSLayoutConstraint
│   ├── ConstraintDescription.swift     # 一条约束的完整描述（5.x核心）
│   ├── ConstraintItem.swift           # 约束载体（View/LayoutGuide/目标属性）
│   ├── ConstraintAttributes.swift      # 约束属性（top/left/width/size/edges等）
│   ├── ConstraintRelation.swift       # 约束关系（equal/lessThan/greaterThan）
│   ├── ConstraintLayoutGuide.swift    # 安全区/布局引导器兼容
│   └── ConstraintPriority.swift       # 约束优先级（required/high/low）
│
├── Maker/                    # 链式语法核心层（DSL实现）
│   ├── ConstraintMaker.swift           # 约束生成入口（make/update/remake）
│   ├── ConstraintMakerExtendable.swift # 属性扩展（top/left/edges/size/center）
│   ├── ConstraintMakerRelatable.swift  # 关系设置（equalTo/lessThan）
│   ├── ConstraintMakerEditable.swift   # 数值编辑（offset/inset/multiplied）
│   └── ConstraintMakerPrioritizable.swift # 优先级设置（priority）
│
├── Extensions/               # 对外使用入口层
│   ├── View+SnapKit.swift           # 给UIView添加.snp命名空间
│   ├── LayoutGuide+SnapKit.swift    # 给安全区/布局Guide添加约束能力
│   └── Array+SnapKit.swift          # 批量给多个视图添加约束
│
├── Configuration/            # 全局配置与调试
│   └── SnapKitDebug.swift           # 约束错误/冲突日志打印
│
├── Utilities/                # 约束操作工具层
│   └── Constraint+Install.swift     # 约束安装、卸载、激活、卸载
│
└── SnapKit.swift             # 公开API统一导出
