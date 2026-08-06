//
//  AppLinks.swift
//  SlayGem
//

import Foundation

enum AppLinks {
  static let privacyPolicyURLString = "https://zorquintal.site/slaygem-policy"
  static let termsOfServiceURLString = "https://zorquintal.site/slaygem-terms"
  static let supportEmail = "stefansteets37@icloud.com"

  static var privacyPolicy: URL {
    URL(string: privacyPolicyURLString)!
  }

  static var termsOfService: URL {
    URL(string: termsOfServiceURLString)!
  }

  static var supportMailto: URL {
    URL(string: "mailto:\(supportEmail)")!
  }
}
