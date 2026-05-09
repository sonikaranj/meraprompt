import Foundation
import google_mobile_ads

class NativeAdFactoryExample: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        let adView = NativeAdView()
        adView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        // Headline
        let headlineLabel = UILabel()
        headlineLabel.text = nativeAd.headline
        headlineLabel.textColor = .white
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headlineLabel.numberOfLines = 2
        adView.headlineView = headlineLabel

        // Body
        let bodyLabel = UILabel()
        bodyLabel.text = nativeAd.body
        bodyLabel.textColor = UIColor.lightGray
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        bodyLabel.numberOfLines = 3
        adView.bodyView = bodyLabel

        // Icon
        if let icon = nativeAd.icon {
            let iconView = UIImageView()
            iconView.image = icon.image
            iconView.contentMode = .scaleAspectFit
            iconView.layer.cornerRadius = 8
            iconView.clipsToBounds = true
            adView.iconView = iconView
            adView.addSubview(iconView)

            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 16),
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
                iconView.widthAnchor.constraint(equalToConstant: 60),
                iconView.heightAnchor.constraint(equalToConstant: 60)
            ])
        }

        // Call to Action Button
        let ctaButton = UIButton(type: .system)
        ctaButton.setTitle(nativeAd.callToAction ?? "Learn More", for: .normal)
        ctaButton.backgroundColor = UIColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0)
        ctaButton.setTitleColor(.black, for: .normal)
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        ctaButton.layer.cornerRadius = 8
        ctaButton.isUserInteractionEnabled = false
        adView.callToActionView = ctaButton

        // Add views
        adView.addSubview(headlineLabel)
        adView.addSubview(bodyLabel)
        adView.addSubview(ctaButton)

        // Constraints
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.translatesAutoresizingMaskIntoConstraints = false

        let iconOffset: CGFloat = (nativeAd.icon != nil) ? 88 : 16

        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 16),
            headlineLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: iconOffset),
            headlineLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),

            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),

            ctaButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 16),
            ctaButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            ctaButton.heightAnchor.constraint(equalToConstant: 44),
            ctaButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -16)
        ])

        adView.nativeAd = nativeAd

        return adView
    }
}
