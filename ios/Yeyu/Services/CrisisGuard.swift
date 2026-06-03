import Foundation

enum CrisisGuard {
    static let hotline = "400-161-9995"
    /// iOS tel: URL — 不含短横线，确保所有版本可拨号
    static let hotlineURL = "tel:4001619995"

    private static let keywords = [
        "自杀", "想死", "不想活", "结束生命", "割腕", "跳楼", "吞药",
        "了断", "轻生", "自残", "伤害自己",
        "想消失", "活着没意思", "死了算了", "不如死了", "不想撑了", "太累了想结束",
    ]

    static func shouldShowCrisisUI(for text: String) -> Bool {
        keywords.contains { text.contains($0) }
    }
}
