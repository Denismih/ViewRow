//
//  ViewController.swift
//  CustomViewRow
//
//  Created by Mark Alldritt on 2017-09-18.
//  Copyright © 2017 Late Night Software Ltd. All rights reserved.
//

import UIKit
import Eureka
import SwiftChart


class ViewController: FormViewController {

    let initialHeight = Float(200.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form
            +++ Section("Settings")
            
                <<< SliderRow("height") { (row) in
                    row.title = "Height"
                    row.minimumValue = 150.0
                    row.maximumValue = 500.0
                    row.value = self.initialHeight
                }
                .onChange { (row) in
                    if let newHeight = row.value {
                        //(self.form.rowBy(tag: "view") as? ViewRow<ResultView>)?.cell.height = { return CGFloat(newHeight) }
                        self.tableView.reloadRows(at: [row.indexPath!], with: .none) // forces the tableview to resize the rows
                        
                        //  Alter the contents of the view in some way...
                        if let resultRow = self.form.rowBy(tag: "view") as? ViewRow<ResultView>,
                            let resultView = resultRow.view {
                            resultView.n200Label.text = "-\(Int(newHeight))-"
                            resultView.p300Label.text = "*\(Int(newHeight))*"
                        }
                    }
                }

            +++ Section("Custom View from Nib")
            
                <<< LabelRow() { (row) in
                    row.title = "A Row"
                    row.value = "Hello World"
                }
            
                <<< ViewRow<ResultView>("view") { (row) in
                }
                .cellSetup { (cell, row) in
                    //  Construct the view - in this instance the view is loaded from a nib
                    let bundle = Bundle.main
                    let nib = UINib(nibName: "ResultView", bundle: bundle)
                    
                    cell.view = nib.instantiate(withOwner: self, options: nil)[0] as? ResultView
                    cell.view?.backgroundColor = cell.backgroundColor
                    cell.contentView.addSubview(cell.view!)
                    
                    //  Define the cell's height - in this example I use the value of the height slider.
                    cell.height = { return CGFloat((self.form.rowBy(tag: "height") as? SliderRow)?.value ?? self.initialHeight) /*return CGFloat(self.initialHeight)*/ }
                }
            
                <<< LabelRow() { (row) in
                    row.title = "Another Row"
                    row.value = "Hello Again"
                }
            
            +++ Section("Custom View from code")
            
                <<< LabelRow() { (row) in
                    row.title = "A Row"
                    row.value = "Hello World"
                }
                
                <<< ViewRow<UIView>() { (row) in
                }
                .cellSetup { (cell, row) in
                    //  Construct the view - in this instance the a rudimentry view created here
                    cell.view = UIView()
                    cell.view?.backgroundColor = UIColor.orange
                    cell.contentView.addSubview(cell.view!)
                    
                    //  Define the cell's height
                    cell.height = { return CGFloat(200) }
                }
                
                <<< LabelRow() { (row) in
                    row.title = "Another Row"
                    row.value = "Hello Again"
                }

            +++ Section("Custom View with title")
            
                <<< LabelRow() { (row) in
                    row.title = "A Row"
                    row.value = "Hello World"
                }
                
                <<< ViewRow<UIView>() { (row) in
                    row.title = "Title For Custom View Row"
                }
                .cellSetup { (cell, row) in
                    //  Construct the view - in this instance the a rudimentry view created here
                    cell.view = UIView()
                    cell.view?.backgroundColor = UIColor.orange
                    cell.contentView.addSubview(cell.view!)
                    
                    //  Define the cell's height
                    cell.height = { return CGFloat(200) }
                }
                
                <<< LabelRow() { (row) in
                    row.title = "Another Row"
                    row.value = "Hello Again"
                }

            +++ Section("Custom View without margins")
            
                <<< LabelRow() { (row) in
                    row.title = "A Row"
                    row.value = "Hello World"
                }
                
                <<< ViewRow<UIView>() { (row) in
                }
                .cellSetup { (cell, row) in
                    //  Construct the view - in this instance the a rudimentry view created here
                    cell.view = UIView()
                    cell.view?.backgroundColor = UIColor.blue
                    cell.contentView.addSubview(cell.view!)
                    
                    //  Define the cell's height
                    cell.height = { return CGFloat(200) }
                    
                    //  Adjust the cell margins to suit
                    cell.viewTopMargin = 0.0
                    cell.viewBottomMargin = 0.0
                    cell.viewLeftMargin = 0.0
                    cell.viewRightMargin = 0.0
                }
                
                <<< LabelRow() { (row) in
                    row.title = "Another Row"
                    row.value = "Hello Again"
                }

            +++ Section("Graph View from code")
            
                <<< ViewRow<Chart>("graph") { (row) in
                    row.title = "Difference"
                }
                .cellSetup { (cell, row) in
                    cell.view = Chart()
                    cell.contentView.addSubview(cell.view!)
                    
                    cell.viewLeftMargin = 5.0
                    cell.viewRightMargin = 5.0
                    cell.height = { return CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 280 : 210) }
                    
                    let sampleCount = data.count
                    let msPerSample = 3.90625
                    let intervalSamples = 200.0 /* ms */ / Float(msPerSample)
                    let baseLine = 51
                    let series = ChartSeries(data.flatMap({ (v) in return Float(v) }))
                    let min = floor(data.min()!)
                    let max = ceil(data.max()!)
                    
                    var xLabelValues : [Float] = []
                    
                    for i in 0...Int(Float(sampleCount) / intervalSamples) {
                        xLabelValues.append(Float(Int(Float(i) * intervalSamples)))
                    }
                    
                    cell.view!.xLabels = xLabelValues
                    cell.view!.xLabelsFormatter = {
                        let fMsPerSample = Float(msPerSample)
                        let fBaseLine = Float(baseLine)
                        
                        return "\(Int($1 * fMsPerSample - fBaseLine * fMsPerSample + ($1 < fBaseLine ? -9.9 : 9.9)) / 10 * 10)ms"
                    }
                    cell.view!.yLabels = [Float(min), Float(max)]
                    cell.view!.yLabelsFormatter = { return "\(Int($1))µv" }
                    
                    series.area = true
                    cell.view!.add(series)
                }
    }

}


let data = [0.070964489084833882,
            -0.048904357979735191,
            -0.1723720044572967,
            -0.29294622324216057,
            -0.40291273413884754,
            -0.49660535378259602,
            -0.57394326417973529,
            -0.63305601528815569,
            -0.66227277968613163,
            -0.64649626547128958,
            -0.58019790702074803,
            -0.47134314468912963,
            -0.33689884362705835,
            -0.19877378009189761,
            -0.081094514520846095,
            -0.0030027469095452175,
            0.03070339617680462,
            0.02817153027066327,
            -0.0014309295508240782,
            -0.052760100081461425,
            -0.11791864174816352,
            -0.18312902882523724,
            -0.23452143017458366,
            -0.26509389636842751,
            -0.27481530899561091,
            -0.26458184940674068,
            -0.23297926724444629,
            -0.18000347743282105,
            -0.10969567623694657,
            -0.027807946330716177,
            0.058562487343914893,
            0.13880734048357751,
            0.20112245993732547,
            0.23974099036501251,
            0.25975998904225084,
            0.27281410177114196,
            0.28842839044969204,
            0.31210604077934118,
            0.34656970418235389,
            0.38790242675856695,
            0.42471948185781927,
            0.44685589700106709,
            0.45287727119871646,
            0.44801737710910206,
            0.43741719850368155,
            0.42351858577914681,
            0.41101532831314369,
            0.41099738358082166,
            0.43438905400080641,
            0.48098974382366128,
            0.53910681966770679,
            0.59610151244310683,
            0.64491084834146295,
            0.68141518401871082,
            0.70264535898025804,
            0.70763798271752631,
            0.69319613454444973,
            0.64833177136609432,
            0.55890848567925744,
            0.4209150195441842,
            0.24669677392353093,
            0.056264623225106405,
            -0.13275293071788868,
            -0.30415031414401411,
            -0.4401982842724923,
            -0.52716063610803854,
            -0.56209329680398112,
            -0.54949807409352425,
            -0.49306767939671681,
            -0.39615602410434847,
            -0.26803288962944033,
            -0.12317295655925309,
            0.025690175758792955,
            0.17122843482362704,
            0.31045560685633056,
            0.44415383745985604,
            0.57784617432747309,
            0.71986695070454598,
            0.8742153523750853,
            1.0351428289041835,
            1.1922671759025156,
            1.340390441381109,
            1.4805566240577563,
            1.6134250915252182,
            1.7365594602571561,
            1.8478652540337663,
            1.9479251530874793,
            2.0377686390174592,
            2.1174711715439178,
            2.1891534741831751,
            2.2577534533840202,
            2.3278080826444771,
            2.4042536932270528,
            2.4956394223434097,
            2.6116362150042227,
            2.7574241832455018,
            2.9314252417281663,
            3.1265800390927891,
            3.3316402402043703,
            3.5296086573591023,
            3.6969381389676106,
            3.8104462540751958,
            3.8581325101649417,
            3.8423924901909094,
            3.7760453309977322,
            3.6803250529311873,
            3.5820459873418939,
            3.5017345379128257,
            3.4402988888880648,
            3.3798468135541819,
            3.2983435400475805,
            3.1818437095032848,
            3.0254006471862582,
            2.8306968933684145,
            2.6078473941632114,
            2.3755943254654541,
            2.1541263177227208,
            1.9567011819674072,
            1.7869845431011924,
            1.6402519508132656,
            1.5048112693215323,
            1.3650651605799049,
            1.2097196101997103,
            1.0397667588690047,
            0.86467688619596694,
            0.69044918463865645,
            0.51627040421419623,
            0.34294049715928998,
            0.17860346079794653,
            0.031842233653120333,
            -0.09659160197805805,
            -0.20725561020254113,
            -0.29120135625324828,
            -0.33534134738593457,
            -0.33585337952573469,
            -0.30099693565532148,
            -0.24509383905053417,
            -0.1841844077710395,
            -0.13579971651419165,
            -0.11650070878614727,
            -0.1336802553719747,
            -0.18146371086572688,
            -0.24808796160030033,
            -0.32422719286636847,
            -0.40252672111759497,
            -0.47548200942302182,
            -0.53858687760519375,
            -0.59258291099656579,
            -0.63977774521573993,
            -0.68046860339075854,
            -0.71586507847385206,
            -0.75296559522091999,
            -0.80199375121928184,
            -0.86857446692019824,
            -0.95300430349654641,
            -1.0565721431528103,
            -1.180019029960635,
            -1.3129405604297713,
            -1.4326717174211996,
            -1.5173464053526209,
            -1.5543042157151015,
            -1.5358159095685384,
            -1.4564151161744787,
            -1.3189667838386372,
            -1.1378520228517965,
            -0.93178726623190211,
            -0.7152156290177647,
            -0.49835471920432406,
            -0.29391015784800578,
            -0.1191065088975154,
            0.012754024487588445,
            0.10005234826630938,
            0.14903279360278676,
            0.16606157016444756,
            0.15719323716700495,
            0.1316144721417517,
            0.099134629042738287,
            0.063611590653063654,
            0.023102248543412474,
            -0.023927174049925615,
            -0.078436094665817302,
            -0.14725924910432786,
            -0.24212509621942085,
            -0.36712050020037001,
            -0.51019008637757568,
            -0.65034411311068596,
            -0.76986301516994704,
            -0.8567504674317632,
            -0.90072903837177065,
            -0.89378907125192275,
            -0.83406139681108859,
            -0.7247288103010594,
            -0.57090788548299454,
            -0.3824220300025199,
            -0.17740661742153349,
            0.020982791246436483,
            0.18995299707811339,
            0.309323472891401,
            0.3645679201818024,
            0.35253247306627533,
            0.28450188258333275,
            0.18197475295451518,
            0.066733260976017436,
            -0.045896748775864582,
            -0.14454769692565592
]

