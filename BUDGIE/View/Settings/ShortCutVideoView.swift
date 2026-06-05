//
//  ShortCutVideoView.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 19/12/1447 AH.
//

import SwiftUI

struct ShortCutVideoView: View {
    
    var onOpenShortcuts: () -> Void
    
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

#Preview {
    ShortCutVideoView(onOpenShortcuts: {
        if let url = URL(string: "https://apps.apple.com/sa/app/shortcuts/id1462947752") {
            UIApplication.shared.open(url)
        }
    })
}
