//
//  AQIListViewController.swift
//  AirQuality
//
//  Created by Prince Sojitra on 09/01/22.
//

import DTTableViewManager
import UIKit

class AQIListViewController: UIViewController, DTTableViewManageable {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    var viewModel: AQIListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Cities"
        self.viewModel = AQIListViewModel(delegate: self)
        self.registerAndConfigureCells()
        self.loadCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [unowned self] notification in
            self.viewModel.cityAPIServiceObj?.disconnectFromSocket()
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            self.viewModel.cityAPIServiceObj?.connectToSocket()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }


    func registerAndConfigureCells() {
        manager.register(AQIListTableViewCell.self) { mapping in
            mapping.didSelect { [weak self] cell, model, indexPath in
                // did select menu item \(model) at \(indexPath)
                guard let strongSelf = self else { return }
                let selectedCityData = strongSelf.viewModel.citiesAQIData[indexPath.row]
                strongSelf.viewModel.selectedCity = selectedCityData
                strongSelf.navigateToCityChartVC()
            }
        } handler: { cell, _, _ in
            cell.selectionStyle = .none
        }
    }

    func loadCells() {
        self.errorView.isHidden = true
        self.tableView.isHidden = false
        manager.memoryStorage.updateWithoutAnimations {
            manager.memoryStorage.removeAllItems()
            manager.memoryStorage.setItems(self.viewModel.prepareCellObjects())
        }
        tableView.reloadData()
    }

    deinit {
        manager.tableDelegate = nil
    }

    @IBAction func refreshClicked(_ sender: UIButton) {
        self.viewModel.cityAPIServiceObj?.connectToSocket()
    }

    func navigateToCityChartVC() {
        let controller = AQICityChartViewController(cityDataModel: self.viewModel.selectedCity)
        viewModel.cityChartDelegate = controller.viewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
}


extension AQIListViewController: AirQualityListProtocol {

    func refreshScreen(withData cellObjects: [Any]) {
        self.manager.memoryStorage.updateWithoutAnimations {
            self.manager.memoryStorage.removeAllItems()
            self.manager.memoryStorage.addItems(cellObjects)
        }
        self.tableView.reloadData()
    }

    func socketStatusRefresh(isConnected: Bool, error: String?) {
        self.tableView.isHidden = !isConnected
        self.errorView.isHidden = isConnected
        self.errorLabel.text = error
    }
}
