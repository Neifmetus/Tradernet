import UIKit

class StockTableViewCell: UITableViewCell {
    
    static let identifier = "stockCell"
    
    // MARK: Views
    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let priceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let priceShiftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstrains() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(priceShiftLabel)
        contentView.addSubview(priceView)
        priceView.addSubview(priceLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceView.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceShiftLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            priceView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            priceView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: priceView.topAnchor, constant: 2),
            priceLabel.leftAnchor.constraint(equalTo: priceView.leftAnchor, constant: 4),
            priceLabel.rightAnchor.constraint(equalTo: priceView.rightAnchor, constant: -4),
            priceLabel.bottomAnchor.constraint(equalTo: priceView.bottomAnchor, constant: -2)
        ])
        
        NSLayoutConstraint.activate([
            priceShiftLabel.topAnchor.constraint(equalTo: priceView.bottomAnchor, constant: 4),
            priceShiftLabel.rightAnchor.constraint(equalTo: priceView.rightAnchor),
            priceShiftLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(model: Stock) {
        titleLabel.text = model.name
        subtitleLabel.text = model.stocksInfo
        priceShiftLabel.text = model.priceDiff
        setPrice(price: model.price, changeState: model.priceShift)
    }
    
    func setPrice(price: Double, changeState: PriceShiftState = .noDiff) {
        let priceString = price > 0 ? "+\(price)%" : "\(price)%"
        
        if changeState != .noDiff {
            priceLabel.textColor = .white
            priceView.backgroundColor = changeState == .negative ? .red : .green
        } else {
            priceView.backgroundColor = .clear
            if price == 0 {
                priceLabel.textColor = .black
            } else {
                priceLabel.textColor = price > 0 ? .green : .red
            }
        }
        
        priceLabel.text = priceString
    }
    
}
