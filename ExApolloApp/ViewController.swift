//
//  ViewController.swift
//  ExApolloApp
//
//  Created by Jake.K on 2022/03/04.
//

import UIKit
import SnapKit
import Kingfisher
import Apollo

final class ViewController: UIViewController {
  private let tableView: UITableView = {
    let view = UITableView()
    return view
  }()
  
  private var dataSource = [LaunchListQuery.Data.Launch.Launch]()
  private var lastConnection: LaunchListQuery.Data.Launch?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "리스트"
    self.view.addSubview(self.tableView)
    self.tableView.register(LaunchListCell.self, forCellReuseIdentifier: "LaunchListCell")
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    self.loadMoreLaunchesIfTheyExist()
  }
  
  private func loadMoreLaunchesIfTheyExist() {
    guard let connection = self.lastConnection else {
      self.loadMoreLaunches(from: nil)
      return
    }
    guard connection.hasMore else { return }
      
    self.loadMoreLaunches(from: connection.cursor)
  }
  private func loadMoreLaunches(from cursor: String?) {
    Network.shared.apollo.fetch(query: LaunchListQuery(cursor: cursor)) { [weak self] result in
      guard let ss = self else { return }
      defer { ss.tableView.reloadData() }
      
      switch result {
      case .success(let graphQLResult):
        if let launchConnection = graphQLResult.data?.launches {
          ss.lastConnection = launchConnection
          ss.dataSource.append(contentsOf: launchConnection.launches.compactMap { $0 })
        }
      
        if let errors = graphQLResult.errors {
          let message = errors
                          .map { $0.localizedDescription }
                          .joined(separator: "\n")
          print(message)
      }
      case .failure(let error):
        print("network error - \(error)")
      }
    }
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    self.dataSource.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchListCell", for: indexPath) as! LaunchListCell
    let data = self.dataSource[indexPath.row]
    cell.prepare(
      imageUrlString: data.mission?.missionPatch,
      preferredSize: LaunchListCell.Constants.imageSize,
      title: data.mission?.name,
      desc: data.site
    )
    return cell
  }
}

extension ViewController: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentHeight = scrollView.contentSize.height
    let yOffset = scrollView.contentOffset.y
    let heightRemainBottomHeight = contentHeight - yOffset

    let frameHeight = scrollView.frame.size.height
    if heightRemainBottomHeight < frameHeight {
      self.loadMoreLaunchesIfTheyExist()
    }
  }
}

enum ListSection: Int, CaseIterable {
  case launches
  case loading
}

final class LaunchListCell: UITableViewCell {
  enum Constants {
    static let imageSize = CGSize(width: 40, height: 40)
  }
  
  private let thumbnailImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFill
    return view
  }()
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14)
    label.textColor = .label
    return label
  }()
  private let descLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    label.textColor = .secondaryLabel
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.contentView.addSubview(self.thumbnailImageView)
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.descLabel)
    
    self.thumbnailImageView.snp.makeConstraints {
      $0.top.left.equalToSuperview()
      $0.size.equalTo(Constants.imageSize)
      $0.bottom.lessThanOrEqualToSuperview()
    }
    self.titleLabel.snp.makeConstraints {
      $0.top.equalTo(self.thumbnailImageView)
      $0.left.equalTo(self.thumbnailImageView.snp.right)
      $0.right.lessThanOrEqualTo(12)
    }
    self.descLabel.snp.makeConstraints {
      $0.top.equalTo(self.titleLabel.snp.bottom)
      $0.left.equalTo(self.thumbnailImageView.snp.right)
      $0.bottom.lessThanOrEqualToSuperview()
      $0.right.lessThanOrEqualTo(12)
    }
  }
  required init?(coder: NSCoder) { fatalError() }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.prepare(imageUrlString: nil, preferredSize: .zero, title: nil, desc: nil)
  }
  func prepare(imageUrlString: String?, preferredSize: CGSize, title: String?, desc: String?) {
    self.thumbnailImageView.image = nil
    if
      let imageUrlString = imageUrlString,
      let url = URL(string: imageUrlString)
    {
      self.thumbnailImageView.kf.setImage(
        with: url,
        placeholder: UIImage(named: "placeholder"),
        options: [
          .processor(DownsamplingImageProcessor(size: preferredSize)),
          .progressiveJPEG(ImageProgressive(isBlur: false, isFastestScan: true, scanInterval: 0.1))
        ],
        completionHandler: { result in
          print(result)
        }
      )
    }

    self.titleLabel.text = title
    self.descLabel.text = desc
  }
}
