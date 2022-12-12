import Combine
import SwiftUI

struct ActivityListView: View {
    let activities: [HomeState.ActivityLog]
    private let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        VStack {
            ForEach(activities.zipped(), id: \.0) { _, activity in
                card(activity: activity)
            }
        }
    }

    func card(activity: HomeState.ActivityLog) -> some View {
        HStack(alignment: .top, spacing: 16) {
            activity.activityType.image
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Text(activity.infoText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(.gray))
                Text(activity.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .kerning(0.4)
            }
            Spacer()
            HStack {
                Image("ico_time")
                AutoUpdatingDateText(state: activity, timer: timer)
            }
        }
        .frame(height: 68)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color(.gray), radius: 3)
        )
    }
}

private struct AutoUpdatingDateText: View {
    let state: HomeState.ActivityLog
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State private var text: String = ""

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(Color(.gray))
            .onReceive(timer) { _ in
                self.text = state.dateFormatter.localizedString(for: state.date, relativeTo: Date())
            }
    }
}

private extension HomeState.ActivityLog.ActivityType {
    var image: Image {
        switch self {
        case .connected:
            return Image("icon_connected")
        case .shared:
            return Image("icon_shared")
        case .received:
            return Image("icon_received")
        }
    }
}

struct ActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityListView(activities: [
            .init(
                activityType: .connected,
                infoText: "Info",
                name: "Name",
                dateFormatter: RelativeDateTimeFormatter(),
                date: Date()
            ),
            .init(
                activityType: .shared,
                infoText: "Info",
                name: "Name",
                dateFormatter: RelativeDateTimeFormatter(),
                date: Date()
            ),
            .init(
                activityType: .received,
                infoText: "Info",
                name: "Name",
                dateFormatter: RelativeDateTimeFormatter(),
                date: Date()
            )
        ])
    }
}
