//
//  UserInformation.swift
//  OnTheMap
//
//  Created by Daniel Soutar on 20/09/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import Foundation

// Annoyingly need to create most of the UserInformation struct.
// Is there any way this could have been avoided? Why can't we just
// use Data? instead?
struct UserInformation: Decodable {
    let lastName: String
    let socialAccounts: [JSONAny]
    let mailingAddress: JSONNullable?
    let cohortKeys: [JSONAny]
    let signature, stripeCustomerID: JSONNullable?
    let userDataResponseGuard: Guard
    let facebookID, timezone, sitePreferences, occupation: JSONNullable?
    let image: JSONNullable?
    let firstName: String
    let jabberID, languages: JSONNullable?
    let badges: [JSONAny]
    let location, externalServicePassword: JSONNullable?
    let principals, enrollments: [JSONAny]
    let email: Email
    let websiteURL: JSONNullable?
    let externalAccounts: [JSONAny]
    let bio, coachingData: JSONNullable?
    let tags, affiliateProfiles: [JSONAny]
    let hasPassword: Bool
    let emailPreferences, resume: JSONNullable?
    let key, nickname: String
    let employerSharing: Bool
    let memberships: [JSONAny]
    let zendeskID: JSONNullable?
    let registered: Bool
    let linkedinURL, googleID: JSONNullable?
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case socialAccounts = "social_accounts"
        case mailingAddress = "mailing_address"
        case cohortKeys = "_cohort_keys"
        case signature
        case stripeCustomerID = "_stripe_customer_id"
        case userDataResponseGuard = "guard"
        case facebookID = "_facebook_id"
        case timezone
        case sitePreferences = "site_preferences"
        case occupation
        case image = "_image"
        case firstName = "first_name"
        case jabberID = "jabber_id"
        case languages
        case badges = "_badges"
        case location
        case externalServicePassword = "external_service_password"
        case principals = "_principals"
        case enrollments = "_enrollments"
        case email
        case websiteURL = "website_url"
        case externalAccounts = "external_accounts"
        case bio
        case coachingData = "coaching_data"
        case tags
        case affiliateProfiles = "_affiliate_profiles"
        case hasPassword = "_has_password"
        case emailPreferences = "email_preferences"
        case resume = "_resume"
        case key, nickname
        case employerSharing = "employer_sharing"
        case memberships = "_memberships"
        case zendeskID = "zendesk_id"
        case registered = "_registered"
        case linkedinURL = "linkedin_url"
        case googleID = "_google_id"
        case imageURL = "_image_url"
    }
}

struct Email: Codable {
    let address: String
    let verified: Bool
    let verificationCodeSent: Bool

    enum CodingKeys: String, CodingKey {
        case address
        case verified = "_verified"
        case verificationCodeSent = "_verification_code_sent"
    }
}

// Useless empty struct to ensure everything is codable.
struct Guard: Codable {}
