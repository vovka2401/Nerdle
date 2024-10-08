import SwiftUI
import SwiftData

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: GameViewModel
    @State var isGameOverViewPresented = false
    
    var body: some View {
        VStack(spacing: 20) {
            equations
            bottomSymbols
        }
        .overlay {
            toast
        }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(phases: .down) { keyPress in
            DispatchQueue.main.async {
                viewModel.handleOnPressKeyEvent(key: keyPress.key)
            }
            return .handled
        }
        .onAppear {
            guard let firstTile = viewModel.game.currentEquation.tiles.first else { return }
            selectTile(firstTile)
        }
        .disabled(viewModel.game.isGameOver)
        .overlay {
            gameOverView
        }
        .onChange(of: viewModel.game.isGameOver) { _, newValue in
            if newValue {
                isGameOverViewPresented = true
            } else {
                isGameOverViewPresented = false
            }
            modelContext.insert(viewModel.game)
            try? modelContext.save()
        }
        .onDisappear {
            modelContext.insert(viewModel.game)
            try? modelContext.save()
        }
    }
    
    var equations: some View {
        VStack(spacing: 5) {
            ForEach(0 ..< viewModel.game.maximumAttempts, id: \.self) { attempt in
                equationView(for: attempt)
            }
        }
    }

    var bottomSymbols: some View {
        VStack(spacing: 5) {
            HStack(spacing: 5) {
                ForEach(viewModel.game.bottomNumberTiles, id: \.id) { tile in
                    symbolButton(tile: tile)
                }
            }
            HStack(spacing: 5) {
                ForEach(viewModel.game.bottomOperatorTiles, id: \.id) { tile in
                    symbolButton(tile: tile)
                }
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.unusedSymbol)
                    .frame(width: 100, height: 70)
                    .overlay {
                        Text("Enter")
                            .font(.system(size: 20))
                    }
                    .onTapGesture {
                        viewModel.guess()
                    }
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.unusedSymbol)
                    .frame(width: 100, height: 70)
                    .overlay {
                        Text("Delete")
                            .font(.system(size: 20))
                    }.onTapGesture {
                        viewModel.delete()
                    }
            }
        }
    }

    var toast: some View {
        SwiftUI.Group {
            if let toast = viewModel.toast {
                Text(toast.message)
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                    .multilineTextAlignment(.center)
                    .frame(width: 300, height: 100)
                    .background(Color(red: 0.965, green: 0.812, blue: 0.827))
                    .cornerRadius(8)
                    .transition(.asymmetric(insertion: .opacity, removal: .identity))
            }
        }
        .animation(.easeInOut, value: viewModel.toast)
    }

    var gameOverView: some View {
        SwiftUI.Group {
            if isGameOverViewPresented {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .frame(width: 400, height: 500)
                    .overlay {
                        if viewModel.game.isGameWon {
                            VStack(spacing: 15) {
                                Text("You won!")
                                    .font(.system(size: 20))
                                VStack(spacing: 2) {
                                    ForEach(viewModel.game.equations, id: \.id) { equation in
                                        HStack(spacing: 2) {
                                            ForEach(equation.tiles, id: \.id) { tile in
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(tile.color)
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                    }
                                }
                                ShareLink(item: viewModel.getResultToShare()) {
                                    Text("Share")
                                        .font(.system(size: 20))
                                        .frame(width: 150, height: 50)
                                }
                                .buttonStyle(BlueButtonStyle())
                                Button {
                                    viewModel.restartGame()
                                } label: {
                                    Text("Restart game")
                                        .font(.system(size: 20))
                                        .frame(width: 150, height: 50)
                                }
                                .buttonStyle(BlueButtonStyle())
                            }
                        } else {
                            VStack(spacing: 15) {
                                Text("Sorry, you lost!")
                                    .font(.system(size: 20))
                                    .frame(width: 150, height: 50)
                                Button {
                                    viewModel.replayLastGuess()
                                } label: {
                                    Text("Retry last guess")
                                        .font(.system(size: 20))
                                        .frame(width: 150, height: 50)
                                }
                                .buttonStyle(BlueButtonStyle())
                                Button {
                                    viewModel.restartGame()
                                } label: {
                                    Text("Restart game")
                                        .font(.system(size: 20))
                                        .frame(width: 150, height: 50)
                                }
                                .buttonStyle(BlueButtonStyle())
                            }
                        }
                    }
                    .overlay {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding(.top, 10)
                                    .onTapGesture {
                                        isGameOverViewPresented = false
                                    }
                                Spacer()
                            }
                            .padding(.trailing, 10)
                        }
                    }
                    .transition(.asymmetric(insertion: .opacity, removal: .identity))
            }
        }
        .animation(.easeInOut, value: isGameOverViewPresented)
    }

    @ViewBuilder
    func symbolButton(tile: Tile) -> some View {
        if let symbol = tile.symbol {
            RoundedRectangle(cornerRadius: 5)
                .fill(tile.color)
                .frame(width: 50, height: 70)
                .overlay {
                    Text(symbol.rawValue)
                        .font(.system(size: 20))
                        .foregroundStyle(tile.color == Color.unusedSymbol ? .black : .white)
                }
                .onTapGesture {
                    viewModel.selectSymbol(symbol)
                }
        }
    }

    func equationView(for attempt: Int) -> some View {
        let isCurrentAttempt = attempt == viewModel.game.currentAttempt
        let equation = viewModel.game.equations[attempt]
        return HStack(spacing: 5) {
            ForEach(Array(zip(equation.tiles.indices, equation.tiles)), id: \.0) { index, tile in
                RoundedRectangle(cornerRadius: 5)
                    .fill(tile.color)
                    .frame(width: 70, height: 70)
                    .overlay {
                        if tile == viewModel.selectedTile, isCurrentAttempt, !viewModel.game.isGameOver {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 3)
                                .frame(width: 70, height: 70)
                        }
                    }
                    .overlay {
                        if let text = tile.symbol?.rawValue {
                            Text(text)
                                .font(.system(size: 20))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .animation(.easeInOut(duration: 0.4).delay(TimeInterval(index) / 7), value: tile.color)
                    .onTapGesture {
                        guard isCurrentAttempt else { return }
                        selectTile(tile)
                    }
            }
        }
    }
    
    func selectTile(_ tile: Tile) {
        withAnimation(.easeInOut) {
            viewModel.selectTile(tile)
        }
    }
}

