import Foundation

struct TimeContext {
    let period: String
    let description: String

    var systemLine: String {
        "【当前时间】现在是\(period)（\(description)）"
    }

    static func current() -> TimeContext {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<9:
            return TimeContext(period: "清晨", description: "刚醒，可能带着昨晚的情绪，或担心今天")
        case 9..<12:
            return TimeContext(period: "上午", description: "工作中，刚经历职场冲突，或被消息刺痛")
        case 12..<15:
            return TimeContext(period: "午后", description: "午休后，可能刚开完会、被否、或绩效谈话")
        case 15..<19:
            return TimeContext(period: "傍晚", description: "快下班，疲惫感，或担心今晚/明天")
        case 19..<23:
            return TimeContext(period: "夜晚", description: "晚饭后，独处时间，开始复盘今天")
        default:
            return TimeContext(period: "深夜", description: "翻来覆去，脑子里停不下来")
        }
    }
}
