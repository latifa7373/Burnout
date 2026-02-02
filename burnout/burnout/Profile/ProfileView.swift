import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        Text("Profile Screen")
            .font(.title)
    }
}

#Preview {
    ProfileView()
}



