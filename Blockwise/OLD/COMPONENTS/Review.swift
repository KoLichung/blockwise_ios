//
//  Review.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/11/25.
//

import Foundation

struct Review: Identifiable {
    let id = UUID()
    let asset: String
    let name: String
    let title: String
    let body: String
    
    static let reviews: [Review] = [
        Review(
            asset: "user_feedback_photo_1",
            name: "_2tcc",
            title: "Does what it says!",
            body: "Sleep section has been blissful for me. Im asleep in 30 minutes. For sensitive needs the frequencies are wuite effective at shutting off mind chatter."
        ),
        
        Review(
            asset: "user_feedback_photo_2",
            name: "_2tcc",
            title: "Does what it says!",
            body: "Sleep section has been blissful for me. Im asleep in 30 minutes. For sensitive needs the frequencies are wuite effective at shutting off mind chatter."
        ),

        Review(
            asset: "user_feedback_photo_3",
            name: "_2tcc",
            title: "Does what it says!",
            body: "Sleep section has been blissful for me. Im asleep in 30 minutes. For sensitive needs the frequencies are wuite effective at shutting off mind chatter."
        ),

        Review(
            asset: "",
            name: "_2tcc",
            title: "Does what it says!",
            body: "Sleep section has been blissful for me. Im asleep in 30 minutes. For sensitive needs the frequencies are wuite effective at shutting off mind chatter."
        ),

        Review(
            asset: "",
            name: "_2tcc",
            title: "Does what it says!",
            body: "Sleep section has been blissful for me. Im asleep in 30 minutes. For sensitive needs the frequencies are wuite effective at shutting off mind chatter."
        ),

        Review(
            asset: "",
            name: "_2tcc",
            title: "Does what it says!",
            body: "Sleep section has been blissful for me. Im asleep in 30 minutes. For sensitive needs the frequencies are wuite effective at shutting off mind chatter."
        ),

        Review(
            asset: "",
            name: "_2tcc",
            title: "Does what it says!",
            body: "Sleep section has been blissful for me. Im asleep in 30 minutes. For sensitive needs the frequencies are wuite effective at shutting off mind chatter."
        ),

    ]
}
