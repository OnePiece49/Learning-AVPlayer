//
//  LoadingView.swift
//  LAS_SAMPLE_014
//
//  Created by Đức Anh Trần on 20/06/2023.
//

import UIKit
import Lottie

struct LoadingViewConfig {
    var messageText: String
    var animationName: String
    var animationConfig: LottieAnimationConfig
}

struct LottieAnimationConfig {
    var estimatedWidth: CGFloat
    var aspectRatio: CGFloat
    var spacingFromVerticalCenter: CGFloat
    var spacingToImage: CGFloat = 30

}

class LoadingView: UIView {

    private let config: LoadingViewConfig

    private lazy var animationView: LottieAnimationView = {
        let animation = LottieAnimationView(name: config.animationName)
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 1
        return animation
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.fontMedium(20)
        label.textColor = UIColor(rgb: 0x000000)
        label.textAlignment = .center
        label.text = ""
        return label
    }()

    init(config: LoadingViewConfig) {
        self.config = config
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        messageLabel.text = config.messageText
        setupUI()
    }

    private func setupUI() {
        applyBlurBackground()
        setupConstraint()
    }

    private func setupConstraint() {
        addSubview(messageLabel)
        addSubview(animationView)
        let animationConfig = config.animationConfig

        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: animationConfig.spacingFromVerticalCenter),
            animationView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: animationConfig.estimatedWidth / 393),
            animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor, multiplier: 1 / animationConfig.aspectRatio),

            messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            messageLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: animationConfig.spacingToImage),
            messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20)
        ])
    }

    func show() {
        guard let window = UIWindow.keyWindow else { return }

        self.frame = window.bounds
        self.alpha = 0
        window.addSubview(self)

        UIView.animate(withDuration: 0.3, delay: 0) {
            self.alpha = 1
            self.animationView.play()
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.alpha = 0
        } completion: { finished in
            self.removeFromSuperview()
        }
    }
}
