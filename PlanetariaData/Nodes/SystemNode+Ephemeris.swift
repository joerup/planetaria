//
//  SystemNode+Ephemeris.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 5/21/23.
//

import Foundation

extension SystemNode {
    
    func loadEphemerides() async {
        for system in childSystems {
            await setEphemerides(node: system)
            await system.loadEphemerides()
        }
        for object in childObjects {
            await setEphemerides(node: object)
        }
    }
    
    fileprivate func setEphemerides(node: Node) async {
        do {
            if let stateVector = try await getEphemerisData(node: node) {
                node.set(state: stateVector)
            }
        } catch {
            print(error)
        }
    }

    fileprivate func getEphemerisData(node: Node) async throws -> StateVector? {
        guard node.position == .zero, node.velocity == .zero else { return nil }

        // Get the Horizons ID and date range
        let objectID = node.id
        let sourceID = self.id

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd-HH:mm:ss.SSSS"
        let startDate = dateFormatter.string(from: .now)
        let endDate = dateFormatter.string(from: .now.addingTimeInterval(1))

        let stepSize: String = "1d"

        // Set the URL
        let string = "https://ssd.jpl.nasa.gov/api/horizons.api?format=text&COMMAND='\(objectID > 2000000 ? "DES=" : "")\(String(objectID))'&OBJ_DATA='NO'&MAKE_EPHEM='YES'&EPHEM_TYPE='VECTOR'&CENTER='@\(String(sourceID))'&START_TIME='\(startDate)'&STOP_TIME='\(endDate)'&STEP_SIZE='\(stepSize)'&VEC_TABLE='2'&CSV_FORMAT='YES'"
        
        print("Generating ephemeris for \(node.name)")
        
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
            else {
                throw EphemerisError.invalidEphemeris
            }

            // Create the state vector
            return StateVector(position: [x,y,z], velocity: [vx,vy,vz])
            
        } catch {
            throw error
        }
    }
}

fileprivate enum EphemerisError: Error {
    case invalidURL
    case invalidEphemeris
}
