import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// Errors making a request to Rarible.
enum RaribleRequestError: Error  {
  case MalformedURL
}

// Objects that want to issue a Rarible request.
protocol RaribleRequest {
  associatedtype T: Decodable

  var host:String { get }
  var url:URL? { get }

  var path:String { get }
  var queryParams:[URLQueryItem] { get }

  func send() async throws -> T

}

// Extension for default implementations.
extension RaribleRequest {
  var host:String {
    "https://api-staging.rarible.org"
  }
  var url:URL? {
    URL(string: "\(host)\(path)")
  }

  func send() async throws -> T {
    guard var url = url else { throw RaribleRequestError.MalformedURL }
    url.append(queryItems: queryParams)
    let (response, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(T.self, from: response)
  }
}

// A model representing a Rarible item.
struct RaribleItem {
  let id: String
}

// Extension that decodes a Rarible item with a decoder.
extension RaribleItem: Decodable {

  private enum Key: String, CodingKey {
    case id = "id"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    self.id = try container.decode(String.self, forKey: .id)
  }
}

struct RaribleItemsByCollectionResponse {
  let items: [RaribleItem]
}

extension RaribleItemsByCollectionResponse: Decodable {
  private enum Key: String, CodingKey {
    case items = "items"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    self.items = try container.decode([RaribleItem].self, forKey: .items)
  }
}

class RaribleItemsByCollectionRequest: RaribleRequest {
  typealias T = RaribleItemsByCollectionResponse
  
  var path:String {
    "/v0.1/items/byCollection"
  }

  var queryParams:[URLQueryItem]  {
    [ URLQueryItem(name: "collection", value: "TEZOS:KT18far4C9Hvs7uHi2KzzRZF8f9EX5dhcVQP") ]
  }
}

let response = try await RaribleItemsByCollectionRequest().send()
print("\(response)")
