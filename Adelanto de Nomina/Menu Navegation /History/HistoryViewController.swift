//
//  HistoryViewController.swift
//  Adelanto de Nomina
//
//  Created by Miguel Eduardo  Valdez Tellez  on 22/06/21.
//

import UIKit

class HistoryViewController: UIViewController {

    var paymentsArray: [Payment] = []
    var filtered: [Payment]!

    @IBOutlet weak var segmentSort: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var paymentTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadJson()
        initView()
    }

    @IBAction func sortSegmentAction(_ sender: Any) {
        if segmentSort.selectedSegmentIndex == 0 {
            filtered = filtered.sorted(by: { $0.concepto < $1.concepto })
            paymentTable.reloadData()
        } else if segmentSort.selectedSegmentIndex == 1 {
            filtered = filtered.sorted(by: { $0.monto < $1.monto })
            paymentTable.reloadData()
        } else {
            filtered = filtered.sorted(by: { $0.metodo < $1.metodo })
            paymentTable.reloadData()
        }
    }

    @discardableResult
    func loadJson() -> [Payment]? {
        if let url = Bundle.main.url(forResource: "payments", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([Payment].self, from: data)
                paymentsArray = jsonData
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }

    func initView() {
        paymentTable.register(StoryTableViewCell.nib, forCellReuseIdentifier: StoryTableViewCell.reuseIdentifier)
        paymentTable.delegate = self
        paymentTable.dataSource = self
        paymentTable.separatorStyle = .none
        searchBar.delegate = self
        filtered = paymentsArray
        filtered = filtered.sorted(by: { $0.concepto < $1.concepto })
        self.hideKeyboardWhenTappedAround()
        segmentSort.setTitle(NSLocalizedString("CONCEP", comment: ""), forSegmentAt: 0)
        segmentSort.setTitle(NSLocalizedString("BALANCE", comment: ""), forSegmentAt: 1)
        segmentSort.setTitle(NSLocalizedString("PAYMENT", comment: ""), forSegmentAt: 2)
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? StoryTableViewCell else {
            fatalError()
        }
        cell.conceptoLabel.text = filtered[indexPath.row].concepto
        let monto = String(filtered[indexPath.row].monto)
        let montoProcesado = "$\(monto)0 MXN"
        cell.montoLabel.text = montoProcesado
        cell.fechaLabel.text = filtered[indexPath.row].fecha
        cell.medioPagoImage.image = UIImage(named: filtered[indexPath.row].metodo)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "Detail") as? DetailsPaymentViewController else {
            fatalError()
        }
        let monto = String(filtered[indexPath.row].monto)
        let montoProcesado = "$\(monto)0 MXN"
        controller.conceptText = filtered[indexPath.row].concepto
        controller.balanceText = montoProcesado
        controller.dateText = filtered[indexPath.row].fecha
        controller.paymentText = filtered[indexPath.row].metodo
        controller.conceptImageText = filtered[indexPath.row].imageConcept
        present(controller, animated: true, completion: nil)
    }
}

extension HistoryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = []
        if searchText == "" {
            filtered = paymentsArray
        } else {
            for concept in paymentsArray {
                if concept.concepto.lowercased().contains(searchText.lowercased()) {
                    filtered.append(concept)
                }
            }
        }
        self.paymentTable.reloadData()
    }
}
