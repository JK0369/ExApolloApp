//
//  Network.swift
//  ExApolloApp
//
//  Created by Jake.K on 2022/03/04.
//

import Apollo

class Network {
  static let shared = Network()
  let apollo = ApolloClient(url: URL(string: "https://apollo-fullstack-tutorial.herokuapp.com/graphql")!)
  
  private init() {}
}
