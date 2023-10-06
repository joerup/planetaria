//
//  Node+Ephemeris.swift
//  Planetaria
//
//  Created by Joe Rupertus on 5/21/23.
//

import Foundation

extension Node {
    
    public func loadEphemerides(major: Bool? = nil) async {
        await object?.loadEphemeris()
        var children = children.filter { $0 != object }
        if let major {
            children = children.filter { major ? $0.category == .system || $0.category == .star : $0.category != .system && $0.category != .star }
        }
        for child in children {
            await child.loadEphemeris()
        }
    }
    
    fileprivate func loadEphemeris() async {
        do {
            if timestamp == nil, let ephemerisData = try await getEphemerisData(date: .now) {
                self.timestamp = ephemerisData.timestamp
                self.position = ephemerisData.position
                self.velocity = ephemerisData.velocity
                self.setOrbitalElements()
                self.setRotationalElements()
            }
        } catch {
            print(error)
        }
    }

    fileprivate func getEphemerisData(date: Date) async throws -> EphemerisData? {

        // Get the Horizons ID and date range

        let objectID = self.id
        let sourceID = parent?.id ?? 0

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd-HH:mm:ss.SSSS"
        let startDate = dateFormatter.string(from: date)
        let endDate = dateFormatter.string(from: date.addingTimeInterval(1))

        let stepSize: String = "1d"

        // Set the URL

        let string = "https://ssd.jpl.nasa.gov/api/horizons.api?format=text&COMMAND='\(objectID > 2000000 ? "DES=" : "")\(String(objectID))'&OBJ_DATA='NO'&MAKE_EPHEM='YES'&EPHEM_TYPE='VECTOR'&CENTER='@\(String(sourceID))'&START_TIME='\(startDate)'&STOP_TIME='\(endDate)'&STEP_SIZE='\(stepSize)'&VEC_TABLE='2'&CSV_FORMAT='YES'"
        
        print("Generating ephemeris for \(self.name)")
        
        guard let url = URL(string: string) else { throw EphemerisError.invalidURL }

        do {

            // Make the API call

            let (data, _) = try await URLSession.shared.data(from: url)
            let returnedString = String(decoding: data, as: UTF8.self)
            
            // Get the raw data

            let returnedLines = returnedString.split(separator: "\n")
            guard let start = returnedLines.firstIndex(of: "$$SOE"), let end = returnedLines.firstIndex(of: "$$EOE") else { throw EphemerisError.invalidEphemeris }
            guard let ephemerisLine = returnedLines[start+1 ..< end].first else { throw EphemerisError.invalidEphemeris }
            let rawEphemerisData = ephemerisLine.split(separator: ",").map { $0.replacingOccurrences(of: " ", with: "") }
            
            // Set the properties
            
            guard rawEphemerisData.count == 8,
                    let x = Double(rawEphemerisData[2]),
                    let y = Double(rawEphemerisData[3]),
                    let z = Double(rawEphemerisData[4]),
                    let vx = Double(rawEphemerisData[5]),
                    let vy = Double(rawEphemerisData[6]),
                    let vz = Double(rawEphemerisData[7])
            else { throw EphemerisError.invalidEphemeris }

            var date = rawEphemerisData[1]
            date.removeFirst(4)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MMM-ddHH:mm:ss.SSSS"
            
            guard let timestamp = dateFormatter.date(from: date) else { throw EphemerisError.invalidEphemeris }

            // Create the ephemeris

            let ephemerisData = EphemerisData(timestamp: timestamp, position: [x,y,z], velocity: [vx,vy,vz])

            return ephemerisData

        } catch {
            throw error
        }
    }

    fileprivate struct EphemerisData {
        var timestamp: Date
        var position: [Double]
        var velocity: [Double]
    }

    fileprivate enum EphemerisError: Error {
        case invalidURL
        case failedToLoad
        case invalidEphemeris
    }
}
