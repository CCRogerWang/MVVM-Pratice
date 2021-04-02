//
//  PlantListViewModel.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import Foundation
import RxSwift
import RxCocoa
import MJRefresh


class ViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    
    struct Input {
        
        /// pull to refresh stream
        let headerRefresh: Driver<Void>
        
        /// load more stream
        let footerRefresh: Driver<Void>
        
        /// scrolling stream: contentOffset, self.customNavitaonBarView.frame
        let scrollingEvent: Observable<(CGPoint, CGRect?)>
        
        /// stop scroll stream
        let didEndScroll: Observable<CGRect?>
    }
    
    struct Output {
        let tableData: Driver<[Plant]>
        let endHeaderRefreshing: Driver<Bool>
        let endFooterRefreshing: Driver<Bool>
        
        /// NavigationBar Frame
        let customNavigationBarFrame: Driver<CGRect?>
        
        /// contentOffsetY?
        let adjustTableViewContentOffsetY: Driver<CGFloat?>
        
        /// conent labels alpha
        let adjustConetntLabelsAlpha: Driver<(CGFloat?, CGFloat?)>
    }
    
    let tableData = BehaviorRelay<[Plant]>(value: [])
    
    private var offset: Int = 0
    private let limit: Int = 20
    private let networkService: TaipeiZooPlantAPIs
    
    init(networkService: TaipeiZooPlantAPIs) {
        self.networkService = networkService
    }
    
    func transform(input: Input) -> Output {
        let headerRefreshData = input.headerRefresh
            .startWith(()) // loading data when init
            .flatMapLatest{
                return self.networkService.getPlantList(limit: self.limit)
            }
        
        // loadMore
        let footerRefreshData = input.footerRefresh
            .flatMapLatest{
                return self.networkService.getPlantList(offset: self.offset, limit: self.limit)
            }
        
        // pull to refresh
        headerRefreshData
            .drive(onNext: refreshUpdateData)
            .disposed(by: disposeBag)
        
        
        footerRefreshData
            .drive(onNext: updateData)
            .disposed(by: disposeBag)
            
        
        // create stop sequence to header
        let endHeaderRefreshing = headerRefreshData.map{ _ in true }
        
        // create stop sequence to footer
        let endFooterRefreshing = footerRefreshData.map{ _ in true }
        
        let navigationViewFrameObsever = input.scrollingEvent
            .map(getCustomNavigationFrame)
        
        // create custom navigation view frame
        let navigationViewFrame = navigationViewFrameObsever
            .asDriverOnErrorJustComplete()
        
        // did end dragging
        let adjustTableViewContnetOffsetY = input.didEndScroll
            .map(getAdjustY)
            .asDriver(onErrorJustReturn: nil)
        
        // create labels alpha
        let labelsAlptha = navigationViewFrameObsever
            .map(getContentLabelsAlpha)
            .asDriverOnErrorJustComplete()
        
        // create Output
        return Output(tableData: self.tableData.asDriver(),
                      endHeaderRefreshing: endHeaderRefreshing,
                      endFooterRefreshing: endFooterRefreshing,
                      customNavigationBarFrame: navigationViewFrame,
                      adjustTableViewContentOffsetY: adjustTableViewContnetOffsetY,
                      adjustConetntLabelsAlpha: labelsAlptha)
        
        
        
    }
    
    /// init or pull to update Data
    /// - Parameter list: PlantList
    func refreshUpdateData(list: PlantList) {
        tableData.accept(list.results)
        offset += limit
    }
    
    /// load more data process
    ///
    /// - Parameter result: PlantList
    func updateData(result: PlantList) {
        if result.count > tableData.value.count {
            self.tableData.accept(self.tableData.value + result.results )
            self.offset = result.offset + limit
        } else {
            print("沒資料了")
        }
    }
    
    func getCustomNavigationFrame(contentOffset: CGPoint, frame: CGRect?) -> CGRect? {
        guard let f = frame else {
            return nil
        }
        var frame = f
        // default is -200. scroll up > -200, scroll down < -200
        
        /*
         -200 + 200 = 0
         -180 + 200 = 20
         -220 + 200 = -20
         */
        var newY = contentOffset.y * -1 - 200


        if newY > CustomNavigationViewStyle.bigCustomNavigationViewY {
            newY = CustomNavigationViewStyle.bigCustomNavigationViewY
        }
        
        if newY < CustomNavigationViewStyle.smallCustomNavigationViewY {
            newY = CustomNavigationViewStyle.smallCustomNavigationViewY
        }
        
        frame.origin.y = newY
        
        return frame
    }
    
    func getAdjustY(frame: CGRect?) -> CGFloat? {
        guard let f = frame else {
            return nil
        }
        let newFrame = f
        if newFrame.origin.y < CustomNavigationViewStyle.threshold && newFrame.origin.y != CustomNavigationViewStyle.smallCustomNavigationViewY {
            return CustomNavigationViewStyle.small.tableViewContentSizeY
        }
        
        if newFrame.origin.y >= CustomNavigationViewStyle.threshold && newFrame.origin.y != CustomNavigationViewStyle.bigCustomNavigationViewY{
            return CustomNavigationViewStyle.big.tableViewContentSizeY
        }
        return nil
    }
    
    func getContentLabelsAlpha(frame: CGRect?) -> (CGFloat?, CGFloat?) {
        guard let f = frame else {
            return (nil, nil)
        }
        //  0 to -156
        // B 1.0 to 0.0
        // S 1 - B to 1 - B
        let bigContentLabelAlpha =  (f.origin.y + 156) / 156.0
        let smallContentLabelAlpha = 1 - bigContentLabelAlpha
        return (smallContentLabelAlpha, bigContentLabelAlpha)
    }
}
