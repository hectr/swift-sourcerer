import Foundation

extension GraphViz {
    public enum ArrowHead: String {
        case invdot
        case invodot
        case empty
        case invempty
        case ediamond
        case open
        case halfopen
        case box, lbox, rbox, obox, olbox, orbox
        case crow, lcrow, rcrow
        case diamond, ldiamond, rdiamond, odiamond, oldiamond, ordiamond
        case dot, odot
        case inv, linv, rinv, oinv, olinv, orinv
        case none
        case normal, lnormal, rnormal, onormal, olnormal, ornormal
        case tee, ltee, rtee
        case vee, lvee, rvee
        case curve, lcurve, rcurve, icurve, licurve, ricurve
    }

    public enum Direction: String {
        case topToBottom = "TB"
        case bottomToTop = "BT"
        case leftToRight = "LR"
        case rightToLeft = "RL"
    }

    public enum NodePolygonShape: String {
        case box, polygon, ellipse, oval
        case circle, point, egg, triangle
        case plaintext, plain, diamond, trapezium
        case parallelogram, house, pentagon, hexagon
        case septagon, octagon, doublecircle, doubleoctagon
        case tripleoctagon, invtriangle, invtrapezium, invhouse
        case mDiamond = "Mdiamond"
        case mSquare = "Msquare"
        case mCircle = "Mcircle"
        case rect
        case rectangle, square, star, none
        case underline, cylinder, note, tab
        case folder, box3d, component, promoter
        case cds, terminator, utr, primersite
        case restrictionsite, fivepoverhang, threepoverhang, noverhang
        case assembly, signature, insulator, ribosite
        case rnastab, proteasesite, proteinstab, rpromoter
        case rarrow, larrow, lpromoter
    }

    public enum NodeStyle: String {
        case solid
        case dashed
        case dotted
        case bold
        case rounded
        case diagonals
        case filled
    }

    public enum EdgeStyle: String {
        case solid
        case dashed
        case dotted
        case bold
    }
}
