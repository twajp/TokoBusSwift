import Foundation

class MakeTimetable : ObservableObject{
    var fileName = ""
    
    var csvArray: [[String]] = [[]]
    var timetableOrg: [[String]] = [[]]
    var timetable: [[Any]] = [[]]
    
    @Published var busTime = ["-", "-", "-"]
    @Published var countdownText = ["-", "-", "-"]
    @Published var location = ["-", "-", "-"]
    @Published var wheelchair = ["-", "-", "-"]
    
    var count = 0
    var timer: Timer?
    
    func main() {
        csvArray += loadCSV(fileName: fileName)
        csvArray.removeFirst()
        //print(csvArray)
        
        timetableOrg.append(contentsOf: csvArray)
        timetableOrg.removeFirst()
        print(timetableOrg)
        
        ConvertTimetableOrg()
        
        // 1秒ごとに表示を更新
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.CulcCountdown()
        }
    }
    
    // 渡されたファイル名のCSVを2次元配列に格納
    func loadCSV(fileName: String) -> [[String]] {
        var csvArray: [[String]] = [[]]
        //csvのファイルパスを取得
        if let csvPath = Bundle.main.path(forResource: fileName, ofType: "csv") {
            do {
                //csvのファイルのデータを所得
                let csvStr = try String(contentsOfFile:csvPath, encoding:String.Encoding.utf8)
                //csvファイルを改行区切りで配列に格納
                let csvArr = csvStr.components(separatedBy: "\r\n")
                
                for csvFile in csvArr {
                    //csvファイルをカンマ区切りで多次元配列に格納
                    let csvSplit = csvFile.components(separatedBy: ",")
                    csvArray += [csvSplit]
                    //csvArray.append(contentsOf: csvSplit)
                }
                csvArray.removeFirst()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        csvArray.removeLast()
        return csvArray
    }
    
    // 時刻表の配列timetableOrgの「8:00」という形式から、その日の0時からの秒数という形式に変換して配列Timetableに格納
    // BOM付きCSVを読み込むと落ちるっぽいので注意
    func ConvertTimetableOrg() {
        timetable = timetableOrg
        for i in 0...timetableOrg.count-1 {
            let arr: [String] = timetableOrg[i][0].components(separatedBy: ":")
            let timeIntervalSinceStartOfToday = Int(arr[0])! * 60 * 60 + Int(arr[1])! * 60
            timetable[i][0] = timeIntervalSinceStartOfToday
        }
        print(timetable)
    }
    
    // 時刻表の全てのバスのカウントダウンを計算し、今の時刻から適切なバスとその前後を選択
    // これらの情報を表示するテキストをcountdownTextという配列に格納
    func CulcCountdown() {
        let busNumber = timetable.count
        var countdownArray: [Int] = Array(repeating: 0, count: busNumber)
        for i in 0...busNumber-1 {
            let startOfToday = Calendar(identifier: .gregorian).startOfDay(for: Date())
            
            let timeIntervalSinceStartOfToday = timetable[i][0]
            // 現在時刻からの差(s)を求める
            let countdown = timeIntervalSinceStartOfToday as! Int + Int(startOfToday.timeIntervalSinceNow)
            countdownArray[i] = countdown
        }
        
        for i in 0...busNumber-1 {
            if countdownArray[i] > 0 {
                if i == 0 {
                    //　始発より前の時間の場合
                    busTime[0] = "-"
                    busTime[1] = timetableOrg[i][0]
                    busTime[2] = timetableOrg[i+1][0]
                    
                    countdownText[0] = "-"
                    countdownText[1] = ConvertCountdown(timeRemain: countdownArray[i])
                    countdownText[2] = ConvertCountdown(timeRemain: countdownArray[i+1])
                    
                    location[0] = "-"
                    location[1] = timetableOrg[i][1]
                    location[2] = timetableOrg[i+1][1]
                    
                    wheelchair[0] = "-"
                    wheelchair[1] = timetableOrg[i][2]
                    wheelchair[2] = timetableOrg[i+1][2]
                    break
                } else if i > 0 && i < busNumber-1 {
                    for j in i-1...i+1 {
                        busTime[j-(i-1)] = timetableOrg[j][0]
                        countdownText[j-(i-1)] = ConvertCountdown(timeRemain: countdownArray[j])
                        location[j-(i-1)] = timetableOrg[j][1]
                        wheelchair[j-(i-1)] = timetableOrg[j][2]
                    }
                    break
                } else if i == busNumber-1 {
                    // 次が最終便の場合
                    busTime[0] = timetableOrg[i-1][0]
                    busTime[1] = timetableOrg[i][0]
                    busTime[2] = "-" //バスが次に移動したときに-表示に戻す
                    
                    countdownText[0] = ConvertCountdown(timeRemain: countdownArray[i-1])
                    countdownText[1] = ConvertCountdown(timeRemain: countdownArray[i])
                    countdownText[2] = "-"
                    
                    location[0] = timetableOrg[i-1][1]
                    location[1] = timetableOrg[i][1]
                    location[2] = "-"
                    
                    wheelchair[0] = timetableOrg[i-1][2]
                    wheelchair[1] = timetableOrg[i][2]
                    wheelchair[2] = "-"
                    break
                }
            } else {
                //最終便の後の場合
                busTime[0] = timetableOrg[busNumber-1][0]
                busTime[1] = "-"
                
                countdownText[0] = ConvertCountdown(timeRemain: countdownArray[busNumber-1])
                countdownText[1] = "-"
                
                location[0] = timetableOrg[busNumber-1][1]
                location[1] = "-"
                
                wheelchair[0] = timetableOrg[busNumber-1][2]
                wheelchair[1] = "-"
            }
        }
    }
    
    // 残り時間の秒数(int)を「残り?分?秒」の形式に変換してreturnする
    func ConvertCountdown(timeRemain:Int) -> String {
        let time:TimeInterval = Double(timeRemain)
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .short
        dateFormatter.allowedUnits = [.hour, .minute, .second]
        //dateFormatter.includesTimeRemainingPhrase = true  //「残り/remaining」をつけるかつけないか
        
        // 日本語表記に固定
        var calender = Calendar.current
        calender.locale = Locale(identifier: "ja_JP")
        dateFormatter.calendar = calender
        
        print(dateFormatter.string(from: time)!)
        return dateFormatter.string(from: time)!
    }
}
