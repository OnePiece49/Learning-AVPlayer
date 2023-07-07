//
//  RequestPhoto.swift
//  LAS_SAMPLE_014
//
//  Created by Minh Tuan on 22/06/2023.
//

import Photos

class RequestPhotoAccess {
    static let share = RequestPhotoAccess()
    
    func requestData() -> Bool {
        var isSuccess: Bool = false
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                
                // Handle restricted or denied state
                if status == .authorized
                {
                    isSuccess = true
                }
                else {
                    isSuccess = false
                }
            }
        } else {
            isSuccess = true
        }
        return isSuccess
    }
    
    
}
