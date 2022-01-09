//
//  AQIListViewModel.swift
//  AirQuality
//
//  Created by Prince Sojitra on 09/01/22.
//

import Foundation
import Starscream


protocol AirQualityListProtocol: NSObject {
    func refreshScreen(withData cellObjects: [Any])
    func socketStatusRefresh(isConnected: Bool, error: String?)
}

protocol AQICityChartDelegate: NSObject {
    func refreshCityDataToChart(with data: AQICityDetails.CityDataModel)
}

class AQIListViewModel: NSObject {
    var citiesAQIData = [AQICityDetails.CityDataModel]()
    var cityAPIServiceObj: AQICityAPIService?
    var selectedCity: AQICityDetails.CityDataModel?
    weak var delegate: AirQualityListProtocol?
    weak var cityChartDelegate: AQICityChartDelegate?
    
    init(cityAPIServiceObj: AQICityAPIService? = AQICityAPIService(), delegate: AirQualityListProtocol? = nil, cityChartDelegate: AQICityChartDelegate? = nil) {
        super.init()
        self.cityAPIServiceObj = cityAPIServiceObj
        self.delegate = delegate
        self.cityChartDelegate = cityChartDelegate
        setupWebSocketConnection()
    }

    func setupWebSocketConnection() {
        self.cityAPIServiceObj?.connectToSocket()
        self.cityAPIServiceObj?.socket?.delegate = self
    }
    
    func prepareCellObjects() -> [Any] {
        var cells = [Any]()
        citiesAQIData.forEach { cityData in
            cells.append(cityListItemCellObject(cityData: cityData))
        }
        return cells
    }
    
    func cityListItemCellObject(cityData: AQICityDetails.CityDataModel) -> AQIListIItemCellObjects {
        let cityCell = AQIListIItemCellObjects()
        cityCell.city = cityData.cityName
        cityCell.airQualityIndex = cityData.aqiHistoryData.last?.aqi
        cityCell.airQualityCategory = cityData.aqiHistoryData.last?.category
        cityCell.airQualityCategoryColor = cityData.aqiHistoryData.last?.category.color
        cityCell.lastUpdated = cityData.aqiHistoryData.last?.lastUpdated.timeAgoSince()
        return cityCell
    }
}

extension AQIListViewModel: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        indicator?.stopAnimating()
        switch event {
        case .connected(let headers):
            self.cityAPIServiceObj?.isConnected = true
            print("Websocket is connected: \(headers)")
            self.delegate?.socketStatusRefresh(isConnected: true, error: nil)
        case .disconnected(let reason, let code):
            self.cityAPIServiceObj?.isConnected = false
            print("Websocket is disconnected: \(reason) code: \(code)")
            self.delegate?.socketStatusRefresh(isConnected: false, error: reason)
        case .text(let string):
            AQICityDetails.parseResponse(from: string) { [weak self ] response,error  in
                guard let responseData = response, let strongSelf = self else {
                    return
                }
                strongSelf.processAQIData(with: responseData)
                strongSelf.delegate?.refreshScreen(withData: strongSelf.prepareCellObjects())

                // prepare data for chart and notiify chart for new data
                if strongSelf.cityChartDelegate != nil && strongSelf.selectedCity != nil {
                    if let selectedCity = strongSelf.citiesAQIData.filter({$0.cityName == strongSelf.selectedCity!.cityName}).first {
                        strongSelf.cityChartDelegate?.refreshCityDataToChart(with: selectedCity)
                    }
                }
            }
        case .binary(let data):
            print("Data: \(data.count)")
        case .ping(_), .pong(_), .viabilityChanged(_), .reconnectSuggested(_):
            break
        case .cancelled:
            self.cityAPIServiceObj?.isConnected = false
        case .error(let error):
            self.cityAPIServiceObj?.isConnected = false
            print("Websocket error:", error?.localizedDescription ?? "")
            self.delegate?.socketStatusRefresh(isConnected: false, error: error?.localizedDescription)
        }
    }
    
    
    func processAQIData(with data: [AQICityDetails.CityDataModel]) {
        for dataResponse in data {
            let aqiHistoryData = dataResponse.aqiHistoryData
            if var cityModel = citiesAQIData.filter({ $0.cityName == dataResponse.cityName }).first {
                if cityModel.aqiHistoryData.count >= 10 {
                    cityModel.aqiHistoryData.removeFirst()
                }
                cityModel.aqiHistoryData.append(contentsOf: aqiHistoryData)
                if let index = citiesAQIData.firstIndex(where: {$0.cityName == dataResponse.cityName}) {
                    citiesAQIData[index] = cityModel
                }
            } else {
                self.citiesAQIData.append(dataResponse)
            }
        }
        self.citiesAQIData.sort { $0.cityName < $1.cityName }
    }
}
