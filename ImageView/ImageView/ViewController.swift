import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var imageViewSecond: UIImageView!
    let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = imageView.center
        activityIndicator.hidesWhenStopped = true
        imageView.addSubview(activityIndicator)
    }
    
    func callForSettingUiimage(image: UIImage ){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
    }
    
    func callUrlSession(completion:  (UIImage?) -> Void){
        let url = URL(string: "https://logowik.com/content/uploads/images/558_swift_logo_icon.jpg")
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                if error != nil {
                    print("Error fetching image")
                    return
                }
                
                guard let imageData = data else {
                    print("No data received")
                    return
                }
                if let image = UIImage(data: imageData) {
                 completion(ima)
                    
                } else {
                    
                }
            }
            task.resume()
            
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        activityIndicator.startAnimating()
        callUrlSession(completion: { image in
            guard let image = image else {return }
            self.callForSettingUiimage(image: image)
        })
    }
    
}
// https://jsonplaceholder.typicode.com/posts

// weak self unowned
