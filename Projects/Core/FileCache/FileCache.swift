import Foundation

public final class FileCache {
  private let fileManager = FileManager.default
  private let directory: String

  public init(name: String) {
    self.directory = "\(Bundle.main.bundleIdentifier ?? "")/" + (name.hasPrefix("/") ? String(name.dropFirst()) : name)
  }

  public func loadFile(path: String) throws -> Data {
    let fileURL = directoryURL.appendingPathComponent(path)
    return try Data(contentsOf: fileURL)
  }

  public func persist(data: Data, path: String) throws {
    let path = path.hasPrefix("/") ? String(path.dropFirst()) : path
    try createDirectoryIfNeeded()
    let fileURL = directoryURL.appendingPathComponent(path)
    let fileDirectoryURL = fileURL.deletingLastPathComponent()
    try createDirectoryIfNeeded(for: fileDirectoryURL)

    if fileManager.fileExists(atPath: fileURL.path) {
      try fileManager.removeItem(at: fileURL)
    }

    try data.write(to: fileURL, options: .atomic)
  }
  
  public func exists(atPath path: String) -> Bool {
    let fileURL = directoryURL.appendingPathComponent(path)
    return fileManager.fileExists(atPath: fileURL.path)
  }

  public func persist<T: Encodable>(item: T, encoder: JSONEncoder, path: String) throws {
    let data = try encoder.encode(item)
    try persist(data: data, path: path)
  }

  private func createDirectoryIfNeeded() throws {
    if fileManager.fileExists(atPath: directoryURL.path) == false {
      try fileManager.createDirectory(
        at: directoryURL,
        withIntermediateDirectories: true,
        attributes: nil
      )
    }
  }

  private func createDirectoryIfNeeded(for url: URL) throws {
    if fileManager.fileExists(atPath: url.path) == false {
      try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
  }

  private var directoryURL: URL {
    cacheDirectory().appendingPathComponent(directory)
  }

  private func cacheDirectory() -> URL {
    return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
  }
}
