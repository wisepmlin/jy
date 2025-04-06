//
//  MyIcon.swift
//  jy
//
//  Created by 林晓彬 on 2025/1/28.
//

import SwiftUI

/// 自定义图标形状组件
struct MyIcon: Shape {
    /// 绘制图标路径
    /// - Parameter rect: 绘制区域
    /// - Returns: 图标路径
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        // 绘制主体轮廓
        path.move(to: CGPoint(x: 0.99839*width, y: 0.52372*height))
        path.addCurve(to: CGPoint(x: 0.86961*width, y: 0.38057*height),
                      control1: CGPoint(x: 0.98763*width, y: 0.46372*height),
                      control2: CGPoint(x: 0.86961*width, y: 0.38057*height))
        path.addCurve(to: CGPoint(x: 0.63008*width, y: 0.19031*height),
                      control1: CGPoint(x: 0.81822*width, y: 0.28587*height),
                      control2: CGPoint(x: 0.67463*width, y: 0.21557*height))
        path.addCurve(to: CGPoint(x: 0.2723*width, y: 0.01247*height),
                      control1: CGPoint(x: 0.59924*width, y: 0.17315*height),
                      control2: CGPoint(x: 0.39664*width, y: 0.07375*height))
        
        // 绘制底部曲线
        path.addCurve(to: CGPoint(x: 0.21821*width, y: 0),
                      control1: CGPoint(x: 0.25555*width, y: 0.00432*height),
                      control2: CGPoint(x: 0.23702*width, y: 0.00005*height))
        path.addCurve(to: CGPoint(x: 0.1234*width, y: 0.04288*height),
                      control1: CGPoint(x: 0.18161*width, y: 0.00061*height),
                      control2: CGPoint(x: 0.14706*width, y: 0.01624*height))
        path.addCurve(to: CGPoint(x: 0.11133*width, y: 0.05871*height),
                      control1: CGPoint(x: 0.11935*width, y: 0.04841*height),
                      control2: CGPoint(x: 0.11469*width, y: 0.05314*height))
        
        // 绘制连接曲线
        path.addCurve(to: CGPoint(x: 0.1082*width, y: 0.06287*height),
                      control1: CGPoint(x: 0.11005*width, y: 0.05992*height),
                      control2: CGPoint(x: 0.10899*width, y: 0.06133*height))
        path.addLine(to: CGPoint(x: 0.10328*width, y: 0.07143*height))
        
        // 绘制右侧曲线
        path.addCurve(to: CGPoint(x: 0.0434*width, y: 0.62593*height),
                      control1: CGPoint(x: -0.0088*width, y: 0.23638*height),
                      control2: CGPoint(x: -0.03107*width, y: 0.44264*height))
        path.addCurve(to: CGPoint(x: 0.47934*width, y: 0.99707*height),
                      control1: CGPoint(x: 0.11786*width, y: 0.80923*height),
                      control2: CGPoint(x: 0.28002*width, y: 0.94728*height))
        
        // 绘制内部细节
        path.addCurve(to: CGPoint(x: 0.30631*width, y: 0.79397*height),
                      control1: CGPoint(x: 0.3756*width, y: 0.95419*height),
                      control2: CGPoint(x: 0.30631*width, y: 0.87965*height))
        path.addCurve(to: CGPoint(x: 0.38035*width, y: 0.64999*height),
                      control1: CGPoint(x: 0.30848*width, y: 0.73813*height),
                      control2: CGPoint(x: 0.33539*width, y: 0.68579*height))
        path.addLine(to: CGPoint(x: 0.38976*width, y: 0.64168*height))
        
        // 绘制装饰曲线
        path.addCurve(to: CGPoint(x: 0.41929*width, y: 0.6209*height),
                      control1: CGPoint(x: 0.39923*width, y: 0.63428*height),
                      control2: CGPoint(x: 0.40908*width, y: 0.62735*height))
        path.addCurve(to: CGPoint(x: 0.5445*width, y: 0.57807*height),
                      control1: CGPoint(x: 0.45749*width, y: 0.59857*height),
                      control2: CGPoint(x: 0.50012*width, y: 0.58398*height))
        path.addCurve(to: CGPoint(x: 0.83115*width, y: 0.60765*height),
                      control1: CGPoint(x: 0.64101*width, y: 0.56066*height),
                      control2: CGPoint(x: 0.74077*width, y: 0.57095*height))
        
        // 完成主体轮廓
        path.addCurve(to: CGPoint(x: 0.89914*width, y: 0.69337*height),
                      control1: CGPoint(x: 0.91299*width, y: 0.64235*height),
                      control2: CGPoint(x: 0.89914*width, y: 0.69337*height))
        path.addCurve(to: CGPoint(x: 0.95954*width, y: 0.6411*height),
                      control1: CGPoint(x: 0.92261*width, y: 0.67982*height),
                      control2: CGPoint(x: 0.94312*width, y: 0.66207*height))
        path.addCurve(to: CGPoint(x: 0.99843*width, y: 0.52326*height),
                      control1: CGPoint(x: 0.98844*width, y: 0.60833*height),
                      control2: CGPoint(x: 1.00244*width, y: 0.56591*height))
        path.addLine(to: CGPoint(x: 0.99839*width, y: 0.52372*height))
        path.closeSubpath()
        
        // 绘制内部装饰
        path.move(to: CGPoint(x: 0.5928*width, y: 0.38144*height))
        path.addCurve(to: CGPoint(x: 0.56553*width, y: 0.3716*height),
                      control1: CGPoint(x: 0.58341*width, y: 0.37898*height),
                      control2: CGPoint(x: 0.57428*width, y: 0.37568*height))
        path.addCurve(to: CGPoint(x: 0.46218*width, y: 0.23863*height),
                      control1: CGPoint(x: 0.49176*width, y: 0.3416*height),
                      control2: CGPoint(x: 0.46218*width, y: 0.23863*height))
        path.addCurve(to: CGPoint(x: 0.68582*width, y: 0.35817*height),
                      control1: CGPoint(x: 0.54036*width, y: 0.27196*height),
                      control2: CGPoint(x: 0.61521*width, y: 0.31197*height))
        path.addCurve(to: CGPoint(x: 0.5928*width, y: 0.38144*height),
                      control1: CGPoint(x: 0.66071*width, y: 0.38005*height),
                      control2: CGPoint(x: 0.62593*width, y: 0.38875*height))
        path.closeSubpath()
        
        return path
    }
}

struct LoadingIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.71*width, y: 0.59888*height))
        path.addCurve(to: CGPoint(x: 0.61502*width, y: 0.48554*height), control1: CGPoint(x: 0.70206*width, y: 0.55138*height), control2: CGPoint(x: 0.61502*width, y: 0.48554*height))
        path.addCurve(to: CGPoint(x: 0.43837*width, y: 0.33489*height), control1: CGPoint(x: 0.57712*width, y: 0.41056*height), control2: CGPoint(x: 0.47122*width, y: 0.3549*height))
        path.addCurve(to: CGPoint(x: 0.17451*width, y: 0.19408*height), control1: CGPoint(x: 0.41562*width, y: 0.32131*height), control2: CGPoint(x: 0.26621*width, y: 0.24261*height))
        path.addCurve(to: CGPoint(x: 0.13461*width, y: 0.18421*height), control1: CGPoint(x: 0.16215*width, y: 0.18763*height), control2: CGPoint(x: 0.14848*width, y: 0.18425*height))
        path.addCurve(to: CGPoint(x: 0.06469*width, y: 0.21816*height), control1: CGPoint(x: 0.10762*width, y: 0.1847*height), control2: CGPoint(x: 0.08214*width, y: 0.19707*height))
        path.addCurve(to: CGPoint(x: 0.05579*width, y: 0.2307*height), control1: CGPoint(x: 0.0617*width, y: 0.22254*height), control2: CGPoint(x: 0.05827*width, y: 0.22629*height))
        path.addCurve(to: CGPoint(x: 0.05348*width, y: 0.23399*height), control1: CGPoint(x: 0.05485*width, y: 0.23166*height), control2: CGPoint(x: 0.05407*width, y: 0.23277*height))
        path.addLine(to: CGPoint(x: 0.04985*width, y: 0.24077*height))
        path.addCurve(to: CGPoint(x: 0.00569*width, y: 0.67982*height), control1: CGPoint(x: -0.0328*width, y: 0.37138*height), control2: CGPoint(x: -0.04923*width, y: 0.53469*height))
        path.addCurve(to: CGPoint(x: 0.3272*width, y: 0.97368*height), control1: CGPoint(x: 0.06061*width, y: 0.82495*height), control2: CGPoint(x: 0.1802*width, y: 0.93426*height))
        path.addCurve(to: CGPoint(x: 0.19959*width, y: 0.81287*height), control1: CGPoint(x: 0.25069*width, y: 0.93973*height), control2: CGPoint(x: 0.19959*width, y: 0.88071*height))
        path.addCurve(to: CGPoint(x: 0.25419*width, y: 0.69887*height), control1: CGPoint(x: 0.20118*width, y: 0.76866*height), control2: CGPoint(x: 0.22103*width, y: 0.72722*height))
        path.addLine(to: CGPoint(x: 0.26113*width, y: 0.69229*height))
        path.addCurve(to: CGPoint(x: 0.28291*width, y: 0.67584*height), control1: CGPoint(x: 0.26811*width, y: 0.68643*height), control2: CGPoint(x: 0.27538*width, y: 0.68094*height))
        path.addCurve(to: CGPoint(x: 0.37525*width, y: 0.64192*height), control1: CGPoint(x: 0.31109*width, y: 0.65815*height), control2: CGPoint(x: 0.34252*width, y: 0.6466*height))
        path.addCurve(to: CGPoint(x: 0.58666*width, y: 0.66534*height), control1: CGPoint(x: 0.44643*width, y: 0.62813*height), control2: CGPoint(x: 0.52*width, y: 0.63629*height))
        path.addCurve(to: CGPoint(x: 0.6368*width, y: 0.73322*height), control1: CGPoint(x: 0.64701*width, y: 0.69282*height), control2: CGPoint(x: 0.6368*width, y: 0.73322*height))
        path.addCurve(to: CGPoint(x: 0.68135*width, y: 0.69183*height), control1: CGPoint(x: 0.65411*width, y: 0.72249*height), control2: CGPoint(x: 0.66924*width, y: 0.70843*height))
        path.addCurve(to: CGPoint(x: 0.71003*width, y: 0.59852*height), control1: CGPoint(x: 0.70266*width, y: 0.66588*height), control2: CGPoint(x: 0.71299*width, y: 0.6323*height))
        path.addLine(to: CGPoint(x: 0.71*width, y: 0.59888*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.41087*width, y: 0.48623*height))
        path.addCurve(to: CGPoint(x: 0.39076*width, y: 0.47844*height), control1: CGPoint(x: 0.40395*width, y: 0.48428*height), control2: CGPoint(x: 0.39721*width, y: 0.48167*height))
        path.addCurve(to: CGPoint(x: 0.31455*width, y: 0.37316*height), control1: CGPoint(x: 0.33635*width, y: 0.45468*height), control2: CGPoint(x: 0.31455*width, y: 0.37316*height))
        path.addCurve(to: CGPoint(x: 0.47948*width, y: 0.46781*height), control1: CGPoint(x: 0.3722*width, y: 0.39955*height), control2: CGPoint(x: 0.4274*width, y: 0.43123*height))
        path.addCurve(to: CGPoint(x: 0.41087*width, y: 0.48623*height), control1: CGPoint(x: 0.46096*width, y: 0.48513*height), control2: CGPoint(x: 0.43531*width, y: 0.49202*height))
        path.addLine(to: CGPoint(x: 0.41087*width, y: 0.48623*height))
        path.closeSubpath()
        return path
    }
}
