import SwiftUI
import JapaneseNationalHolidays

struct ContentView: View {
    @State var selectedTag = 1
    
    @State var staCampShow: Bool = false
    @State var campStaShow: Bool = false
    @State var campFRCShow: Bool = false
    @State var fRCCampShow: Bool = false
    
    @ObservedObject var busStaCamp = MakeTimetable()
    @ObservedObject var busCampSta = MakeTimetable()
    @ObservedObject var busCampFRC = MakeTimetable()
    @ObservedObject var busFRCCamp = MakeTimetable()
    
    var titleStaGo = "小手指 → キャンパス"
    var titleStaBack = "キャンパス → 小手指"
    var label3StaGo = "発車場所"
    var label3StaBack = "降車場所"
    var label4Sta = "車椅子"
    
    let titleFRCGo = "キャンパス → FRC"
    let titleFRCBack = "FRC → キャンパス"
    let label3FRCGo = "発車場所"
    let label3FRCBack = "降車場所"
    let label4FRC = "接続"
    
    
    var body: some View {
        TabView(selection: $selectedTag) {
            EachTabView(busGo: busStaCamp,
                        busBack: busCampSta,
                        goShow: $staCampShow,
                        backShow: $campStaShow,
                        titleGo: titleStaGo,
                        titleBack: titleStaBack,
                        label3Go: label3StaGo,
                        label3Back: label3StaBack,
                        label4: label4Sta
            ).tag(1)
            
            EachTabView(busGo: busCampFRC,
                        busBack: busFRCCamp,
                        goShow: $campFRCShow,
                        backShow: $fRCCampShow,
                        titleGo: titleFRCGo,
                        titleBack: titleFRCBack,
                        label3Go: label3FRCGo,
                        label3Back: label3FRCBack,
                        label4: label4FRC
            ).tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .background(Color(UIColor.secondarySystemBackground))
        .ignoresSafeArea()
        .onAppear {
            let dayOfWeek = Calendar.current.component(.weekday, from: Date())
            let current = Calendar.current
            
            if japaneseNationalHolidayName(forYear: current.component(.year, from: Date()), month: current.component(.month, from: Date()), day: current.component(.day, from: Date())) != nil || dayOfWeek == 1{
                // 日曜日か祝日
                busStaCamp.fileName = "Timetable_2022S_Kotesashi-Campus_SundaysHolidays"
                busCampSta.fileName = "Timetable_2022S_Campus-Kotesashi_SundaysHolidays"
            } else if dayOfWeek >= 2 && dayOfWeek <= 6 {
                // 平日
                busStaCamp.fileName = "Timetable_2022S_Kotesashi-Campus_Weekdays"
                busCampSta.fileName = "Timetable_2022S_Campus-Kotesashi_Weekdays"
                busCampFRC.fileName = "Timetable_2022S_Campus-FRC_Weekdays"
                busFRCCamp.fileName = "Timetable_2022S_FRC-Campus_Weekdays"
            } else if dayOfWeek == 7 {
                // 土曜日
                busStaCamp.fileName = "Timetable_2022S_Kotesashi-Campus_Saturdays"
                busCampSta.fileName = "Timetable_2022S_Campus-Kotesashi_Saturdays"
                busCampFRC.fileName = "Timetable_2022S_Campus-FRC_Saturdays"
                busFRCCamp.fileName = "Timetable_2022S_FRC-Campus_Saturdays"
            }
            
            busStaCamp.main()
            busCampSta.main()
            busCampFRC.main()
            busFRCCamp.main()
        }
    }
}


struct EachTabView: View {
    @ObservedObject var busGo: MakeTimetable
    @ObservedObject var busBack: MakeTimetable
    @Binding var goShow: Bool
    @Binding var backShow: Bool
    
    let titleGo: String
    let titleBack: String
    let label3Go: String
    let label3Back: String
    let label4: String
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack(alignment: .center, spacing: 15.0) {
                Spacer()
                EachBusView(isShow: $goShow,
                            timetable: busGo,
                            title: titleGo,
                            label3: label3Go,
                            label4: label4
                )
                Spacer()
                EachBusView(isShow: $backShow,
                            timetable: busBack,
                            title: titleBack,
                            label3: label3Back,
                            label4: label4
                )
                Spacer()
            }
        }
    }
}

struct EachBusView: View {
    @Binding var isShow: Bool // 親ビューの変数isShowとバインディングする
    @ObservedObject var timetable: MakeTimetable
    
    var title: String
    var label3: String
    var label4: String
    
    var body: some View {
        Button(action: {
            isShow = true
        }) {
            VStack() {
                Text(title).font(.title)
                HStack(spacing: 0) {
                    VStack(alignment: .center, spacing: 30) {
                        Text("発車時刻")
                        Text(timetable.busTime[0]).frame(width: 70)
                        Text(timetable.busTime[1]).frame(width: 70, height: 40).background(Color("highlight"))
                        Text(timetable.busTime[2]).frame(width: 70)
                    }
                    VStack(alignment: .center, spacing: 30) {
                        Text("残り時間")
                        Text(timetable.countdownText[0]).lineLimit(1).frame(width: 150)
                        Text(timetable.countdownText[1]).lineLimit(1).frame(width: 150, height: 40).background(Color("highlight"))
                        Text(timetable.countdownText[2]).lineLimit(1).frame(width: 150)
                    }
                    VStack(alignment: .center, spacing: 30) {
                        Text(label3)
                        Text(timetable.location[0]).frame(width: 65)
                        Text(timetable.location[1]).frame(width: 65, height: 40).background(Color("highlight"))
                        Text(timetable.location[2]).frame(width: 65)
                    }
                    VStack(alignment: .center, spacing: 30) {
                        Text(label4)
                        Text(timetable.wheelchair[0]).frame(width: 65)
                        Text(timetable.wheelchair[1]).frame(width: 65, height: 40).background(Color("highlight"))
                        Text(timetable.wheelchair[2]).frame(width: 65)
                    }
                }
                .frame(width: 350+20, height: 200+30)
                .background(Color(UIColor.tertiarySystemBackground))
                .padding()
            }
            .sheet(isPresented: $isShow){
                SomeView(isPresented: $isShow, timetable: timetable, title: title, label3: label3, label4: label4)
            }
            .foregroundColor(Color("text"))
        }
    }
}

struct SomeView: View {
    @Binding var isPresented: Bool // ContentViewビューの変数isShowとバインディングする
    @ObservedObject var timetable: MakeTimetable
    let title: String
    let label3: String
    let label4: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(title).font(.title).foregroundColor(Color("text"))
                ScrollViewReader {_ in
                    VStack(alignment: .center, spacing: 15.0) {
                        HStack(spacing: 30) {
                            VStack(alignment: .center, spacing: 15) {
                                Text("発車時刻")
                                ForEach(0..<timetable.timetableOrg.count, id: \.self) { num in
                                    Text(self.timetable.timetableOrg[num][0])
                                    //Divider()
                                }
                            }.padding()
                            VStack(alignment: .center, spacing: 15) {
                                Text(label3)
                                ForEach(0..<timetable.timetableOrg.count, id: \.self) { num in
                                    Text(self.timetable.timetableOrg[num][1])
                                    //Divider()
                                }
                            }.padding()
                            VStack(alignment: .center, spacing: 15) {
                                Text(label4)
                                ForEach(0..<timetable.timetableOrg.count, id: \.self) { num in
                                    Text(self.timetable.timetableOrg[num][2])
                                    //Divider()
                                }
                            }.padding()
                        }
                        //.frame(width: 350+20, height: 200+30)
                        //.background(Color(UIColor.tertiarySystemBackground))
                        .padding()
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            // 閉じるボタン
                            Button {
                                isPresented = false
                            } label: {
                                Text("閉じる")
                            }
                        }
                    }
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //KotesashiCampusView(busStaCamp: busStaCamp, busCampSta: busCampSta)
        //CampusFRCView(busCampFRC: busCampFRC, busFRCCamp: busFRCCamp)
    }
}
