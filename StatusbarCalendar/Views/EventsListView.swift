import EventKit
import SwiftUI

/// 选中日的系统日历事件列表
struct EventsListView: View {
    @EnvironmentObject var app: AppState

    private var events: [EKEvent] {
        app.eventStore.events(on: app.selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Divider().padding(.horizontal, 12)

            switch app.eventStore.accessState {
            case .pending:
                Label("正在请求日历权限…", systemImage: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

            case .denied:
                VStack(spacing: 6) {
                    Label("无法访问系统日历", systemImage: "calendar.badge.exclamationmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("请在 系统设置 → 隐私与安全性 → 日历 中允许访问")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            default:
                if events.isEmpty {
                    Label("当日无日历事件", systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(Array(events.enumerated()), id: \.offset) { _, event in
                                EventRow(event: event)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .frame(maxHeight: 130)
                }
            }
        }
    }
}

private struct EventRow: View {
    let event: EKEvent

    private var timeText: String {
        let formatter = DateFormatter()
        if event.isAllDay { return "全天" }
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: event.startDate)
    }

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color(nsColor: event.calendar.color))
                .frame(width: 3, height: 14)
            Text(timeText)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 34, alignment: .leading)
            Text(event.title ?? "（无标题）")
                .font(.system(size: 11))
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 1)
    }
}
