//
//  Grid.swift
//
import Foundation

public typealias GridPosition = (row: Int, col: Int)
public typealias GridSize = (rows: Int, cols: Int)

public func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

public enum CellState {
    case alive, empty, born, died
    
    public var isAlive: Bool {
        switch self {
        case .alive, .born: return true
        default: return false
        }
    }
}

public protocol GridProtocol {
    init(_ rows: Int, _ cols: Int, cellInitializer: (GridPosition) -> CellState)
    var description: String { get }
    var size: GridSize { get }
    subscript (row: Int, col: Int) -> CellState { get set }
    func next() -> Self
}

public let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { GridPosition($0) }
}


let offsets: [GridPosition] = [
    (row: -1, col:  -1), (row: -1, col:  0), (row: -1, col:  1),
    (row:  0, col:  -1),                     (row:  0, col:  1),
    (row:  1, col:  -1), (row:  1, col:  0), (row:  1, col:  1)
]

extension GridProtocol {
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: GridPosition) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: GridPosition) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Self {
        var nextGrid = Self(size.rows, size.cols) { _, _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        return nextGrid
    }
    
    public var aliveCount : Int {return lazyPositions(self.size).filter { return  self[$0.row, $0.col] == .alive }.count }
    public var bornCount  : Int {return lazyPositions(self.size).filter { return  self[$0.row, $0.col] == .born  }.count }
    public var diedCount  : Int {return lazyPositions(self.size).filter { return  self[$0.row, $0.col] == .died  }.count }
    public var emptyCount : Int {return lazyPositions(self.size).filter { return  self[$0.row, $0.col] == .empty }.count }
    
    func setConfiguration(currentStatistics statisticsData : [Int]) {
        
        var currentGridState : GridCurrentState = [
            "statistics" : [],
            "gridSize"   : [],
            "alive"      : [],
            "born"       : [],
            "died"       : []
        ]

        currentGridState["statistics"]!.append([statisticsData[0], statisticsData[1], statisticsData[2], statisticsData[3]])
        currentGridState["gridSize"]!.append([size.rows, size.cols])
        
        lazyPositions(self.size).forEach {
            switch self[$0.row, $0.col] {
            case .born:
                currentGridState["born"] = (currentGridState["born"] ?? []) + [[$0.row, $0.col]]
            case .died:
                currentGridState["died"] = (currentGridState["died"] ?? []) + [[$0.row, $0.col]]
            case .alive:
                currentGridState["alive"] = (currentGridState["alive"] ?? []) + [[$0.row, $0.col]]
            case .empty:
                ()
            }
        }
        
        //save current state to user defaults
        let defaults = UserDefaults.standard
        defaults.set(currentGridState, forKey: "savedSession")
    }
    
    func getAlivePositions() -> [[Int]] {
        var alivePositions = [[Int]]()
        lazyPositions(self.size).forEach {
            switch self[$0.row, $0.col] {
            case .alive:
                alivePositions = (alivePositions ?? []) + [[$0.row, $0.col]]
            default:
                ()
            }
        }
        return alivePositions
    }
}

public struct Grid: GridProtocol {
    private var _cells: [[CellState]]
    public let size: GridSize
    
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ rows: Int, _ cols: Int, cellInitializer: (GridPosition) -> CellState = { _, _ in .empty }) {
        _cells = [[CellState]](repeatElement( [CellState](repeatElement(.empty, count: rows)), count: cols))
        size = GridSize(rows, cols)
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
}

extension Grid: Sequence {
    public var living: [GridPosition] {
        return lazyPositions(self.size).filter { return  self[$0.row, $0.col].isAlive   }
    }
    
    public struct GridIterator: IteratorProtocol {
        private class GridHistory: Equatable {
            let positions: [GridPosition]
            let previous:  GridHistory?
            
            static func == (lhs: GridHistory, rhs: GridHistory) -> Bool {
                return lhs.positions.elementsEqual(rhs.positions, by: ==)
            }
            
            init(_ positions: [GridPosition], _ previous: GridHistory? = nil) {
                self.positions = positions
                self.previous = previous
            }
            
            var hasCycle: Bool {
                var prev = previous
                while prev != nil {
                    if self == prev { return true }
                    prev = prev!.previous
                }
                return false
            }
        }
        
        private var grid: GridProtocol
        private var history: GridHistory!
        
        init(grid: Grid) {
            self.grid = grid
            self.history = GridHistory(grid.living)
        }
        
        public mutating func next() -> GridProtocol? {
            if history.hasCycle { return nil }
            let newGrid:Grid = grid.next() as! Grid
            history = GridHistory(newGrid.living, history)
            grid = newGrid
            return grid
        }
    }
    
    public func makeIterator() -> GridIterator { return GridIterator(grid: self) }
}

public extension Grid {
    public static func gliderInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case (0, 1), (1, 2), (2, 0), (2, 1), (2, 2): return .alive
        default: return .empty
        }
    }
}






