//
//  File.swift
//  bookshop_ios
//
//  Created by Alexey Smirnov on 4/13/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import Reachability

struct FileTransferInfo {
    var path : String!
    var task : URLSessionTask!
    var progress : Float
    var completionHandler : (URL) -> Void
}

class DownloadManager : NSObject, URLSessionDownloadDelegate, URLSessionDataDelegate {
    
    static let sharedInstance = DownloadManager()
    static var currentTransfers = [Int : FileTransferInfo]()
    static var delegate : DownloadView!
    
    var downloadSessionConfig : URLSessionConfiguration!
    var downloadSession : Foundation.URLSession!
    
    override init() {
        super.init()
        downloadSessionConfig = URLSessionConfiguration.default
        downloadSession = Foundation.URLSession(configuration: downloadSessionConfig, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    func createTask(_ path: String) -> URLSessionTask {
        return downloadSession.downloadTask(with: URL(string: path)!)
    }
    
    static func startTransfer(_ path: String, completionHandler: @escaping (URL) -> Void) {
        // crashes sometimes
        
        /*
        let reachability = Reachability()!
        if reachability.connection == .none {
            delegate.showInfo(title: "Ошибка", message: "Невозможно подключиться к Интернету")
            
            return
        }
 */
        
        if let _ = DownloadManager.fileTransferInfo(path) {
            return
        }
        
        let task = sharedInstance.createTask(path)
        
        let fti = FileTransferInfo(path: path,
                                   task: task,
                                   progress: 0,
                                   completionHandler: completionHandler)
        
        currentTransfers[task.taskIdentifier] = fti
        
        delegate.progressBar.isHidden = false
        delegate.progressBar.progress = 0
        
        task.resume()
    }
    
    static func fileTransferInfo(_ path: String) -> FileTransferInfo? {
        let transfer = currentTransfers.filter { $0.1.path == path }
        return transfer.count > 0 ? Array(transfer.values)[0] : nil
    }
    
    static func cancelTransfer(_ path: String) {
        guard let fti = fileTransferInfo(path) else { return }
        fti.task.cancel()
        currentTransfers.removeValue(forKey: fti.task.taskIdentifier)
        
        delegate.progressBar.isHidden = true
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {
            print("Unknown transfer size")
            return
        }
        
        let progress  = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        DownloadManager.delegate.progressBar.progress = progress
        DownloadManager.currentTransfers[downloadTask.taskIdentifier]?.progress = progress
    }
 
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let fti = DownloadManager.currentTransfers[downloadTask.taskIdentifier],
              let url = URL(string: fti.path),
              let documentDirectory:URL = urls.first else { return }

        let filename = url.lastPathComponent
        let dest = documentDirectory.appendingPathComponent(filename)
        let fileData = try? Data(contentsOf: location)
        
        do {
            try fileData?.write(to: dest, options: .noFileProtection)
            try (dest as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        DownloadManager.delegate.progressBar.isHidden = true
        DownloadManager.currentTransfers.removeValue(forKey: fti.task.taskIdentifier)
        
        fti.completionHandler(dest)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
    }
}
