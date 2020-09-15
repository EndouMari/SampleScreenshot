//
//  ViewController.swift
//  SampleScreenShot
//
//  Created by mari.endo on 2020/09/15.
//  Copyright © 2020 mari.endo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var pdfView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        pdfView.layer.borderColor = UIColor.black.cgColor
        pdfView.layer.borderWidth = 5
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.window?.windowScene?.screenshotService?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.window?.windowScene?.screenshotService?.delegate = nil
    }
}

extension ViewController: UIScreenshotServiceDelegate {

    func screenshotService(_ screenshotService: UIScreenshotService,
                           generatePDFRepresentationWithCompletion completionHandler: @escaping (Data?, Int, CGRect) -> Void) {
        let renderer = UIGraphicsPDFRenderer(bounds: pdfView.bounds)

        let data = renderer.pdfData { context in
            context.beginPage()
            func recursiveDraw(view: UIView) {
                draw(view: view, context: context.cgContext, rootView: pdfView)
                view.subviews.forEach {
                    recursiveDraw(view: $0)
                }
            }
            pdfView.subviews.forEach {
                recursiveDraw(view: $0)
            }
            drawBorder(view: pdfView, context: context.cgContext)
        }
        UIGraphicsEndPDFContext()

        completionHandler(data, 0, view.bounds)
    }

    private func draw(view: UIView, context: CGContext, rootView: UIView) {
        let bounds = rootView.convert(view.bounds, from: view)
        context.saveGState()
        context.translateBy(x: bounds.minX, y: bounds.minY)
        context.setAlpha(view.alpha)

        if let backgroundColor = view.backgroundColor {
            backgroundColor.setFill()
            UIRectFill(view.bounds)
        }

        if let imageView = view as? UIImageView {
            imageView.image?.draw(in: imageView.contentModeBounds, blendMode: .normal, alpha: imageView.alpha)
        } else {
            view.draw(view.bounds)
        }

        context.restoreGState()
    }

    private func drawBorder(view: UIView, context: CGContext) {
        if let borderColor = view.layer.borderColor {
            let borderWidth = view.layer.borderWidth
            let path: UIBezierPath
            let rect: CGRect = .init(x: view.bounds.minX + (borderWidth / 2), y: view.bounds.minY + (borderWidth / 2), width: view.bounds.width - borderWidth, height: view.bounds.height - borderWidth)
            if view.layer.cornerRadius > 0 {
                path = UIBezierPath(roundedRect: rect, cornerRadius: view.layer.cornerRadius)
            } else {
                path = UIBezierPath(rect: rect)
            }

            UIColor(cgColor: borderColor).setStroke()
            path.lineWidth = borderWidth
            path.stroke()
        }
    }
}

extension UIImageView {

    private var aspectFitSize: CGSize {
        get {
            guard let aspectRatio = image?.size else { return .zero }
            let widthRatio = bounds.width / aspectRatio.width
            let heightRatio = bounds.height / aspectRatio.height
            let ratio = (widthRatio > heightRatio) ? heightRatio : widthRatio
            let resizedWidth = aspectRatio.width * ratio
            let resizedHeight = aspectRatio.height * ratio
            let aspectFitSize = CGSize(width: resizedWidth, height: resizedHeight)
            return aspectFitSize
        }
    }

    var aspectFitBounds: CGRect {
        get {
            let size = aspectFitSize
            return CGRect(origin: CGPoint(x: bounds.size.width * 0.5 - size.width * 0.5, y: bounds.size.height * 0.5 - size.height * 0.5), size: size)
        }
    }

    private var aspectFillSize: CGSize {
        get {
            guard let aspectRatio = image?.size else { return .zero }
            let widthRatio = bounds.width / aspectRatio.width
            let heightRatio = bounds.height / aspectRatio.height
            let ratio = (widthRatio < heightRatio) ? heightRatio : widthRatio
            let resizedWidth = aspectRatio.width * ratio
            let resizedHeight = aspectRatio.height * ratio
            let aspectFitSize = CGSize(width: resizedWidth, height: resizedHeight)
            return aspectFitSize
        }
    }

    var aspectFillBounds: CGRect {
        get {
            let size = aspectFillSize
            return CGRect(origin: CGPoint(x: bounds.origin.x - (size.width - bounds.size.width) * 0.5, y: bounds.origin.y - (size.height - bounds.size.height) * 0.5), size: size)
        }
    }

    var contentModeBounds: CGRect {
        guard let image = image else { return .zero }
        switch contentMode {
        case .scaleToFill, .redraw:
            return bounds
        case .scaleAspectFit:
            return aspectFitBounds
        case .scaleAspectFill:
            return aspectFillBounds
        case .center:
            let x = bounds.size.width * 0.5 - image.size.width * 0.5
            let y = bounds.size.height * 0.5 - image.size.height * 0.5
            return CGRect(origin: CGPoint(x: x, y: y), size: image.size)
        case .topLeft:
            return CGRect(origin: CGPoint.zero, size: image.size)
        case .top:
            let x = bounds.size.width * 0.5 - image.size.width * 0.5
            let y: CGFloat = 0
            return CGRect(origin: CGPoint(x: x, y: y), size: image.size)
        case .topRight:
            let x = bounds.size.width - image.size.width
            let y: CGFloat = 0
            return CGRect(origin: CGPoint(x: x, y: y), size: image.size)
        case .right:
            let x = bounds.size.width - image.size.width
            let y = bounds.size.height * 0.5 - image.size.height * 0.5
            return CGRect(origin: CGPoint(x: x, y: y), size: image.size)
        case .bottomRight:
            let x = bounds.size.width - image.size.width
            let y = bounds.size.height - image.size.height
            return CGRect(origin: CGPoint(x: x, y: y), size: image.size)
        case .bottom:
            let x = bounds.size.width * 0.5 - image.size.width * 0.5
            let y = bounds.size.height - image.size.height
            return CGRect(origin: CGPoint(x: x, y: y), size: image.size)
        case .bottomLeft:
            let x: CGFloat = 0
            let y = bounds.size.height - image.size.height
            return CGRect(origin: CGPoint(x: x, y: y), size: image.size)
        case .left:
            let x: CGFloat = 0
            let y = bounds.size.height * 0.5 - image.size.height * 0.5
            return CGRect(origin: CGPoint(x: x, y: y), size: image.size)
        @unknown default:
            return bounds
        }
    }
}
