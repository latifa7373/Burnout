//
//  SwipeBackEnabler.swift
//  burnout
//
//  Created by Noura Alsbuayt on 12/09/1447 AH.
//

// =========================
// =========================

import SwiftUI
import UIKit

struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            if let nav = vc.navigationController {
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = nil
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            if let nav = uiViewController.navigationController {
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = nil
            }
        }
    }
}

extension View {
    func enableSwipeBack() -> some View {
        background(SwipeBackEnabler().frame(width: 0, height: 0))
    }
}
