//
//  TableViewController.swift
//  SampleScreenShort
//
//  Created by mari.endo on 2020/09/13.
//  Copyright © 2020 mari.endo. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.window?.windowScene?.screenshotService?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.window?.windowScene?.screenshotService?.delegate = nil
    }
}

extension TableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}


extension TableViewController: UIScreenshotServiceDelegate {

    func screenshotService(_ screenshotService: UIScreenshotService,
                           generatePDFRepresentationWithCompletion completionHandler: @escaping (Data?, Int, CGRect) -> Void) {

        let renderer = UIGraphicsPDFRenderer(bounds: .init(origin: tableView.bounds.origin, size: tableView.contentSize))

        let data = renderer.pdfData { context in
            context.beginPage()
            func recursiveDraw(view: UIView) {
                draw(view: view, context: context.cgContext, rootView: tableView)
                view.subviews.forEach {
                    recursiveDraw(view: $0)
                }
            }
            let y = tableView.contentOffset.y
            let scrollCount = ceil(tableView.contentSize.height / tableView.frame.size.height)
            let showsVerticalScrollIndicator = tableView.showsVerticalScrollIndicator
            let showsHorizontalScrollIndicator = tableView.showsHorizontalScrollIndicator
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            tableView.contentOffset.y = 0
            (0..<Int(scrollCount)).forEach {
                tableView.contentOffset.y = tableView.frame.size.height * CGFloat($0)
                tableView.layoutIfNeeded()
                tableView.subviews.forEach {
                    recursiveDraw(view: $0)
                }
            }
            tableView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
            tableView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
            tableView.contentOffset.y = y
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

        view.draw(view.bounds)
        context.restoreGState()
    }
}
