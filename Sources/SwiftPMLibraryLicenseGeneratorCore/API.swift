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
        object(expression: "HEAD") {
          __typename
          ... on Commit {
            tree {
              __typename
              entries {
                __typename
                name
                type
              }
            }
          }
        }
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
          GraphQLField("object", arguments: ["expression": "HEAD"], type: .object(Object.selections)),
          GraphQLField("licenseInfo", type: .object(LicenseInfo.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(object: Object? = nil, licenseInfo: LicenseInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "Repository", "object": object.flatMap { (value: Object) -> ResultMap in value.resultMap }, "licenseInfo": licenseInfo.flatMap { (value: LicenseInfo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A Git object in the repository
      public var object: Object? {
        get {
          return (resultMap["object"] as? ResultMap).flatMap { Object(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "object")
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

      public struct Object: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Blob", "Commit", "Tag", "Tree"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["Commit": AsCommit.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeBlob() -> Object {
          return Object(unsafeResultMap: ["__typename": "Blob"])
        }

        public static func makeTag() -> Object {
          return Object(unsafeResultMap: ["__typename": "Tag"])
        }

        public static func makeTree() -> Object {
          return Object(unsafeResultMap: ["__typename": "Tree"])
        }

        public static func makeCommit(tree: AsCommit.Tree) -> Object {
          return Object(unsafeResultMap: ["__typename": "Commit", "tree": tree.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asCommit: AsCommit? {
          get {
            if !AsCommit.possibleTypes.contains(__typename) { return nil }
            return AsCommit(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsCommit: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Commit"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("tree", type: .nonNull(.object(Tree.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(tree: Tree) {
            self.init(unsafeResultMap: ["__typename": "Commit", "tree": tree.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Commit's root Tree
          public var tree: Tree {
            get {
              return Tree(unsafeResultMap: resultMap["tree"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "tree")
            }
          }

          public struct Tree: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Tree"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("entries", type: .list(.nonNull(.object(Entry.selections)))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(entries: [Entry]? = nil) {
              self.init(unsafeResultMap: ["__typename": "Tree", "entries": entries.flatMap { (value: [Entry]) -> [ResultMap] in value.map { (value: Entry) -> ResultMap in value.resultMap } }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// A list of tree entries.
            public var entries: [Entry]? {
              get {
                return (resultMap["entries"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Entry] in value.map { (value: ResultMap) -> Entry in Entry(unsafeResultMap: value) } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Entry]) -> [ResultMap] in value.map { (value: Entry) -> ResultMap in value.resultMap } }, forKey: "entries")
              }
            }

            public struct Entry: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["TreeEntry"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("name", type: .nonNull(.scalar(String.self))),
                  GraphQLField("type", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(name: String, type: String) {
                self.init(unsafeResultMap: ["__typename": "TreeEntry", "name": name, "type": type])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Entry file name.
              public var name: String {
                get {
                  return resultMap["name"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "name")
                }
              }

              /// Entry file type.
              public var type: String {
                get {
                  return resultMap["type"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "type")
                }
              }
            }
          }
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

public final class GetContentQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query getContent($owner: String!, $name: String!, $expression: String) {
      repository(owner: $owner, name: $name) {
        __typename
        object(expression: $expression) {
          __typename
          ... on Blob {
            text
          }
        }
      }
    }
    """

  public let operationName: String = "getContent"

  public var owner: String
  public var name: String
  public var expression: String?

  public init(owner: String, name: String, expression: String? = nil) {
    self.owner = owner
    self.name = name
    self.expression = expression
  }

  public var variables: GraphQLMap? {
    return ["owner": owner, "name": name, "expression": expression]
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
          GraphQLField("object", arguments: ["expression": GraphQLVariable("expression")], type: .object(Object.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(object: Object? = nil) {
        self.init(unsafeResultMap: ["__typename": "Repository", "object": object.flatMap { (value: Object) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A Git object in the repository
      public var object: Object? {
        get {
          return (resultMap["object"] as? ResultMap).flatMap { Object(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "object")
        }
      }

      public struct Object: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Blob", "Commit", "Tag", "Tree"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["Blob": AsBlob.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeCommit() -> Object {
          return Object(unsafeResultMap: ["__typename": "Commit"])
        }

        public static func makeTag() -> Object {
          return Object(unsafeResultMap: ["__typename": "Tag"])
        }

        public static func makeTree() -> Object {
          return Object(unsafeResultMap: ["__typename": "Tree"])
        }

        public static func makeBlob(text: String? = nil) -> Object {
          return Object(unsafeResultMap: ["__typename": "Blob", "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asBlob: AsBlob? {
          get {
            if !AsBlob.possibleTypes.contains(__typename) { return nil }
            return AsBlob(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsBlob: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Blob"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Blob", "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// UTF8 text data or null if the Blob is binary
          public var text: String? {
            get {
              return resultMap["text"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }
      }
    }
  }
}
