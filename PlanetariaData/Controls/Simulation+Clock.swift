//
//  Simulation+Clock.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/9/24.
//

import Foundation

extension Simulation {
    
    // MARK: Public Clock API
    
    // Pause the clock
    public func pause() {
        isPaused.toggle()
    }
    
    // Increase simulation speed
    public func increaseSpeed() {
        if isPaused {
            frameRatio = 1
            isPaused = false
        }
        switch frameRatio {
        case 0, 1: frameRatio = 100
        case -100: frameRatio = 1
        case ...(-100): frameRatio /= 10
        case (100)...: frameRatio *= 10
        default: frameRatio = 1
        }
        if abs(frameRatio) >= maxFrameRatio {
            frameRatio = maxFrameRatio
        }
    }
    
    // Decrease simulation speed
    public func decreaseSpeed() {
        if isPaused {
            frameRatio = 1
            isPaused = false
        }
        switch frameRatio {
        case 0, 1: frameRatio = -100
        case 100: frameRatio = 1
        case ...(-100): frameRatio *= 10
        case (100)...: frameRatio /= 10
        default: frameRatio = 1
        }
        if abs(frameRatio) >= maxFrameRatio {
            frameRatio = -maxFrameRatio
        }
    }
    
    // Set simulation speed directly
    public func setSpeed(_ speed: Double) {
        if isPaused {
            frameRatio = 1
            isPaused = false
        }
        frameRatio = speed
        if abs(frameRatio) >= maxFrameRatio {
            frameRatio = -maxFrameRatio
        }
    }
    
    // Set simulation timestamp directly
    public func setTime(_ timestamp: Date) {
        guard timestamp >= minTime, timestamp <= maxTime else { return }
        setTimestamp(timestamp)
        frameRatio = 1
    }
    
    // Reset to the current time and real speed
    public func resetTime() {
        setTimestamp(.now)
        frameRatio = 1
        isRealTime = true
    }
}
