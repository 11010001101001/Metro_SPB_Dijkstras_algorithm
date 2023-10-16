import Foundation

extension AdjacencyList {
    func dijkstrasAlgorithm(from: Vertex<Station>, to: Vertex<Station>) {
        var shortestPath = [Vertex<Station>: Int]()
        
        /// Setting max distancies to all vertexes except `from` vertex
        let setMaxDistanciesOperation = BlockOperation { [weak self] in
            guard let self else { return }
            
            distancies[from] = .zero
            
            for vertex in Singleton.allVertexes where vertex != from {
                distancies[vertex] = Constants.maxDistance
            }
        }
        
        /// Visiting all vertexes to find the shortest path and mark visited ones
        let visitingVertexesOperation = BlockOperation { [weak self] in
            guard let self else { return }
            
            while distancies.values.contains(Constants.maxDistance) {
                
                guard let smallestOne = distancies.sorted(by: {$0.value < $1.value}).first?.key,
                      let edges = adjacencies[smallestOne]
                else { return }
                
                shortestPath[smallestOne] = distancies[smallestOne]
                
                for edge in edges {
                    let oldDistance = distancies[edge.destination] ?? .zero
                    let newDistance = (distancies[smallestOne] ?? .zero) + edge.weight
                    
                    if newDistance < oldDistance {
                        distancies[edge.destination] = newDistance
                        distanciesCopy[edge.destination] = newDistance
                        // let's add previous vertex according to the shortest path
                        pathDict[edge.destination] = edge.source
                    }
                }
                
                // let's mark visited vertex by it's deleting from dict
                distancies.removeValue(forKey: smallestOne)
            }
        }
        
        /// finding the shortest path, reversing the path to get right direction
        let findShortestPathOperation = BlockOperation { [weak self] in
            guard let self else { return}
            
            path.append(to)
            
            for _ in 0...pathDict.count {
                if let lastStation = path.last,
                   lastStation != from,
                   let previousVertex = pathDict[lastStation]
                {
                    path.append(previousVertex)
                }
            }
            
            path.reverse()
        }
        
        /// logging path info
        let makePathDetailsOperaion = BlockOperation { [weak self] in
            guard let self,
                  let startStation = path.first else { return }
            
            pathDetails.append("🏁 СТАРТ: \(startStation.data.name)")
            
            for (key,value) in distanciesCopy.sorted(by: {$0.value < $1.value}) {
                if path.contains(key) && !pathDetails.contains(key.data.name) {
                    let isFinishStation = key == to
                    let finishMessage = isFinishStation ? "✅ ФИНИШ: " : ""
                    pathDetails.append("\(finishMessage) \(value)' до станции \(key.data.name)")
                }
            }
        }
        
        lazy var queue: OperationQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            queue.qualityOfService = .userInteractive
            return queue
        }()
        
        visitingVertexesOperation.addDependency(setMaxDistanciesOperation)
        findShortestPathOperation.addDependency(visitingVertexesOperation)
        makePathDetailsOperaion.addDependency(findShortestPathOperation)
        
        lazy var operations = [
            setMaxDistanciesOperation,
            visitingVertexesOperation,
            findShortestPathOperation,
            makePathDetailsOperaion
        ]
        
        queue.addOperations(operations, waitUntilFinished: true)
    }
}

private enum Constants {
    static let maxDistance = 1000_000
}
