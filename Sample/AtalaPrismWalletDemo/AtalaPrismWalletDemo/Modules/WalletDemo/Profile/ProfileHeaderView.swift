import SwiftUI

struct ProfileHeaderView: View {
    let profile: HomeState.Profile

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    profileView
                }
                .padding(.horizontal, 35)
                .padding(.top, 60)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
                .background(Image("bg_home_profile").resizable())
                .clipShape(SpecificRoundedRect(
                    radius: 10,
                    corners: [.bottomLeft, .bottomRight]
                ))
            }
        }
    }

    private var profileView: some View {
        VStack {
            HStack(spacing: 20) {
                let image =
                UIImage(data: profile.profileImage).map {
                    Image(uiImage: $0)
                } ?? Image("ico_placeholder_user")

                image
                    .resizable()
                    .frame(width: 98, height: 98)
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading) {
                        Text("home_profile_hey"
                            .localize())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(profile.fullName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ProfileHeaderView_Previews: PreviewProvider {

    static var previews: some View {
        ProfileHeaderView(
            profile: .init(
                profileImage: Data(),
                fullName: "Jonh Doe"
            )
        )
    }
}
