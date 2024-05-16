//
//  ContentView.swift
//  iPadCalc
//
//  Created by 村田航希 on 2024/05/13.
//
//つぎやる
//AC
//UIをもうちょいマシに

import SwiftUI
import SwiftData

let ROW = 12  // ROWの値を修正
let COL = 4  // `Cells`の数



struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    //NavigationSplitViewが開いてるかどうかの状態を表す変数
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
     
    //ボタン
    private enum CalcButton: String {
        case zero = "0"
        case one = "1"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case add = "+"
        case subtract = "-"
        case multiply = "×"
        case divide = "÷"
        case equal = "="
        case clear = "C"
        case decimal = "."
        
    }
    private let buttons: [[CalcButton]] = [
            
            [.seven, .eight, .nine],
            [.four, .five, .six],
            [.one, .two, .three],
            [.zero, .add],
            [.decimal, .subtract, .multiply],
            [.clear, .equal, .divide]
        ]
    //演算タイプ
    enum Operation: String {
        case add = "+"
        case subtract = "-"
        case multiply = "×"
        case divide = "÷"
        case none = ""
    }
    
    //セルの定義と初期化
    struct Cell: Identifiable, Hashable {
        let id: Int
        var opeType: Operation = .none
        var value: String = "0"
        var initialFlag: Bool = true
    }
    struct Cells: Identifiable, Hashable {
        let id: Int
        var cell: [Cell]
        var result: Double = 0
    }
    @State var table = (0..<COL).map { index in
        Cells(
            id: index,
            cell: ((index * 100)..<(index * 100 + ROW)).map { Cell(id: $0) }
        )
    }
    @State private var cellSelecter: Int?
    
    //入力の管理
    struct Input {
        var value: String
        var currentOperation: Operation
        var ableDecimal: Bool
        var nilValue: Bool
    }
    @State var input = Input(value: "0", currentOperation: .none, ableDecimal: true, nilValue: true)
    
    
    //ダミー
    struct Dummy: Identifiable {
        let id = UUID()
        let value: String
    }
    @State var dummy = (0..<5).map { index in
        Dummy(value: String(index))
    }
    @State private var dummySelecter: UUID?
    
    
    @State private var doCalc: Bool = false

    

    var body: some View {
        
        
            NavigationSplitView(
                columnVisibility: $columnVisibility,
                sidebar: {
                    List(dummy, selection: $dummySelecter) { a in
                        Text(a.value)
                                }
                },
                detail: {
                    HStack(
                        alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/,
                        spacing: 10,
                        content: {
                            HStack(
                                alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/,
                                content: {
                                    ForEach(table, id: \.self) { column in
                                        ZStack {
                                            Color(red: 0.2, green: 0.33, blue: 0.95, opacity: 1.0)
                                            VStack(
                                                alignment: .center,
                                                content: {
                                                    Spacer()
                                                    HStack(
                                                        content: {
                                                        Spacer()
                                                            if column.result > 100000000000000 {
                                                                Text("Error")
                                                                    .frame(height: 40)
                                                            } else {
                                                                Text(
        //                                                            String(column.result)
                                                                    formatF(f: column.result)
                                                                )
                                                                .frame(height: 40)
                                                                }
                                                            }
                                                        
                                                    )
                                                    .background(Color.white)
                                                    .frame(maxWidth: 200)
                                                    List (selection: $cellSelecter){
                                                        ForEach(column.cell) { c in
                                                            HStack {
                                                                Text("")
                                                                Spacer()
    //                                                            Text(String(c.opeType.rawValue)+"\t\t"+String(c.value))
                                                                Text(dispCell(cell: c))
                                                            }
                                                            .frame(height: 30)
                                                            
                                                        }
                                                    }
                                                    .listStyle(.plain)
                                                    .frame(maxWidth: 200)
                                                    Button(
                                                        action: {allClear(colnum: column.id)},
                                                        label: {Text("AC")}
                                                    )
                                                    .buttonStyle(BorderedRoundedButtonStyle())
                                                    Spacer()
                                                }
                                                
                                                
                                            )
                                        }
                                    }
                                    
                                    
                                    
                                }
                            )
                            .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            
                                
                            //ボタン領域
                            VStack {
    //                            Text("Cell")
    //                            Text("Selected: "+String(cellSelecter ?? 0))
    //                            Text("Input")
    //                            Text("Value: "+self.input.value)
    //                            Text("operation:  "+self.input.currentOperation.rawValue)
    //                            Text("ableDecimal:  "+String(self.input.ableDecimal))
                                ForEach(buttons, id: \.self) { row in
                                    HStack(spacing: 12) {
                                        ForEach(row, id: \.self) { item in
                                            Button(action: {
                                                didTap(button: item)
                                            }, label: {
                                                Text(item.rawValue)
                                            })
                                        }
                                    }
                                    .padding(.bottom, 3)
                                }
                            }
                            .buttonStyle(BorderedRoundedButtonStyle())
                        }
                    )
                    
                    .navigationBarTitleDisplayMode(.inline)
                    
//                    .navigationBarTitle("kkk")
                    .toolbar {
                        ToolbarItem(placement: .principal, content: {principalIcon()})
                    }
//                    .toolbar(Visibility.hidden, for: .navigationBar)
                    
                }
            )
            .navigationSplitViewStyle(.prominentDetail)
//            .border(Color.red, width: 10)
            .onChange(of: cellSelecter) { oldState, newState in
                changeInput(value: "0", currentOperation: ContentView.Operation.none, ableDecimal: true, nilValue: true)
                let colSelecter = (oldState ?? 400) / 100  //選択されているセルの列を取得。none->4
                if colSelecter != 4 {
                    if let index = self.table[colSelecter].cell.firstIndex(where: {$0.id == oldState}) {
                        if self.table[colSelecter].cell[index].initialFlag {
                            self.table[colSelecter].cell[index].opeType = .none
                        }
                        if self.table[colSelecter].cell[index].opeType == .add {
                            self.table[colSelecter].cell[index].opeType = .none
                        }
                    }
                }
                
                //Resultを計算
                if doCalc {
                    calculate()
                }
        
        }
    }

    
    
    
    //ボタンを押した時の挙動
    private func didTap(button: CalcButton) {
        let colSelection = (self.cellSelecter ?? 400) / 100  //選択されているセルの列を取得。none->4
        if colSelection != 4 {
            switch button {
            case .add:
                if self.input.nilValue {    //まだ値がnoneの時に+を押すと、operationは+に設定される
                    changeInput(currentOperation: .add)
                    currentCellChange(opeType: .add, value: "0", initialFlag: true)
                } else {    //値がある時に+を押すと、
                    doCalc = false
                    
                    changeInput(value: "0", currentOperation: .add, ableDecimal: true, nilValue: true)
                    upCountCellSelecter()   //次のセルに移る
                    calculate()
                    currentCellChange(opeType: self.input.currentOperation, value: "0", initialFlag: true)
                    
                }
                
                
            case .subtract:
                if self.input.nilValue {    //まだ値がnoneの時に+を押すと、operationは+に設定される
                    changeInput(currentOperation: .subtract)
                    currentCellChange(opeType: .subtract, value: "0", initialFlag: true)
                } else {    //値がある時に+を押すと、
                    doCalc = false
                    
                    changeInput(value: "0", currentOperation: .subtract, ableDecimal: true, nilValue: true)
                    upCountCellSelecter()   //次のセルに移る
                    calculate()
                    currentCellChange(opeType: self.input.currentOperation, value: "0", initialFlag: true)
                    
                }
            case .multiply:
                if self.input.nilValue {    //まだ値がnoneの時に+を押すと、operationは+に設定される
                    changeInput(currentOperation: .multiply)
                    currentCellChange(opeType: .multiply, value: "0", initialFlag: true)
                } else {    //値がある時に+を押すと、
                    doCalc = false
                    
                    changeInput(value: "0", currentOperation: .multiply, ableDecimal: true, nilValue: true)
                    upCountCellSelecter()   //次のセルに移る
                    calculate()
                    currentCellChange(opeType: self.input.currentOperation, value: "0", initialFlag: true)
                    
                }
                
            case .divide:
                if self.input.nilValue {    //まだ値がnoneの時に+を押すと、operationは+に設定される
                    changeInput(currentOperation: .divide)
                    currentCellChange(opeType: .divide, value: "0", initialFlag: true)
                } else {    //値がある時に+を押すと、
                    doCalc = false
                    changeInput(value: "0", currentOperation: .divide, ableDecimal: true, nilValue: true)
                    upCountCellSelecter()   //次のセルに移る
                    calculate()
                    currentCellChange(opeType: self.input.currentOperation, value: "0", initialFlag: true)
                    
                }
                
            case .equal:
                doCalc = true
                
                changeInput(value: "0", currentOperation: ContentView.Operation.none, ableDecimal: true, nilValue: true)
                upCountCellSelecter(change: false)
                
            case .clear:
                changeInput(value: "0", currentOperation: ContentView.Operation.none, ableDecimal: true, nilValue: true)
                currentCellChange(opeType: ContentView.Operation.none, value: "0", initialFlag: true)
                calculate()
            case .decimal:
                doCalc = true
                if !self.input.ableDecimal{
                    break
                }
                changeInput(ableDecimal: false)
                if self.input.currentOperation == .none {
                    changeInput(currentOperation: .add)
                    
                }
                changeInput(value: "\(self.input.value)\(button.rawValue)")
                currentCellChange(value: self.input.value, initialFlag: false)
            default:    //数字or小数点
                doCalc = true
                changeInput(nilValue: false)
                
                if button == .decimal {
                    
                }
                //数字が押された時に、operation=noneだったら、+にする(Inputのみ)
                if self.input.currentOperation == .none {
                    changeInput(currentOperation: .add)
//                    currentCellChange(opeType: .add)
                    
                }
                let number = button.rawValue
                if self.input.value == "0" {
                    changeInput(value: number)
                }
                else  if self.input.value.count < 12{
                    changeInput(value: "\(self.input.value)\(number)")
                } else {
                    break
                }
                currentCellChange(value: self.input.value, initialFlag: false)
                
                
            }
        }
    }
    
    //次のセルに移動
    private func upCountCellSelecter(change:Bool = true) {
        let cellSelecter = self.cellSelecter ?? 400
        if cellSelecter != 400 {
            let colSelecter = cellSelecter / 100
            if self.table[colSelecter].cell.firstIndex(where: {$0.id == cellSelecter + 1}) != nil {
                //cellSelecter+=1できるならば
                self.cellSelecter = cellSelecter + 1
                if change {
                    
                }
            }
        }
    }
    //選択されているセルの中身を変更
    //cellIDを指定すると、指定したセルを変更できる
    private func currentCellChange(opeType: Operation? = nil, value: String? = nil, initialFlag: Bool? = nil, cellID: Int? = nil) {
        let cS: Int
        
        if cellID != nil {
            cS = cellID ?? 400
        } else {
            cS = self.cellSelecter ?? 400
            
        }
        let colSelecter = cS / 100
          //選択されているセルの列を取得。none->4
        if colSelecter != 4 {
            if let index = self.table[colSelecter].cell.firstIndex(where: {$0.id == cS}) {
                if let a = opeType {
                    self.table[colSelecter].cell[index].opeType = a
                }
                if let b = value {
                    self.table[colSelecter].cell[index].value = b
                }
                if let c = initialFlag {
                    self.table[colSelecter].cell[index].initialFlag = c
                }
            }
            
        }
    }
    //入力の中身を変更
    private func changeInput(value: String? = nil, currentOperation: Operation? = nil, ableDecimal: Bool? = nil, nilValue: Bool? = nil){
        if let a = value {
            self.input.value = a
        }
        if let b = currentOperation {
            self.input.currentOperation = b
        }
        if let c = ableDecimal {
            self.input.ableDecimal = c
        }
        if let d = nilValue {
            self.input.nilValue = d
        }
        
    }
    //AC
    private func allClear(colnum: Int) {
        for i in colnum*100..<colnum*100+ROW {
            currentCellChange(opeType: ContentView.Operation.none, value: "0", initialFlag: true, cellID: i)
        }
        self.cellSelecter = colnum*100
    }
    
    
    //アイコン
    private func principalIcon() -> some View {
        Image("NavBar")
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 36)
            
    }
    
    //表示
    private func dispCell(cell: Cell) -> String {
        if cell.initialFlag {
            return "\(cell.opeType.rawValue)"
        }
        let d = Double(cell.value)!
        return "\(cell.opeType.rawValue)"+formatF(f:d)
    }
    //Doubleのフォーマット
    private func formatF(f: Double) -> String {
        print(f)
        
        if f.isFinite{
            let i = Int(f)
            if f == 0{
                return "0"
            }
            else if f > Double(i) { //小数
                return String(f)
            } else {    //整数
//                return String.localizedStringWithFormat("%d", i)//修正
                return addComma(i:  i)
//                return String(i)
            }
        } else {    //inf,nan
            return String(f)
        }
    }
    private func addComma(i: Int) -> String{
        var num = i
        let i0, i1, i2, i3, i4: Int
        var str: String = ""
        i0 = num % 1000
        str = String(i0)
        num = num / 1000
        if num > 0 {
            i1 = num % 1000
            str = String(i1) + "," + String(format: "%03d", i0)
            num = num / 1000
            if num > 0 {
                i2 = num % 1000
                str = String(i2) + "," + String(format: "%03d", i1) + "," + String(format: "%03d", i0)
                num = num / 1000
                if num > 0 {
                    i3 = num % 1000
                    str = String(i3) + "," + String(format: "%03d", i2) + "," + String(format: "%03d", i1) + "," + String(format: "%03d", i0)
                    num = num / 1000
                    if num > 0 {
                        i4 = num % 1000
                        str = String(i4) + "," + String(format: "%03d", i3) + "," + String(format: "%03d", i2) + "," + String(format: "%03d", i1) + "," + String(format: "%03d", i0)
                        num = num / 1000
                    }
                }
            }
        }
        return str
    }
    //計算
    private func calculate() {
        for col in self.table {
            var result: Double = 0
            for c in col.cell {
                switch c.opeType{
                case .add:
                    result = result + Double(c.value)!
                case .subtract:
                    result = result - Double(c.value)!
                case .multiply:
                    result = result * Double(c.value)!
                case .divide:
                    result = result / Double(c.value)!
                case .none:
                    result = result + Double(c.value)!
                }
            }
            self.table[col.id].result = result
            
        }
    }
    
    
    
    /// 枠線のある角丸なボタンスタイル
    struct BorderedRoundedButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) var isEnabled
        
        var color: Color = .blue
        private let disabledColor: Color = .init(uiColor: .lightGray)
        private let backgroundColor: Color = .white
        private let cornerRadius: CGFloat = 8.0
        private let lineWidth: CGFloat = 2.0
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .fontWeight(.bold)
                .font(.system(size: 50))
                // 有効無効でカラーを変更
                .foregroundColor(isEnabled ? color : disabledColor)
                .background(backgroundColor)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(isEnabled ? color : disabledColor, lineWidth: lineWidth))
                // 押下時かどうかで透明度を変更
                .opacity(configuration.isPressed ? 0.5 : 1.0)
        }
    }
    /// 背景塗りつぶしで角丸なボタンスタイル
    struct RoundedButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) var isEnabled
        
        var color: Color = .blue
        private let disabledColor: Color = .init(uiColor: .lightGray)
        private let backgroundColor: Color = .white
        private let cornerRadius: CGFloat = 8.0
        private let lineWidth: CGFloat = 2.0
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .fontWeight(.bold)
                .foregroundColor(.white)
                // 有効無効でカラーを変更
                .background(isEnabled ? color : disabledColor)
                // 押下時かどうかで透明度を変更
                .opacity(configuration.isPressed ? 0.5 : 1.0)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
    
    
    //データベース
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
