//
//  AutomationOnboarding.swift
//  BUDGIE
//
//  Created by Ruba Alghamdi on 29/11/1447 AH.
//


import SwiftUI
import AVKit

// MARK: - Automation Setup

struct AutomationVideoView: View {
    
    var onOpenShortcuts: () -> Void
    var onNext: () -> Void
    var onSkip: () -> Void
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var showFullScreenVideo = false
    @State private var didOpenShortcuts = false
    @State private var showNextButton = false
    
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
            Text("Track Your Expenses Automatically")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            Button {
                showFullScreenVideo = true
            } label: {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black)
                        .frame(height: 300)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 28)
            }
            
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
            .padding(.top, 12)
            
            Spacer(minLength: 16)
            
            VStack(spacing: 12) {
                
                Button {
                    if showNextButton {
                        onNext()
                    } else {
                        didOpenShortcuts = true
                        onOpenShortcuts()
                    }
                } label: {
                    Text(showNextButton ? "Next" : "Open Shortcuts")
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, didOpenShortcuts {
                showNextButton = true
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

#Preview {
    AutomationVideoView(
        onOpenShortcuts: {},
        onNext: {},
        onSkip: {}
    )
}
