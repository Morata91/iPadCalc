//
//  ContentView.swift
//  iPadCalc
//
//  Created by 村田航希 on 2024/05/13.
//

import SwiftUI
import SwiftData

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
        case mutliply = "×"
        case divide = "÷"
        case equal = "="
        case clear = "C"
        case decimal = "."
        
    }

    //演算タイプ
    enum Operation: String {
        case add = "+"
        case subtract = "-"
        case mutliply = "×"
        case divide = "÷"
        case none = "none"
    }
    

    
    //セル
    struct Cell: Identifiable, Hashable {
        let id: Int
        var opeType: Operation
        var value: Float
        var initialFlag: Bool = true
    }
    
    struct Cells: Identifiable, Hashable {
        let id: Int
        var cell: [Cell]
        var result: Float = 0
    }

    //テーブルの初期化
    @State var table = [
        Cells(
            id: 0,
            cell: [
                Cell(id: 0, opeType: .none, value: 0),
                Cell(id: 1, opeType: .none, value: 0),
                Cell(id: 2, opeType: .none, value: 0),
                Cell(id: 3, opeType: .none, value: 0),
                Cell(id: 4, opeType: .none, value: 0),
                Cell(id: 5, opeType: .none, value: 0),
                Cell(id: 6, opeType: .none, value: 0),
                Cell(id: 7, opeType: .none, value: 0)
            ]
        ),
        Cells(
            id: 1,
            cell: [
                Cell(id: 100, opeType: .none, value: 0),
                Cell(id: 101, opeType: .none, value: 0),
                Cell(id: 102, opeType: .none, value: 0),
                Cell(id: 103, opeType: .none, value: 0),
                Cell(id: 104, opeType: .none, value: 0),
                Cell(id: 105, opeType: .none, value: 0),
                Cell(id: 106, opeType: .none, value: 0),
                Cell(id: 107, opeType: .none, value: 0)
            ]
        ),
        Cells(
            id: 2,
            cell: [
                Cell(id: 200, opeType: .none, value: 0),
                Cell(id: 201, opeType: .none, value: 0),
                Cell(id: 202, opeType: .none, value: 0),
                Cell(id: 203, opeType: .none, value: 0),
                Cell(id: 204, opeType: .none, value: 0),
                Cell(id: 205, opeType: .none, value: 0),
                Cell(id: 206, opeType: .none, value: 0),
                Cell(id: 207, opeType: .none, value: 0)
            ]
        ),
        Cells(
                id: 3,
                cell: [
                    Cell(id: 300, opeType: .none, value: 0),
                    Cell(id: 301, opeType: .none, value: 0),
                    Cell(id: 302, opeType: .none, value: 0),
                    Cell(id: 303, opeType: .none, value: 0),
                    Cell(id: 304, opeType: .none, value: 0),
                    Cell(id: 305, opeType: .none, value: 0),
                    Cell(id: 306, opeType: .none, value: 0),
                    Cell(id: 307, opeType: .none, value: 0)
                ]
            )
        ]

    
    
    
    
    @State private var cellSelecter: Int?
    
    
    

    
    
    
    
    private let buttons: [[CalcButton]] = [
            
            [.seven, .eight, .nine],
            [.four, .five, .six],
            [.one, .two, .three],
            [.zero, .add],
            [.decimal, .subtract, .mutliply],
            [.clear, .equal, .divide]
        ]
    
    
    
    //Input
    @State var value = "0"
    @State var currentOperation: Operation = .none
    @State var ableDecimal: Bool = true
    @State var nilValue: Bool = true    //初期値value=0だが実際はnilとみなす。

    
    
    
    
    

    var body: some View {
        
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {
                Text("ww")
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
                                    VStack(
                                        alignment: .center,
                                        content: {
                                            Text(String(column.result))
                                            
                                            List (column.cell, selection: $cellSelecter){
                                                Text(String($0.opeType.rawValue)+"\t\t\t"+String($0.value))
                                            }
                                            
                                        }
                                        
                                        
                                    )
                                }
                                
                                
                                
                            }
                        )
                            
                        //ボタン領域
                        VStack {
                            Text("Cell")
                            Text("Selected: "+String(cellSelecter ?? 0))
                            Text("Input")
                            Text("Value: "+self.value)
                            Text("operation:  "+self.currentOperation.rawValue)
                            Text("ableDecimal:  "+String(self.ableDecimal))
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
            }
        )
        .onChange(of: cellSelecter) { oldState, newState in
            let colSelecter = (oldState ?? 400) / 100  //選択されているセルの列を取得。none->4
            if colSelecter != 4 {
                if let index = self.table[colSelecter].cell.firstIndex(where: {$0.id == oldState}) {
                    if self.table[colSelecter].cell[index].initialFlag {
                        self.table[colSelecter].cell[index].opeType = .none
                    }
                }
            }
            
            //Resultを計算
            
            for col in self.table {
                var result: Float = 0
                for c in col.cell {
                    switch c.opeType{
                    case .add:
                        result = result + c.value
                    case .subtract:
                        result = result - c.value
                    case .mutliply:
                        result = result * c.value
                    case .divide:
                        result = result / c.value
                    default:
                        break
                    }
                }
                self.table[col.id].result = result
            }
        }
    }

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
    
    
    
    private func didTap(button: CalcButton) {
        let colSelection = (self.cellSelecter ?? 400) / 100  //選択されているセルの列を取得。none->4
        if colSelection != 4 {
            switch button {
            case .add:
                if self.nilValue {
                    self.currentOperation = .add
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        print(self.table[colSelection].cell[index])
                        self.table[colSelection].cell[index].opeType = .add
                    }
                } else {
                    upCountCellSelecter()
                    self.value = "0"
                    self.ableDecimal = true
                    self.currentOperation = .add
                    self.nilValue = true
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        print(self.table[colSelection].cell[index])
                        self.table[colSelection].cell[index].opeType = .add
                    }
                }
                
                
            case .subtract:
                if self.nilValue {
                    self.currentOperation = .subtract
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        print(self.table[colSelection].cell[index])
                        self.table[colSelection].cell[index].opeType = .subtract
                    }
                } else {
                    upCountCellSelecter()
                    self.value = "0"
                    self.ableDecimal = true
                    self.currentOperation = .subtract
                    self.nilValue = true
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        print(self.table[colSelection].cell[index])
                        self.table[colSelection].cell[index].opeType = .subtract
                    }
                }
            case .mutliply:
                if self.nilValue {
                    self.currentOperation = .mutliply
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        print(self.table[colSelection].cell[index])
                        self.table[colSelection].cell[index].opeType = .mutliply
                    }
                } else {
                    upCountCellSelecter()
                    self.value = "0"
                    self.ableDecimal = true
                    self.currentOperation = .mutliply
                    self.nilValue = true
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        print(self.table[colSelection].cell[index])
                        self.table[colSelection].cell[index].opeType = .mutliply
                    }
                }
            case .divide:
                if self.nilValue {
                    self.currentOperation = .divide
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        print(self.table[colSelection].cell[index])
                        self.table[colSelection].cell[index].opeType = .divide
                    }
                } else {
                    upCountCellSelecter()
                    self.value = "0"
                    self.ableDecimal = true
                    self.currentOperation = .divide
                    self.nilValue = true
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        print(self.table[colSelection].cell[index])
                        self.table[colSelection].cell[index].opeType = .divide
                    }
                }
                
            case .equal:
                upCountCellSelecter()
                self.value = "0"
                self.currentOperation = .none
                self.ableDecimal = true
                self.nilValue = true
            case .clear:
                self.value = "0"
                self.currentOperation = .none
                self.ableDecimal = true
                if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                    print(self.table[colSelection].cell[index])
                    self.table[colSelection].cell[index].value = 0
                    self.table[colSelection].cell[index].opeType = .none
                }
//            case .decimal:
//                break
            default:    //数字or小数点
                self.nilValue = false
                
                if button == .decimal {
                    if !self.ableDecimal{
                        break
                    }
                    self.ableDecimal = false
                }
                //数字が押された時に、operation=noneだったら、+にする
                if self.currentOperation == .none {
                    self.currentOperation = .add
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        
                        self.table[colSelection].cell[index].opeType = .add
                    }
                }
                let number = button.rawValue
                if self.value == "0" {
                    value = number
                }
                else {
                    self.value = "\(self.value)\(number)"
                }
                    if let index = self.table[colSelection].cell.firstIndex(where: {$0.id == self.cellSelecter}) {
                        
                        self.table[colSelection].cell[index].value = Float(self.value) ?? 0
                        self.table[colSelection].cell[index].initialFlag = false
                    }
                
                
                
            }
        }
    }
    
    
    private func upCountCellSelecter() {
        let cellSelecter = self.cellSelecter ?? 400
        if cellSelecter != 400 {
            let colSelecter = cellSelecter / 100
            if self.table[colSelecter].cell.firstIndex(where: {$0.id == cellSelecter + 1}) != nil {
                //cellSelecter+=1できるならば
                self.cellSelecter = cellSelecter + 1
            }
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

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
