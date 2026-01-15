//
//  ViewController.swift
//  inavi-navigation-sdk-demo
//
//  Created by DAECHEOL KIM on 1/12/26.
//

import UIKit
import iNaviNavigationSdk

class ViewController: UIViewController {

    @IBOutlet weak var contentsView: UIView!
    //    let locationManager = CLLocationManager()
    
    @IBOutlet weak var searchBar: InvSimpleSearchBar!
    @IBOutlet weak var backBt: UIButton!
    
    let con = InaviController.shared

    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let sections = ["Map", "Map Mode"]
    
    let mapItems = [
        "Driving Map",
        "Zoom In",
        "Zoom Out",
        "Geocoding",
        "Reverse Geocoding",
        "Search",
        "Run Guidance"
    ]
    
    let mapItemsDescription = [
        "Show Driving Map",
        "Zooms in one level from the current level",
        "Zooms out one level from the current level",
        "Calls the Geocoding API",
        "Calls the ReverseGeocoding API",
        "Calls the Search API",
        "Search the route and start guiding"
    ]
    
    let mapModeItems = ["General Map", "Add Marker", "Move Camera"]
    
    let mapModeItemsDescription = [
        "Display the map using InvMapView",
        "Display markers using the InvMapView API",
        "Move the map using the InvMapView API"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.backgroundColor = .white
        self.tableView.tintColor = .black
        mapInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.tableView.isHidden = false
    }
    private func mapInit() {
        con.naviInitialize(viewController: self, mapContainer: mapContainer, listener: { status in
            switch(status) {
            case .success:
                break
            case .fail(let errorMsg):
                print(errorMsg)
                break
            case .onMapReady(let mapView):
                break
            @unknown default:
                fatalError()
            }
        })
        con.setMapModeListener { status in
            switch(status) {
            case .nomal:
                self.searchBar.isHidden = false
            case .guide:
                self.searchBar.isHidden = true
            case .mapMove:
                break
            case .simuleGuide:
                self.searchBar.isHidden = true
            case .simuleMapMove:
                break
            @unknown default:
                fatalError()
            }
        }
    }
    
    private func handleMenuItem(section: Int, row: Int) {
        switch section {
        case 0: // map 섹션
            self.tableView.isHidden = true
            
            switch row {
            case 0: // Driving Map
                break
            case 1: // Zoom In
                con.zoomIn()
                break
            case 2: // Zoom Out
                con.zoomOut()
                break
            case 3: // Geocoding
                con.requestGeocoding(address: "Taipei City Hall") { status in
                    switch status {
                    case .success(let data):
                        print("Geocoding API Success: \(data)")
                    case .failure(let errorCode, let message):
                        print("Geocoding API Fail, errorCode: \(errorCode), msg: \(message)")
                    default:
                        print("Unknown")
                    }
                }
                break
            case 4: // Reverse Geocoding
                
                let invCoordinate = InvCoordinate.init(wgsLon: 121.465444, wgsLat: 25.0118520)
            
                con.requestReverseGeocoding(coordinate: invCoordinate) { status in
                    switch status {
                    case .success(let data):
                        print("Reverse Geocoding API Success: \(data)")
                    case .failure(let errorCode, let message):
                        print("Reverse Geocoding API Fail, errorcode: \(errorCode), msg: \(message)")
                    default:
                        print("Unknown")
                    }
                }
                break
            case 5: // Search
                
                let currentPosition = con.getCurrentPosition().coordinate
                let invReqSearch = InvReqSearch(query: "taipei 101", coordinate: currentPosition)
                
                con.runSearch(req: invReqSearch) { status in
                    switch status {
                    case .success(let items):
                        items.forEach { item in
                            print(
                                "Search API Success, Address, Title: \(item.mainTitle) AddrRoad: \(item.addrRoad)"
                            )
                        }
                    case .failure:
                        print("Search API Fail")
                    default:
                        print("Unknown")
                    }
                }
                 
                break
            case 6: // Run Guidance
                
                let currentPosition = con.getCurrentPosition().coordinate
                
                let startPosition = InvRoutePtItem.init(name: "Start", coordinate: currentPosition)
                let destinationPosition = InvRoutePtItem.init(name: "Destination", coordinate: InvCoordinate(wgsLon: 121.206882, wgsLat: 25.004832))
                
                con.runRoute(start: startPosition, end: destinationPosition) { status in
                    switch status {
                    case .success(let items):
                        if let id = items.first {
                            let goalInvCoordinate = InvCoordinate.init(
                                wgsLon: destinationPosition.coordinate.wgsLon,
                                wgsLat: destinationPosition.coordinate.wgsLat
                            )
                            
                            let goalSearchItem = InvSearchItem.init(coordinate: goalInvCoordinate, mainTitle: "")
                            self.con.runGuidance(searchItem: goalSearchItem, routeID: id)
                        }
                    case .failure(let errorCode, let message):
                        print("Route API Fail, errorCode: \(errorCode), msg: \(message)")
                    default:
                        print("Unknown")
                    }
                }
                break
            default: break
            }
        case 1: // map mode 섹션
            switch row {
            case 0: // 지도 (현재 뷰)
                startSampleMapView(type: EnterType.Map)
                break
            case 1: // 아이콘 추가
                startSampleMapView(type: EnterType.Marker)
                break
            case 2: // 카메라 이동
                startSampleMapView(type: EnterType.Camera)
                break
            default: break
            }
        default: break
        }
    }
    
    func startSampleMapView(type: EnterType) {
        let vc = SampleMapViewController(nibName: "SampleMapViewController", bundle: nil)
        vc.enterType = type
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return mapItems.count
        } else {
            return mapModeItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .white
        view.tintColor = .systemGray6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        
        if indexPath.section == 0 {
            cell.textLabel?.text = mapItems[indexPath.row]
            cell.detailTextLabel?.text = mapItemsDescription[indexPath.row]
        } else {
            cell.textLabel?.text = mapModeItems[indexPath.row]
            cell.detailTextLabel?.text = mapModeItemsDescription[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleMenuItem(section: indexPath.section, row: indexPath.row)
    }
}

