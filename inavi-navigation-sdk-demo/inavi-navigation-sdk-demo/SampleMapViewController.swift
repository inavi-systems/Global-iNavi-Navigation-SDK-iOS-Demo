//
//  SampleMapViewController.swift
//  inavi-navigation-sdk-demo
//
//  Created by DAECHEOL KIM on 1/14/26.
//

import UIKit
import iNaviNavigationSdk

enum EnterType {
    case Map
    case Marker
    case Camera
}

class SampleMapViewController: UIViewController {

    @IBOutlet weak var mapView: InvMapView!
    @IBOutlet weak var action: UIButton!
    
    var isInitPosition = true
    var enterType: EnterType?
    
    @IBAction func onActionButton(_ sender: UIButton) {
        guard let type = enterType else { return }
        switch type {
        case .Map:
            break
        case .Marker:
            break
        case .Camera:
            if (!isInitPosition) {
                mapView.setMapCenter(longitude: 121.465444, latitude: 25.0118520)
            } else {
                mapView.setMapCenter(longitude: 121.431329, latitude: 25.0292831)
            }
            isInitPosition = !isInitPosition
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.setMapCenter(longitude: 121.465444, latitude: 25.0118520)
        
        guard let type = enterType else { return }
        switch type {
        case .Map:
            break
        case .Marker:
            let coordinates: [(Double, Double)] = [
                (121.465444, 25.0118520),
                (121.466444, 25.0139520),
                (121.467444, 25.0117520),
                (121.463444, 25.0126520)
            ]
            
            let markerOptions = coordinates.compactMap { (longitude, latitude) -> InvMapMarkerOption? in
                guard let image = UIImage(named: "inv_map_pin") else {
                    print("Error: Image not found")
                    return nil
                }
                
                return InvMapMarkerOption(
                    coordinate: InvCoordinate(wgsLon: longitude, wgsLat: latitude),
                    iconImage: image
                )
            }
            
            markerOptions.forEach { option in
                self.mapView.addMarker(mapMarkerOption: option)
            }
            break
        case .Camera:
            action.setTitle("Move Camera", for: .normal)
            action.isHidden = false
            break
        }
    }


    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
