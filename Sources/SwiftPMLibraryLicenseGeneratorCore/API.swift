// swift-format-ignore-file
// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class GetRepositoryLicenseConditionsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query getRepositoryLicenseConditions($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        __typename
        licenseInfo {
          __typename
          name
          conditions {
            __typename
            description
            key
            label
          }
          implementation
          body
        }
      }
    }
    """

  public let operationName: String = "getRepositoryLicenseConditions"

  public var owner: String
  public var name: String

  public init(owner: String, name: String) {
    self.owner = owner
    self.name = name
  }

  public var variables: GraphQLMap? {
    return ["owner": owner, "name": name]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("repository", arguments: ["owner": GraphQLVariable("owner"), "name": GraphQLVariable("name")], type: .object(Repository.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(repository: Repository? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "repository": repository.flatMap { (value: Repository) -> ResultMap in value.resultMap }])
    }

    /// Lookup a given repository by the owner and repository name.
    public var repository: Repository? {
      get {
        return (resultMap["repository"] as? ResultMap).flatMap { Repository(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "repository")
      }
    }

    public struct Repository: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Repository"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("licenseInfo", type: .object(LicenseInfo.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(licenseInfo: LicenseInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "Repository", "licenseInfo": licenseInfo.flatMap { (value: LicenseInfo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The license associated with the repository
      public var licenseInfo: LicenseInfo? {
        get {
          return (resultMap["licenseInfo"] as? ResultMap).flatMap { LicenseInfo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "licenseInfo")
        }
      }

      public struct LicenseInfo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["License"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("conditions", type: .nonNull(.list(.object(Condition.selections)))),
            GraphQLField("implementation", type: .scalar(String.self)),
            GraphQLField("body", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, conditions: [Condition?], implementation: String? = nil, body: String) {
          self.init(unsafeResultMap: ["__typename": "License", "name": name, "conditions": conditions.map { (value: Condition?) -> ResultMap? in value.flatMap { (value: Condition) -> ResultMap in value.resultMap } }, "implementation": implementation, "body": body])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The license full name specified by <https://spdx.org/licenses>
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// The conditions set by the license
        public var conditions: [Condition?] {
          get {
            return (resultMap["conditions"] as! [ResultMap?]).map { (value: ResultMap?) -> Condition? in value.flatMap { (value: ResultMap) -> Condition in Condition(unsafeResultMap: value) } }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Condition?) -> ResultMap? in value.flatMap { (value: Condition) -> ResultMap in value.resultMap } }, forKey: "conditions")
          }
        }

        /// Instructions on how to implement the license
        public var implementation: String? {
          get {
            return resultMap["implementation"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "implementation")
          }
        }

        /// The full text of the license
        public var body: String {
          get {
            return resultMap["body"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "body")
          }
        }

        public struct Condition: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["LicenseRule"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("description", type: .nonNull(.scalar(String.self))),
              GraphQLField("key", type: .nonNull(.scalar(String.self))),
              GraphQLField("label", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(description: String, key: String, label: String) {
            self.init(unsafeResultMap: ["__typename": "LicenseRule", "description": description, "key": key, "label": label])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A description of the rule
          public var description: String {
            get {
              return resultMap["description"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          /// The machine-readable rule key
          public var key: String {
            get {
              return resultMap["key"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "key")
            }
          }

          /// The human-readable rule label
          public var label: String {
            get {
              return resultMap["label"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "label")
            }
          }
        }
      }
    }
  }
}
