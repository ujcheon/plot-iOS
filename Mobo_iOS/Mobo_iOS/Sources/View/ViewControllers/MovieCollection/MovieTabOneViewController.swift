//
//  MoviewTabOne.swift
//  Mobo_iOS
//
//  Created by 조경진 on 2019/12/23.
//  Copyright © 2019 조경진. All rights reserved.
//

import UIKit

class MovieTabOneViewController: UIViewController {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet var button1: UIButton!
    
    
    let movieListCellID: String = "MovieTabViewCell"
    //let movieListTwoCellID: String = "MovieTabTwoViewCell"
    
    var movies: [movieInfo] = []
    var reserveMovie : [reserveMovieInfo] = []
    var movieData: [TicketResponseString.TicketMovie.movieTicketInfo] = []
    var transitMovieData: [TicketResponseString.TicketMovie.movieTicketInfo] = []
    var selectedImage: UIImage!
    var selectedTitle: String!
    var selectedRating: Double!
    var selectedDate: String!
    let dataManager = DataManager.sharedManager
    
    var selectedIndex: [IndexPath] = []
    var GotoHome: Bool = false
    
    
    struct Storyboard {
        static let photoCell = "PhotoCell"
        static let showDetailVC = "ShowMovieDetail"
        static let leftAndRightPaddings: CGFloat = 2.0
        static let numberOfItemsPerRow: CGFloat = 3.0
    }
    
    var isRevise = false
    
    
    //init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieCollectionView.translatesAutoresizingMaskIntoConstraints = false
        movieCollectionView.showsHorizontalScrollIndicator = false
        movieCollectionView.decelerationRate = .fast
        movieCollectionView.isScrollEnabled = false
        
        GotoHome = false
        
        self.title1.text = "    예매율TOP 10" // 띄어쓰기 4 번
        self.title1.backgroundColor = .groundColor
        
        setMovieListCollectionView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //  print(isRevise)
        
        if DataManager.sharedManager.getRevise() {
            //수정 완료 버튼으로 바뀌어야함
            button1.setImage(UIImage(named: "btnTimeselect-1"), for: .normal)
        }
        else {
            
            // 시간 선택 버튼으로 바뀌어야함
            button1.setImage(UIImage(named: "btnTimeselect"), for: .normal)
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        
        reloadMovieLists()
        //et orderType: String = dataManager.getMovieOrderType()
        //            getMovieList(orderType: orderType)
        getTicketingMoiveList() { (listResponse) in
            guard let response = listResponse else {
                return
            }
            
            //   print(response)
            
        }
        
    }
    
    
    @IBAction func PickFinishBtn(_ sender: Any) {
        
        navigationSetup()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TimeTableVC") as! MovieTimeTableViewController
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        
        self.show(vc, sender: nil)
        dataManager.setMovingMovieList(list: transitMovieData)
        
        
        //self.present(vc, animated: true, completion: nil)   // 식별자 가르키는 곳으로 이동
        
        
    }
    
    func navigationSetup() { //네비게이션 투명색만들기
        
        //self.navigationController?.navigationBar.barTintColor = .mainOrange
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "btnBack")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "btnBack")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "시간 선택하기", style: .done, target: nil, action: nil)
        //           self.navigationItem.backBarButtonItem?.tintColor = .white
        //투명하게 만드는 공식처럼 기억하기
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //네비게이션바의 백그라운드색 지정. UIImage와 동일
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //shadowImage는 UIImage와 동일. 구분선 없애줌.
        self.navigationController?.navigationBar.isTranslucent = true
        //false면 반투명이다.
        
        //뷰의 배경색 지정
        
        //self.navigationController?.navigationBar.topItem?.title = "
        //        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.init(red: 211/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)]
        //        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
    }
    
    
    func getTicketingMoiveList(completion: @escaping (TicketResponseString?) -> Void) {
        
        let appUrl: String = "http://13.125.48.35:7935/movie/0"
        
        guard let finalURL = URL(string: appUrl) else {
            return
        }
        
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: finalURL)
        
        request.addValue("application/x-www-form-urlencoded" , forHTTPHeaderField: "Content-Type")
        //    request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHgiOjM3LCJpYXQiOjE1Nzc1MzEyODUsImV4cCI6MTU3ODEzNjA4NSwiaXNzIjoibW9ib21hc3RlciJ9.T1oJedjdkHFdR-ZcN47P2S72nr6LuZ2l1ptJZJHHRAc", forHTTPHeaderField: "authorization")
        
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let resultData = data else {
                // print(data)
                return
            }
            
            do {
                
                let movieTicketLists: TicketResponseString  = try JSONDecoder().decode(TicketResponseString.self, from: resultData)
                
                self.dataManager.setTicketingMoiveList(list: movieTicketLists.results.movieData)
                
                self.reloadMovieLists()
                completion(movieTicketLists)
            }
            catch let error {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
    }
    
    func reloadMovieLists() {
        
        self.movieData = dataManager.getTicketingMoiveList()
        
        DispatchQueue.main.async {
            self.movieCollectionView.reloadData()
            //        self.mainCollectionView.reloadData()
        }
    }
    
    func getTitle(title: String) -> String? {
        return title
    }
    func getRating(rating: Double) -> Double? {
        return rating
    }
    func getDate(date: String) -> String? {
        return date
    }
   
    func getGradeImage(grade: Int) -> UIImage? {
        switch grade {
        case 0:
            return UIImage(named: "ic_allages")
        case 12:
            return UIImage(named: "ic_12")
        case 15:
            return UIImage(named: "ic_15")
        case 19:
            return UIImage(named: "ic_19")
        default:
            return nil
        }
    }
    
    //    func setDefaultMovieOrderType() {
    //        let orderType: String = "0"
    //        dataManager.setMovieOrderType(orderType: orderType)
    //
    //    }
    
    func setMovieListCollectionView() {
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        
        
        movieCollectionView.backgroundColor = .groundColor
    }
    
    
    
}

extension MovieTabOneViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if indexPath == [0, 0] || indexPath == [0, 1] {
            
            return CGSize(width: 140, height: 244)
            
        }
        
        return CGSize(width: 72, height: 150)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 3
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return min(movieData.count, 2)
            
        } else if section == 1 {
            return min(max(movieData.count - 2, 0), 4)
        }
        else {
            return min(max(movieData.count - 6, 0), 4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 33, bottom: 25, right: 33)
        }
        return UIEdgeInsets(top: 5, left: 26, bottom: 0, right: 26)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if section == 0 {
            return 17
        }
        return 13
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieListCellID, for: indexPath) as! MovieCollectionTabViewCell
            
            
            let movie = movieData[indexPath.row]
            
            cell.movieName.text = movie.title
            cell.movieName.font = .boldSystemFont(ofSize: 12)
            
            cell.movieName.adjustsFontSizeToFitWidth = true
            cell.delegate = self
            
            cell.currentIndex = indexPath
            cell.rating.rating = Double((movie.userRating) / 2)
            cell.ratingLabel.text = String(describing: (movie.userRating) / 2)
            
            cell.imageThumbnail.contentMode = .scaleAspectFill
            cell.imageThumbnail.imageFromUrl(movie.thumnailImageURL, defaultImgPath: "img1-1")
            
            return cell
        }
            
            
        else if indexPath.section == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieListCellID, for: indexPath) as! MovieCollectionTabViewCell
            
            
            let movie = movieData[indexPath.row + 2]
            
            cell.movieName.text = movie.title
            cell.movieName.font = .boldSystemFont(ofSize: 10)
            cell.movieName.adjustsFontSizeToFitWidth = true
            
            //cell.dateLabel.text = movie.date
            cell.delegate = self
            cell.currentIndex = indexPath
            cell.rating.rating = Double((movie.userRating) / 2)
            cell.ratingLabel.text = String(describing: (movie.userRating) / 2)
        
            cell.imageThumbnail.contentMode = .scaleAspectFill
            cell.imageThumbnail.imageFromUrl(movie.thumnailImageURL, defaultImgPath: "img1-1")
            
            return cell
            
        }
            
            
        else if indexPath.section == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieListCellID, for: indexPath) as! MovieCollectionTabViewCell
            
            
            let movie = movieData[indexPath.row + 6]
            
            cell.movieName.text = movie.title
            cell.movieName.font = .boldSystemFont(ofSize: 10)
            cell.movieName.adjustsFontSizeToFitWidth = true
            
            //cell.dateLabel.text = movie.date
            cell.delegate = self
            cell.currentIndex = indexPath
            cell.rating.rating = Double((movie.userRating) / 2)
            cell.ratingLabel.text = String(describing: (movie.userRating) / 2)
            cell.imageThumbnail.contentMode = .scaleAspectFill
            cell.imageThumbnail.imageFromUrl(movie.thumnailImageURL, defaultImgPath: "img1-1")
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}

extension MovieTabOneViewController: MovieTabDelegate {
    
    func didMovieClicked(index: IndexPath) {
        
        if selectedIndex.contains(index) {
            
            for (i, v) in selectedIndex.enumerated() {
                if v == index {
                    selectedIndex.remove(at: i)
                }
            }
        } else {
            selectedIndex.append(index)
            selectedIndex.sort()
        }
        
        
        for indexPath in selectedIndex {
            if indexPath.section == 0 {
                
                transitMovieData.append(movieData[indexPath.item])
                
            }
            if indexPath.section == 1 {
                transitMovieData.append(movieData[indexPath.item + 2])
                
            }
            if indexPath.section == 2 {
                transitMovieData.append(movieData[indexPath.item + 6])
                
            }
        }
        
        let withoutDuplicates = Array(Set(transitMovieData))
        //hashable을 따를 수 있어서 set , array 해서 중복 제거.
        
        print("!!!!!!!")
        print(withoutDuplicates)
        print("!!!!!!!")
        
        dataManager.setMovingMovieList(list: withoutDuplicates)
        
    }
    
}
//구조체 객체에 대한 중복 제거하기위하여 hashable 을 따르게하고 set
extension TicketResponseString.TicketMovie.movieTicketInfo: Equatable {
    static func ==(lhs: TicketResponseString.TicketMovie.movieTicketInfo, rhs: TicketResponseString.TicketMovie.movieTicketInfo) -> Bool {
        return lhs.id == rhs.id &&
            lhs.thumnailImageURL == rhs.thumnailImageURL &&
            lhs.title == rhs.title && lhs.userRating == rhs.userRating
    }
}

extension TicketResponseString.TicketMovie.movieTicketInfo: Hashable {
    var hashValue: Int {
        return self.id.hashValue ^
            self.thumnailImageURL.hashValue ^
            self.title.hashValue
        self.userRating.hashValue
    }
}
