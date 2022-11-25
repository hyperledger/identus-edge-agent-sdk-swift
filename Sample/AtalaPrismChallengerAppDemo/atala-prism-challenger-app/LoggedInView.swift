//
//  LoggedInView.swift
//  atala-prism-challenger-app
//
//  Created by Goncalo Frade IOHK on 31/10/2022.
//

import SwiftUI

struct LoggedInView: View {
    var body: some View {
        VStack {
            Text("🚀🎉 Congrats 🎉🚀")
                .font(.title)
            Text("You successfully Logged In with your ") + Text("DID").bold()
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
