import Foundation
import Observation
import AVFoundation
import SwiftUI
import UIKit

@Observable
class AuraViewModel {
    // MARK: - State Properties
    var noiseLevel: Float = 0.0
    var currentMood: AuraMood = .calm
    var showDetails: Bool = false
    var noiseHistory: [NoiseEntry] = []
    
    // MARK: - Services
    private var recorder: AVAudioRecorder?
    private let hapticManager = AuraHapticManager()
    
    init() {
        setupMicrophone()
    }
    
    func setupMicrophone() {
        let session = AVAudioSession.sharedInstance()
        
        // 1. Request Permission explicitly
        session.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.startRecording()
                } else {
                    // You could set a 'permissionDenied' flag here to show a UI alert
                    print("Microphone access denied by user.")
                }
            }
        }
    }

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: .mixWithOthers)
        try? session.setActive(true)
        
        let url = URL(fileURLWithPath: "/dev/null")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.isMeteringEnabled = true
        recorder?.record()
        
        // Start the timer only after recording starts
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateData()
        }
    }
    private func updateData() {
        guard let recorder = recorder else { return }
        recorder.updateMeters()
        
        // Normalize decibels (typically -60 to 0) to a 0.0 to 1.0 range
        let db = recorder.averagePower(forChannel: 0)
        let normalizedLevel = max(0, (db + 60) / 60)
        
        // Update the noise level
        self.noiseLevel = normalizedLevel
        
        // 1. Trigger Haptics
        if noiseLevel > 0.2 {
            hapticManager.playPulse(intensity: noiseLevel, sharpness: noiseLevel)
        }
        
        // 2. Add to History for the Chart
        let newEntry = NoiseEntry(timestamp: Date(), level: Double(noiseLevel))
        noiseHistory.append(newEntry)
        if noiseHistory.count > 25 {
            noiseHistory.removeFirst()
        }
        
        // 3. Update the Mood/State
        updateMood()
    }
    
    private func updateMood() {
        if noiseLevel > 0.7 {
            currentMood = .stressed
        } else if noiseLevel > 0.3 {
            currentMood = .energetic
        } else {
            currentMood = .calm
        }
    }
    
    // MARK: - Share Image Generation
    func generateShareImage(scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // Render the share card view at a fixed size defined in AuraShareCard
        let shareView = AuraShareCard(mood: currentMood, noiseLevel: noiseLevel)
            .preferredColorScheme(.dark) // Ensure visuals match your app’s look
        
        let controller = UIHostingController(rootView: shareView)
        let targetSize = CGSize(width: 400, height: 400) // Matches AuraShareCard frame
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = .clear
        
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = scale
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: rendererFormat)
        
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
