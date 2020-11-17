//
//  TodayPageViewController.swift
//  VoidMind
//
//  Created by Ziyao Zhou on 11/16/20.
//

import UIKit

class TodayPageViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func triggerDownload() {
        fetchData() { [weak self] response in
            if response != nil, self != nil {
                self?.textView.text = response?.answer
                if response?.image == nil {
                    return
                }
                self?.imageView.downloaded(from: response?.image ?? "", contentMode: UIView.ContentMode.scaleToFill)
            }
        }
    }
    
    private func fetchData(completion: @escaping (Response?)->Void) {
        
        let headers = [
            "x-rapidapi-key": "64d0818b24msh0ba501609f85b17p1b7a98jsnc2354a2e4d0d",
            "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/quickAnswer?q=How%20much%20vitamin%20c%20is%20in%202%20apples%3F")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error in Data Fetching")
                return
            }
            
            var result: Response?
            do {
                result = try JSONDecoder().decode(Response.self, from: data)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            catch {
                print("fail to convert")
            }
        })
        dataTask.resume()
    } 
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

struct Response : Codable {
    let answer : String
    let image : String
    let type : String
}

//struct Response : Codable {
//    let todayInfo : TodayInfo
//    let status : String
//}
//
//struct TodayInfo : Codable{
//    let mood : String
//}
