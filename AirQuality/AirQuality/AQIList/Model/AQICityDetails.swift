//
//  AirQualityListModel.swift
//  AirQuality
//
//  Created by Prince Sojitra on 09/01/22.
//

import Foundation
import UIKit

enum AQICategory: Int {
    case good
    case satisfactory
    case moderate
    case poor
    case veryPoor
    case severe
    case unknown
    
    init(rawValue: Double) {
        switch rawValue {
        case _ where rawValue <= 50.00:
            self = .good
        case _ where rawValue <= 100.00:
            self = .satisfactory
        case _ where rawValue <= 200.00:
            self = .moderate
        case _ where rawValue <= 300.00:
            self = .poor
        case _ where rawValue <= 400.00:
            self = .veryPoor
        case _ where rawValue <= 500.00:
            self = .severe
        default:
            self = .unknown
        }
    }
    
    var description: String {
        switch self {
        case .good:
            return AQIListStrings.airQualityIndexGood
        case .satisfactory:
            return AQIListStrings.airQualityIndexSatisfactory
        case .moderate:
            return AQIListStrings.airQualityIndexModerate
        case .poor:
            return AQIListStrings.airQualityIndexPoor
        case .veryPoor:
            return AQIListStrings.airQualityIndexVeryPoor
        case .severe:
            return AQIListStrings.airQualityIndexSevere
        case .unknown:
            return AQIListStrings.airQualityIndexUnknown
        }
    }
    
    var color: UIColor {
        switch self {
        case .good:
            return UIColor(named: AQICategoryColor.good.rawValue) ?? .lightGray
        case .satisfactory:
            return UIColor(named: AQICategoryColor.satisfactory.rawValue) ?? .lightGray
        case .moderate:
            return UIColor(named: AQICategoryColor.moderate.rawValue) ?? .lightGray
        case .poor:
            return UIColor(named: AQICategoryColor.poor.rawValue) ?? .lightGray
        case .veryPoor:
            return UIColor(named: AQICategoryColor.veryPoor.rawValue) ?? .lightGray
        case .severe:
            return UIColor(named: AQICategoryColor.severe.rawValue) ?? .lightGray
        default:
            return UIColor(named: AQICategoryColor.unknown.rawValue) ?? .lightGray
        }
    }
}

enum AQICategoryColor: String {
    case good = "AQI Good Color"
    case satisfactory = "AQI Satisfactory Color"
    case moderate = "AQI Moderate Color"
    case poor = "AQI Poor Color"
    case veryPoor = "AQI Very Poor Color"
    case severe = "AQI Severe Color"
    case unknown = "AQI Unknonwn Color"
}


class AQICityDetails: NSObject
{
    public typealias AQICityResponseBlock = ([CityDataModel]?, Error?) -> ()
    
    struct DataResponse : Codable {
        var city : String
        var aqi  : Double
    }
    
    struct AQIDataModel {
        var aqi: Double
        var category: AQICategory
        var lastUpdated: Date
        
        init(response: DataResponse) {
            self.aqi = response.aqi
            self.category = AQICategory(rawValue: response.aqi.roundingToDecimal(place: 2))
            self.lastUpdated = Date()
        }
    }
    
    struct CityDataModel {
        var cityName: String
        var aqiHistoryData = [AQIDataModel]()
    }
    
    var citiesAQIData = [CityDataModel]()
    
    init(response: [DataResponse]) {
        citiesAQIData.removeAll()
        for dataResponse in response {
            let aqiDataModel = AQIDataModel(response: dataResponse)
            var cityDataModel = CityDataModel(cityName: dataResponse.city)
            cityDataModel.aqiHistoryData.append(aqiDataModel)
            self.citiesAQIData.append(cityDataModel)
        }
    }
    
    static func parseResponse(from string: String, completionBlock: @escaping AQICityResponseBlock) {
        guard let data = string.data(using: .utf8) else {
            print("Invalid Response from server.")
            completionBlock(nil, AQIRepsonseError.invalidResponse)
            return
        }
        do {
            let responseArray = try JSONDecoder().decode([DataResponse].self, from: data)
            let aQICityDetails = AQICityDetails(response: responseArray)
            completionBlock(aQICityDetails.citiesAQIData, nil)
        } catch {
            print(error)
        }
    }
}

enum AQIRepsonseError: Error {
    case invalidResponse
    case inValidRequest
    case parseError
    case networkNotRechable
    
    var description: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .inValidRequest:
            return "Invalid request"
        case .parseError:
            return "parsing error."
        case .networkNotRechable:
            return "No active internet connection"
        }
    }
}
