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
    
    //セル
    struct Cell: Identifiable, Hashable {
        let id = UUID()
        let value: Float
    }
    
    private var cells0 = [
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0)
    ]
    private var cells1 = [
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0)
    ]
    private var cells2 = [
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0)
    ]
    private var cells3 = [
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0),
        Cell(value: 0)
    ]
    @State private var singleSelection: UUID?
    
//    private struct NumKey: Identifiable {
//        var id: Int
//        let char: String
//        let value: Int
//    }
//    private let numKeys: [NumKey] = [
//        NumKey(id: 0, char: "0", value: 0),
//        NumKey(id: 1, char: "1", value: 1),
//        NumKey(id: 2, char: "2", value: 2),
//        NumKey(id: 3, char: "3", value: 3),
//        NumKey(id: 4, char: "4", value: 4),
//        NumKey(id: 5, char: "5", value: 5),
//        NumKey(id: 6, char: "6", value: 6),
//        NumKey(id: 7, char: "7", value: 7),
//        NumKey(id: 8, char: "8", value: 8),
//        NumKey(id: 9, char: "9", value: 9)
//        
//    ]
    
    
    
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

    enum Operation {
        case add, subtract, multiply, divide, none
    }
    
    
    private let buttons: [[CalcButton]] = [
            
            [.seven, .eight, .nine],
            [.four, .five, .six],
            [.one, .two, .three],
            [.zero, .add],
            [.decimal, .subtract, .mutliply],
            [.clear, .equal, .divide]
        ]
    
    @State var value = "0"
    @State var runningNumber = 0
    @State var currentOperation: Operation = .none

    
    
    
    
    

    var body: some View {
        
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {
                Text("ww")
            },
                            
            detail: {
                HStack(
                    alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/,
                    spacing: 5,
                    content: {
                        VStack(
                            alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/,
                            content: {
                                HStack(
                                    alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/,
                                    content: {
                                        VStack(
                                            alignment: .center,
                                            content: {
                                                Text("計算結果1")
                                                List (cells0, selection: $singleSelection){
                                                            Text(String($0.value))
                                                    }
                                            }
                                        )
                                        VStack(
                                            alignment: .center,
                                            content: {
                                                Text("計算結果1")
                                                List (cells1, selection: $singleSelection){
                                                            Text(String($0.value))
                                                    }
                                            }
                                        )
                                        VStack(
                                            alignment: .center,
                                            content: {
                                                Text("計算結果1")
                                                List (cells2, selection: $singleSelection){
                                                            Text(String($0.value))
                                                    }
                                            }
                                        )
                                        VStack(
                                            alignment: .center,
                                            content: {
                                                Text("計算結果1")
                                                List (cells3, selection: $singleSelection) { cell in
                                                    Text(dispCell(cellValue: cell.value))
                                                    }
                                            }
                                        )
                                        
                                        
                                    }
                                )
                            })
                        // Our buttons
                        VStack {
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
        switch button {
            case .add, .subtract, .mutliply, .divide, .equal:
                break
            case .clear:
                break
            case .decimal:
                break
            default:
                let number = button.rawValue
                if self.value == "0" {
                    value = number
                }
                else {
                    self.value = "\(self.value)\(number)"
                }
            print(self.value)
        }
    }
    
    private func dispCell(cellValue: Float) -> String{
        return String(cellValue)
    }
    
    
    
    
    @ViewBuilder
    private func tenkeyView(name: String) -> some View {
        VStack(
            alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/,
            content: {
                HStack {
                    Button(action: {print("7")},label: {Text("7")})
                    Button(action: {print("7")},label: {Text("7")})
                    Button(action: {print("7")},label: {Text("7")})
                }
                .buttonStyle(BorderedRoundedButtonStyle())
                HStack {
                    Button(action: {print("7")},label: {Text("7")})
                    Button(action: {print("7")},label: {Text("7")})
                    Button(action: {print("7")},label: {Text("7")})
                }
                .buttonStyle(BorderedRoundedButtonStyle())
                HStack {
                    Button(action: {print("7")},label: {Text("7")})
                    Button(action: {print("7")},label: {Text("7")})
                    Button(action: {print("7")},label: {Text("7")})
                }
                .buttonStyle(BorderedRoundedButtonStyle())
            }
        )
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
