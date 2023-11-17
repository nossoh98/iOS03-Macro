//
//  LocationSearcher.swift
//  Macro
//
//  Created by 김나훈 on 11/15/23.
//

import Combine
import Foundation
import MacroNetwork

protocol LocationSearchUseCase {
  func searchLocation(query: String) -> AnyPublisher<[LocationDetail], NetworkError>
}

final class LocationSearcher: LocationSearchUseCase {

  private let provider: Requestable

  init(provider: Requestable) {
    self.provider = provider
  }
  
  func searchLocation(query: String) -> AnyPublisher<[LocationDetail], MacroNetwork.NetworkError> {
    return provider.request(TravelEndPoint.search(query))
  }
      
}
