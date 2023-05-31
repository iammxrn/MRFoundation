import Foundation

protocol Locking {
    func rd_lock()

    func rd_unlock()

    func wr_lock()

    func wr_unlock()
}
