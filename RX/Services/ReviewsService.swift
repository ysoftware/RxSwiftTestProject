//
//  ReviewsService.swift
//  RX
//
//  Created by Ерохин Ярослав Игоревич on 16.12.2020.
//

import Foundation
import RxSwift

protocol IReviewsService {
    func fetchReviews(for restaurant: Restaurant) -> Observable<[Review]>
}

class ReviewsService {
    init(fileService: IFileService) {
        self.fileService = fileService
    }

    // MARK: Dependencies
    let fileService: IFileService
}

extension ReviewsService: IReviewsService {
    func fetchReviews(for restaurant: Restaurant) -> Observable<[Review]> {
        fileService
            .fetchJSON(fileName: "Reviews")
            .parseJSONIntoResponse()
            .randomlySwitchCodeToError(true)
            .handleResponse()
    }
}
