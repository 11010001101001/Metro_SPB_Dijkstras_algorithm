import UIKit
import Foundation


final class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var mapScrollView: UIScrollView!
    @IBOutlet weak var map: UIView!
    
    private lazy var menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .black
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    // MARK: building the shortest way plus launching its animation
    private lazy var builtPathbutton: UILabel = {
        let label = UILabel()
        label.text = "Построить"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.backgroundColor = .darkGray
        label.isUserInteractionEnabled = true
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(findPath))
        gesture.minimumPressDuration = .zero
        label.addGestureRecognizer(gesture)
        return label
    }()
    
    @objc private func findPath(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began,
           Singleton.pathWay.count == 2 && Singleton.graph.path.isEmpty
        {
            let fromId = Singleton.pathWay[0]
            let toId = Singleton.pathWay[1]
            Singleton.graph.dijkstrasAlgorithm(from: Vertex(data: Station(id: fromId,
                                                                          name: Singleton.graph.info[fromId]!)),
                                               to: Vertex(data: Station(id: toId,
                                                                        name: Singleton.graph.info[toId]!)))
            animatePath()
//            builtPathbutton.pulsate()
        }
    }
    private lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Сброс", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        btn.backgroundColor = .darkGray
        btn.addTarget(self,
                      action: #selector(removeAnimations),
                      for: .touchUpInside)
        return btn
    }()
    
    @objc private func removeAnimations() {
        for subview in map.subviews {
            subview.transform = .identity
        }
        if !Singleton.pathWay.isEmpty {
            for subview in map.subviews {
                subview.layer.removeAllAnimations()
            }
//            cancelButton.pulsate()
            Singleton.pathWay.removeAll()
            Singleton.graph.path.removeAll()
            Singleton.graph.detailsInfoArr.removeAll()
        }
    }
     
    private lazy var detailsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Подробнее (ಠ_ಠ)", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        btn.backgroundColor = .darkGray
        btn.addTarget(self,
                      action: #selector(showDetailsPath),
                      for: .touchUpInside)
        return btn
    }()
    
    @objc private func showDetailsPath() {
        self.navigationController?.pushViewController(DetailsViewController(),
                                                      animated: true)
//        detailsButton.pulsate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Метро СПБ"
        mapScrollView.minimumZoomScale = 1.0
        mapScrollView.maximumZoomScale = 6.0
        menuStackView.addArrangedSubview(builtPathbutton)
        menuStackView.addArrangedSubview(cancelButton)
        view.addSubview(menuStackView)
        view.addSubview(detailsButton)
        setDoubleTap()
        mapScrollView.contentInsetAdjustmentBehavior = .always
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return map
    }
    
    private func setDoubleTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(tap))
        tapGestureRecognizer.numberOfTapsRequired = 2
        map.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tap() {
        if self.mapScrollView.zoomScale == 1.0 {
            UIView.animate(withDuration: 0.25,
                           animations: {
                self.mapScrollView.zoomScale = 2.0
            })
        } else {
            UIView.animate(withDuration: 0.25,
                           animations: {
                self.mapScrollView.zoomScale = 1.0
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuStackView.frame = CGRect(x: view.bounds.minX + view.safeAreaInsets.left,
                                     y: view.bounds.height/8*6,
                                     width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
                                     height: view.bounds.height/8)
        menuStackView.setCustomSpacing(10, after: cancelButton)
        detailsButton.frame = CGRect(x: view.bounds.minX + view.safeAreaInsets.left,
                                     y: view.bounds.height/8*7,
                                     width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
                                     height: view.bounds.height/8)
        menuStackView.layer.opacity = 0.5
        detailsButton.layer.opacity = 0.5
        builtPathbutton.layer.borderWidth = 2.0
        builtPathbutton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.borderWidth = 2.0
        cancelButton.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Singleton.pathWay.removeAll()
        Singleton.graph.path.removeAll()
        Singleton.graph.detailsInfoArr.removeAll()
    }
    
    private func animatePath() {
        for view in map.subviews {
            for vertex in Singleton.graph.path {
                if vertex.data.id == view.tag {
                    if Singleton.graph.bigStationsArrIds.contains(view.tag) {
                        UIView.animate(withDuration: 0.15,
                                       delay: 0,
                                       options: [.autoreverse,.repeat,.curveEaseIn],
                                       animations: {
                            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                        }, completion: { finished in
                            view.transform = .identity
                        })
                    } else {
                        UIView.animate(withDuration: 0.15,
                                       delay: 0,
                                       options: [.autoreverse,.repeat,.curveEaseOut],
                                       animations: {
                            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                        }, completion: { finished in
                            view.transform = .identity
                        })
                    }
                }
            }
        }
    }
}

