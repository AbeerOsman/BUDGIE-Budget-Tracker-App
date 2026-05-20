//
//  Splash.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 28/11/1447 AH.
//

import SwiftUI

struct Splash: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var navigate = false
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some View {
        Group {
            if navigate {
                if hasOnboarded {
                    ContentView()
                } else {
                    Onboarding()
                }
            } else {
                Image(colorScheme == .dark ? "TextLogo" : "TextLogoDark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170)
                    .offset(y: -50)
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                navigate = true
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    Splash()
}
