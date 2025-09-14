import Foundation

struct Dispatchers {
    let main = DispatchQueue.main
    let background = DispatchQueue.global(qos: .userInitiated)
}
