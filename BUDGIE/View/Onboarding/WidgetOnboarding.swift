//
//  WidgetOnboarding.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 29/11/1447 AH.
//

import SwiftUI
import AVKit

struct WidgetOnboarding: View {
    
    @State private var step = 0
    @State private var goToMain = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        if goToMain {
            Main()
            
        } else {
            ZStack {
                Image(colorScheme == .dark ? "DarkBG" : "LightBG")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.75)
                    .offset(x:30,y:-500)
                    .blur(radius: 60)
                
                switch step {
                case 0:
                    WidgetIntroView {
                        withAnimation {
                            step = 1
                        }
                    } onSkip: {
                        withAnimation {
                            goToMain = true
                        }
                    }
                    
                case 1:
                    WidgetImageView {
                        withAnimation {
                            step = 2
                        }
                    }
                    
                default:
                    WidgetVideoView {
                        exit(0)
                    } onSkip: {
                        withAnimation {
                            goToMain = true
                        }
                    }
                }
            }
            .animation(.easeInOut, value: step)
        }
    }
}

#Preview {
    WidgetOnboarding()
}

// MARK: - SCREEN 1

struct WidgetIntroView: View {
    
    var onSetup: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            VStack(spacing: 22) {
                Text("Quickly View Your Spending")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Use the widget to instantly check your balance, spending activity, and category progress directly from your home or lock screen.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: onSetup) {
                    Text("Set Up Widget")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }
                
                Button(action: onSkip) {
                    Text("Skip")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}
// MARK: - SCREEN 2

struct WidgetImageView: View {
    
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            Image("widgetPreview")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 330)
            
            Spacer()
            
            VStack(spacing: 14) {
                Text("Add Payments Faster")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Quickly log manual payments from the widget without opening the app, making expense tracking easier and more accessible.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Color.skyBlue)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}
// MARK: - SCREEN 3

struct WidgetVideoView: View {
    
    var onAddWidget: () -> Void
    var onSkip: () -> Void
    
    private var player: AVPlayer {
        if let url = Bundle.main.url(forResource: "widgetTutorial", withExtension: "mp4") {
            return AVPlayer(url: url)
        }
        return AVPlayer()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            VideoPlayer(player: player)
                .frame(height: 360)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 28)
                .padding(.top, 45)
            
            Spacer()
            
            VStack(spacing: 14) {
                Text("Set Up Widget")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Watch the tutorial above, then tap below to Add Widget.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: onAddWidget) {
                    Text("Add Widget")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }
                
                Button(action: onSkip) {
                    Text("I’ll do it later")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}
