//
//  TemperatureChartView.swift
//  PetMil
//
//  Created by Emil on 09.04.2026.
//

import UIKit

final class TemperatureChartView: UIView {
    
    var onPointSelected: ((Int) -> Void)?
    
    private var points: [CGPoint] = []
    private var temperatures: [Double] = []
    private var selectedIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(temperatures: [Double], selectedIndex: Int = 0) {
        self.temperatures = temperatures
        self.selectedIndex = selectedIndex
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    func updateSelectedIndex(_ index: Int) {
        selectedIndex = index
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recalculatePoints()
    }
    
    override func draw(_ rect: CGRect) {
        guard points.count > 1 else { return }
        
        let path = UIBezierPath()
        path.lineWidth = 3
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        UIColor.label.setStroke()
        path.stroke()
        
        for (index, point) in points.enumerated() {
            let size: CGFloat = index == selectedIndex ? 12 : 8
            let circleRect = CGRect(
                x: point.x - size / 2,
                y: point.y - size / 2,
                width: size,
                height: size
            )
            
            let circlePath = UIBezierPath(ovalIn: circleRect)
            (index == selectedIndex ? UIColor.systemBlue : UIColor.label).setFill()
            circlePath.fill()
        }
    }
}

private extension TemperatureChartView {
    func recalculatePoints() {
        guard !temperatures.isEmpty, bounds.width > 0, bounds.height > 0 else {
            points = []
            return
        }
        
        let minTemp = temperatures.min() ?? 0
        let maxTemp = temperatures.max() ?? 0
        let tempRange = max(maxTemp - minTemp, 1)
        
        let horizontalInset: CGFloat = 16
        let verticalInset: CGFloat = 20
        
        let usableWidth = bounds.width - horizontalInset * 2
        let usableHeight = bounds.height - verticalInset * 2
        
        points = temperatures.enumerated().map { index, temp in
            let x: CGFloat
            
            if temperatures.count == 1 {
                x = bounds.midX
            } else {
                x = horizontalInset + (usableWidth * CGFloat(index) / CGFloat(temperatures.count - 1))
            }
            
            let normalized = CGFloat((temp - minTemp) / tempRange)
            let y = bounds.height - verticalInset - (normalized * usableHeight)
            
            return CGPoint(x: x, y: y)
        }
    }
    
    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        guard !points.isEmpty else { return }
        
        let nearestIndex = points.enumerated().min { lhs, rhs in
            abs(lhs.element.x - location.x) < abs(rhs.element.x - location.x)
        }?.offset ?? 0
        
        selectedIndex = nearestIndex
        setNeedsDisplay()
        onPointSelected?(nearestIndex)
    }
}
