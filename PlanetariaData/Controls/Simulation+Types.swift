//
//  Simulation+Types.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/9/24.
//

extension Simulation {
    
    public enum ViewType {
        
        // scaled based on a fixed box on a screen
        // gestures applied on any part of the screen
        // allows full rotation & pitch from -90 to 90
        // billboards point toward the screen plane
        // used for iOS/macOS by default
        case fixed
        
        // scaled based on a fixed box in AR
        // gestures applied on any part of the screen
        // allows full rotation but no pitch
        // billboards point toward the camera point
        // used for iOS in AR mode
        case augmented
        
        // scaled to its true size
        // center set to a sufficient far-away distance
        // allows full rotation and pitch
        // billboards point toward the camera point
        // used for visionOS
        case immersive
        
    }
    
    public enum UpdateType {
        
        // uses SPICE to access state
        // initial state input directly from SPICE
        case spice
        
        // uses numerical n-body integration to access state
        // initial state input from decoded json
        case integration
        
    }

    public enum Status {
        case uninitialized
        case decodingNodes
        case loadingEphemerides
        case creatingEntities
        case fetchingContent
        case loaded
        case error(SimulationError)
        
        public var text: String {
            switch self {
            case .uninitialized:
                "Starting"
            case .decodingNodes:
                "Loading object data"
            case .loadingEphemerides:
                "Loading orbit data"
            case .creatingEntities:
                "Creating models"
            case .fetchingContent:
                "Fetching additional content"
            case .loaded:
                "Loaded"
            case .error(_):
                "Error"
            }
        }
    }
    
    public enum SimulationError: Error {
        case nodeDecodingFailed
        case ephemerisNotFound
        case ephemerisLoadingFailed
        case unknown
        
        public var text: String {
            switch self {
            case .nodeDecodingFailed:
                "Error decoding nodes from file"
            case .ephemerisNotFound:
                "Error: ephemeris not found"
            case .ephemerisLoadingFailed:
                "Error loading ephemeris"
            case .unknown:
                "An unknown error occurred"
            }
        }
        
        public var detailText: String {
            "Please try again later. If the issue persists,"
        }
    }
}
