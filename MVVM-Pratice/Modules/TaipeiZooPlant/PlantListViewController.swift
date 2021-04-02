//
//  PlantListViewController.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class PlantListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customNavitaonBarView: UIView!
    @IBOutlet weak var cutomNavigationBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var smallContnetLabel: UILabel!
    @IBOutlet weak var bigContnetLabel: UILabel!
    
    var viewModel: ViewModel! = ViewModel(networkService: TaipeiZooAPIService.share)
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bindViewModel()
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        cutomNavigationBarHeightConstraint.constant = CustomNavigationViewStyle.NavigationAndStatusBarHeight
        self.tableView.register(UINib(nibName: "PlantTableViewCell", bundle: nil), forCellReuseIdentifier: "PlantTableViewCell")
        
        self.tableView.mj_header = MJRefreshNormalHeader()
        self.tableView.mj_footer = MJRefreshBackNormalFooter()
        self.tableView.contentInset = UIEdgeInsets(top: 200.0, left: 0, bottom: 0, right: 0)
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        
        // observe scrolling event
        let scrollingEvent = tableView.rx.contentOffset
            .map { (contentOffset) -> (CGPoint, CGRect) in
                return (contentOffset, self.customNavitaonBarView.frame)
            }
        
        // In order to observe scroll view stopped,
        // merge didEndDragging and didEndDecelerating to observe both event.
        //
        let didEndScroll = Observable.merge(tableView.rx.didEndDragging.mapToVoid(), tableView.rx.didEndDecelerating.mapToVoid())
            .map({ (_) -> CGRect in
                return self.customNavitaonBarView.frame
            })
        
        
        let input = ViewModel.Input(headerRefresh: self.tableView.mj_header!.rx.refreshing.asDriver(),
                                    footerRefresh: self.tableView.mj_footer!.rx.refreshing.asDriver(), scrollingEvent: scrollingEvent, didEndScroll: didEndScroll)
        let output = viewModel.transform(input: input)
        
        //bind data
        output.tableData
            .drive(tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlantTableViewCell") as! PlantTableViewCell
                cell.setupCell(plant: element)
                return cell
            }
            .disposed(by: disposeBag)

        // bind customNavitaonBarView.rx.frame
        output.customNavigationBarFrame
            .drive(customNavitaonBarView.rx.frame)
            .disposed(by: disposeBag)
        
        // bind adjust tableview contentOffset
        output.adjustTableViewContentOffsetY
            .drive(onNext: { (newY) in
                if let y = newY {
                    UIView.animate(withDuration: 0.3) {
                        self.tableView.contentOffset.y = y
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // binding content labels alpha
        output.adjustConetntLabelsAlpha
            .drive(onNext: { smallAlpha, bigAlpha in
                self.bigContnetLabel.alpha = bigAlpha
                self.smallContnetLabel.alpha = smallAlpha
            })
            .disposed(by: disposeBag)
        
        // binding ending sequence to header refresh
        output.endHeaderRefreshing
            .drive(self.tableView.mj_header!.rx.endRefreshing)
            .disposed(by: disposeBag)

        // binding ending sequence to footer refresh
        output.endFooterRefreshing
            .drive(self.tableView.mj_footer!.rx.endRefreshing)
            .disposed(by: disposeBag)
        
    }

}
