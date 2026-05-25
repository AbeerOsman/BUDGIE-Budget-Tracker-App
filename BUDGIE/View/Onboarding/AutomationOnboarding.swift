//
//  AutomationOnboarding.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 29/11/1447 AH.
//


import SwiftUI
import AVKit

struct AutomationOnboarding: View {
    
    @State private var step = 0
    @State private var goToWidgetOnboarding = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        if goToWidgetOnboarding {
            WidgetOnboarding()
            
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
                    AutomationIntroView {
                        withAnimation {
                            step = 1
                        }
                    } onSkip: {
                        withAnimation {
                            goToWidgetOnboarding = true
                        }
                    }
                    
                case 1:
                    AutomationImageView {
                        withAnimation {
                            step = 2
                        }
                    }
                    
                default:
                    AutomationVideoView {
                        if let url = URL(string: "https://apps.apple.com/sa/app/shortcuts/id1462947752") {
                            UIApplication.shared.open(url)
                        }
                    } onSkip: {
                        withAnimation {
                            goToWidgetOnboarding = true
                        }
                    }
                }
            }
            .animation(.easeInOut, value: step)
        }
    }
}

#Preview {
    AutomationOnboarding()
}


// MARK: - SCREEN 1

struct AutomationIntroView: View {
    
    var onSetup: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            SetupStepProgress(currentStep: 2)
            Spacer()
            
            VStack(spacing: 22) {
                Text("Track Your Expenses Automatically")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Budgie reads your bank SMS and Apple Pay to log expenses instantly, no manual entry needed.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                
                Button(action: onSetup) {
                    Text("Set Up Automation")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }
                
                Button(action: onSkip) {
                    Text("Skip")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}


// MARK: - SCREEN 2

struct AutomationImageView: View {
    
    var onNext: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            SetupStepProgress(currentStep: 2)
            
            
            Image("shortcutPreview")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 330)
            
            Spacer()
            
            VStack(spacing: 14) {
                
                Text("Track Apple Pay & Bank SMS")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Get notified every time a payment is automatically logged from Apple Pay or bank SMS.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .foregroundStyle(.white)
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

struct AutomationVideoView: View {
    
    var onOpenShortcuts: () -> Void
    var onSkip: () -> Void
    
    @State private var showFullScreenVideo = false
    
    private var videoURL: URL? {
        
        let isArabic = Locale.current.language.languageCode?.identifier == "ar"
        
        let videoName = isArabic
        ? "automationTutorialArabic"
        : "automationTutorialEnglish"
        
        return Bundle.main.url(
            forResource: videoName,
            withExtension: "mp4"
        )
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            SetupStepProgress(currentStep: 2)
            
            Spacer()
            
            Button {
                showFullScreenVideo = true
            } label: {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black)
                        .frame(height: 360)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 28)
                .padding(.top, 45)
            }
            
            Spacer()
            
            VStack(spacing: 14) {
                
                Text("Set Up Shortcut")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Watch the tutorial above, then tap below to open shortcuts.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                
                Button(action: onOpenShortcuts) {
                    
                    Text("Open Shortcuts")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.skyBlue)
                        .clipShape(Capsule())
                }
                
                Button(action: onSkip) {
                    Text("I’ll do it later")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $showFullScreenVideo) {
            
            if let videoURL {
                FullScreenTutorialVideo(videoURL: videoURL)
                    .ignoresSafeArea()
            }
        }
    }
}


// MARK: - FULL SCREEN VIDEO

struct FullScreenTutorialVideo: UIViewControllerRepresentable {
    
    let videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        let controller = AVPlayerViewController()
        
        let player = AVPlayer(url: videoURL)
        
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        
        player.play()
        
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: AVPlayerViewController,
        context: Context
    ) { }
}
