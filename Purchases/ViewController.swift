//
//  ViewController.swift
//  Purchases
//
//  Created by shengjie on 2022/8/24.
//

import StoreKit
import UIKit
class ViewController: UIViewController {
    enum product: String, CaseIterable {
        case one
        case two
        case three
    }

    @IBOutlet var tableView: UITableView!
    var models = [SKProduct]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        SKPaymentQueue.default().add(self)
        fetchDatas()
        // Do any additional setup after loading the view.
    }

    func fetchDatas() {
        let request = SKProductsRequest(productIdentifiers: Set(product.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        let product = models[indexPath.row]
        cell.textLabel?.text = "\(product.localizedTitle):\(product.localizedDescription)-\(product.priceLocale.currencySymbol ?? "$")\(product.price)"
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let payment = SKPayment(product: models[indexPath.row])
        SKPaymentQueue.default().add(payment)
    }
}

extension ViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.models = response.products
            self.tableView.reloadData()
        }
    }
}

extension ViewController:SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            switch $0.transactionState {
                
            case .purchasing:
                print("purchasing")
            case .purchased:
                print("purchased")
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                print("did not purchase")
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
    
    
}
