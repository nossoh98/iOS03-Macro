//
//  SearchResultViewController.swift
//  Macro
//
//  Created by 김나훈 on 11/16/23.
//

import Combine
import UIKit

final class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // MARK: - Properties
  
  private var locationDetails: [LocationDetail]
  private var tableView: UITableView!
  private let viewModel: TravelViewModel
  private let inputSubject: PassthroughSubject<TravelViewModel.Input, Never> = .init()
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Life Cycles
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupTableView()
    bind()
  }
  
  // MARK: - Init
  
  init(locationDetails: [LocationDetail], viewModel: TravelViewModel) {
    self.locationDetails = locationDetails
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UI Settings
  
  private func setupTableView() {
    tableView = UITableView()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
    ])
  }
  
  // MARK: - Bind
  
  private func bind() {
    viewModel.transform(with: inputSubject.eraseToAnyPublisher())
      .sink { _ in
        // TODO: implements 
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Methods
  
  @objc func pinLocation(_ sender: UIButton) {
    let locationDetail = locationDetails[sender.tag]
    inputSubject.send(.addPinnedLocation(locationDetail))
  }
}

// MARK: - TableView

extension SearchResultViewController {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locationDetails.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let locationDetail = locationDetails[indexPath.row]
    cell.textLabel?.text = locationDetail.title
    let pinButton = UIButton(type: .custom)
    pinButton.setImage(UIImage(systemName: "pin"), for: .normal)
    pinButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    pinButton.addTarget(self, action: #selector(pinLocation(_:)), for: .touchUpInside)
    cell.accessoryView = pinButton
    pinButton.tag = indexPath.row
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // TODO: 테이블 뷰가 눌리면, 경로추천 segment 실행
  }
}
