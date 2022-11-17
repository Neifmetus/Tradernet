import UIKit

class TradeViewController: UIViewController {
    
    let viewModel = TradeViewModel()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(StockTableViewCell.self, forCellReuseIdentifier: StockTableViewCell.identifier)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        self.viewModel.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

}

extension TradeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.identifier) as? StockTableViewCell {
            cell.configure(model: viewModel.stocks[indexPath.row])
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        return UITableViewCell()
    }
}

extension TradeViewController: UITableViewDelegate {}

extension TradeViewController: TradeViewModelDelegate {
    func addNewStock() {
        tableView.reloadData()
    }
    
    func updateStockInfo(index: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? StockTableViewCell {
            cell.update(model: viewModel.stocks[index])
        }
    }
}
