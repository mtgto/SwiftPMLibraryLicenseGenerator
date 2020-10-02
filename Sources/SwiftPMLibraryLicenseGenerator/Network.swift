import Foundation
import Apollo

struct LicenseInfo {
  let name: String
  let implementation: String?
  let body: String
  let conditions: [LicenseRule]
}

struct LicenseRule {
  let key: String
  let label: String
  let description: String
}

enum APIError: Error {
  case invalid
}

class Network {
  private let accessToken: String
  
  private lazy var networkTransport: RequestChainNetworkTransport = {
    let cache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: cache)
    let client = URLSessionClient()
    let interceptorProvider = GitHubInterceptorProvider(store: store, client: client)
    let headers = [
      "User-Agent": "SwiftPMLibraryLicenseGenerator/1.0.0", "Authorization": "Bearer \(self.accessToken)",
    ]
    let transport = RequestChainNetworkTransport(
      interceptorProvider: interceptorProvider,
      endpointURL: URL(string: "https://api.github.com/graphql")!, additionalHeaders: headers)
    return transport
  }()
    
  private(set) lazy var client = ApolloClient(networkTransport: self.networkTransport)
  
  init(accessToken: String) {
    self.accessToken = accessToken
  }
  
  func getRepositoryLicenseConditions(owner: String, name: String, resultHandler: @escaping (Result<LicenseInfo, Error>) -> Void) {
    self.client.fetch(query: GetRepositoryLicenseConditionsQuery(owner: owner, name: name)) { result in
      switch result {
      case .success(let graphQLResult):
        debugPrint("Result: \(graphQLResult)")
        if let data = graphQLResult.data?.repository?.licenseInfo {
          let conditions: [LicenseRule] = data.conditions
            .compactMap { $0 }
            .map { LicenseRule(key: $0.key, label: $0.label, description: $0.description) }
          let licenseInfo = LicenseInfo(name: data.name, implementation: data.implementation, body: data.body, conditions: conditions)
          resultHandler(.success(licenseInfo))
        } else {
          resultHandler(.failure(APIError.invalid))
        }
      case .failure(let error):
        print("Error: \(error)")
        resultHandler(.failure(error))
      }
    }
  }
}

class GitHubInterceptorProvider: InterceptorProvider {
  private let store: ApolloStore
  private let client: URLSessionClient

  init(
    store: ApolloStore,
    client: URLSessionClient
  ) {
    self.store = store
    self.client = client
  }

  func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] {
    return [
      MaxRetryInterceptor(),
      LegacyCacheReadInterceptor(store: self.store),
      NetworkFetchInterceptor(client: self.client),
      GitHubResponseInterceptor(),
      ResponseCodeInterceptor(),
      LegacyParsingInterceptor(cacheKeyForObject: self.store.cacheKeyForObject),
      AutomaticPersistedQueryInterceptor(),
      LegacyCacheWriteInterceptor(store: self.store),
    ]
  }
}

class GitHubResponseInterceptor: ApolloInterceptor {
  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    chain.proceedAsync(
      request: request,
      response: response,
      completion: completion)
  }
}
