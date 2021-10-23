import Apollo
import Foundation

enum APIError: Error {
  case invalid
}

class Network {
  private let accessToken: String

  private(set) lazy var client: ApolloClient = {
    let url = URL(string: "https://api.github.com/graphql")!
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = DefaultInterceptorProvider(store: store)
    let headers: [String: String] = ["User-Agent": "", "Authorization": "Bearer \(self.accessToken)"]
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                         endpointURL: url,
                                                         additionalHeaders: headers
            )
    return ApolloClient(networkTransport: transport, store: store)
  }()

  init(accessToken: String) {
    self.accessToken = accessToken
  }

  func getRepositoryLicenseConditions(
    owner: String, name: String, resultHandler: @escaping (Result<Repository, Error>) -> Void
  ) {
    self.client.fetch(query: GetRepositoryLicenseConditionsQuery(owner: owner, name: name)) {
      result in
      switch result {
      case .success(let graphQLResult):
        if let data = graphQLResult.data?.repository?.licenseInfo, let fileData = graphQLResult.data?.repository?.object?.asCommit?.tree.entries {
          let conditions: [LicenseRule] = data.conditions
            .compactMap { $0 }
            .map { LicenseRule(key: $0.key, label: $0.label, description: $0.description) }
          let licenseInfo = LicenseInfo(
            name: data.name, implementation: data.implementation, body: data.body,
            conditions: conditions)
          let files = fileData.filter({ $0.type == "blob" }).map { $0.name }
          resultHandler(.success(Repository(licenseInfo: licenseInfo, files: files)))
        } else {
          resultHandler(.failure(APIError.invalid))
        }
      case .failure(let error):
        resultHandler(.failure(error))
      }
    }
  }
  
  /**
   * @param expression "HEAD:filename" format (git revision + ":" + path)
   */
  func getContent(owner: String, name: String, expression: String, resultHandler: @escaping (Result<String, Error>) -> Void) {
    self.client.fetch(query: GetContentQuery(owner: owner, name: name, expression: expression)) { result in
      switch result {
      case .success(let graphQLResult):
        if let text = graphQLResult.data?.repository?.object?.asBlob?.text {
          resultHandler(.success(text))
        } else {
          resultHandler(.failure(APIError.invalid))
        }
      case .failure(let error):
        resultHandler(.failure(error))
      }
    }
  }
}
