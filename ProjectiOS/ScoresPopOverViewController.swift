//
//  ScoresPopOverViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 28/02/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit
import Charts

class ScoresPopOverViewController: UIViewController {

    var votes: [(score: Int, votes: Int)]!
    @IBOutlet weak var scoresBarChart: BarChartView!
    @IBAction func closePopOver(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tapOutsideBox(_ sender: Any) {
        closePopOver(sender)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scoresBarChart.noDataText = "No scores available"
        var chartData = [BarChartDataEntry]()
        for score in votes {
            let scoreAndVotes = BarChartDataEntry.init(x: Double(score.score), y: Double(score.votes))
            chartData.append(scoreAndVotes)
        }
        let dataSet = BarChartDataSet.init(values: chartData, label: nil)
        dataSet.barBorderColor = UIColor.white
//        dataSet.setColors(<#T##colors: NSUIColor...##NSUIColor#>)
//        dataSet.colors = [
//            NSUIColor.init(red: 0, green: 255, blue: 0, alpha: 1),
//            NSUIColor.init(red: 51, green: 255, blue: 0, alpha: 1),
//            NSUIColor.init(red: 102, green: 255, blue: 0, alpha: 1),
//            NSUIColor.init(red: 153, green: 255, blue: 0, alpha: 1),
//            NSUIColor.init(red: 204, green: 255, blue: 0, alpha: 1),
//            NSUIColor.init(red: 255, green: 255, blue: 0, alpha: 1),
//            NSUIColor.init(red: 255, green: 204, blue: 0, alpha: 1),
//            NSUIColor.init(red: 255, green: 153, blue: 0, alpha: 1),
//            NSUIColor.init(red: 255, green: 102, blue: 0, alpha: 1),
//            NSUIColor.init(red: 255, green: 51, blue: 0, alpha: 1)
//        ]
//        dataSet.setColors(NSUIColor.init(red: 0, green: 255, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 51, green: 255, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 102, green: 255, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 153, green: 255, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 204, green: 255, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 255, green: 255, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 255, green: 204, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 255, green: 153, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 255, green: 102, blue: 0, alpha: 1),
//                          NSUIColor.init(red: 255, green: 51, blue: 0, alpha: 1))
        let data = BarChartData.init(dataSets: [dataSet]);
        scoresBarChart.data = data
        scoresBarChart.legend.enabled = false
        scoresBarChart.xAxis.labelPosition = .bottom
        scoresBarChart.xAxis.labelCount = 10
        scoresBarChart.leftAxis.drawLabelsEnabled = false
        scoresBarChart.rightAxis.drawLabelsEnabled = false
        scoresBarChart.chartDescription = nil
        scoresBarChart.fitBars = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
