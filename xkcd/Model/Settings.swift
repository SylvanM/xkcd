//
//  Settings.swift
//  xkcd
//
//  Created by Sylvan Lee Martin on 7/1/26.
//

import Foundation

/// A UserDefauts wrapper handling basic user settings
class Settings {
    
    public enum SettingKey: String, CaseIterable, Identifiable {
        
        public var id: Self { self }
        
        /// Whether or not the user wants the search bar on the top of the list page
        case searchBarOnTop     = "searchBarOnTop"
        
        /// Whether or not the user wants to shuffle to an unread comic instead of a truly random one
        case preferUnread       = "preferUnread"
        
        /// Whether or not we should SAVE each comic when they're being viewed
        case downloadOnView     = "downloadOnView"
        
        /// Whether or not we automatically download the new comics that we detect upon refreshing
        case downloadOnRefresh  = "downloadOnRefresh"
        
        /// Whether or not to use the system's color theme (dark or light mode) instead of the default light mode
        /// that I think makes the comics look better
        case useSystemDefaultTheme = "useSystemDefaultTheme"
        
    }
    
    private static let defaultSettings: [SettingKey : Bool] = [
        .searchBarOnTop         : true,
        .preferUnread           : true,
        .downloadOnView         : false,
        .downloadOnRefresh      : false,
        .useSystemDefaultTheme  : false,
    ]
    
    private static let defaults = UserDefaults.standard
    
    // MARK: Class Functions
    
    /// Sets all un-set preferences to the app defaults
    public static func writeDefaults(overwritingUserSettings: Bool = false) {
        for (setting, defaultValue) in defaultSettings {
            if Self.defaults.object(forKey: setting.rawValue) == nil || overwritingUserSettings {
                Self.defaults.set(defaultValue, forKey: setting.rawValue)
            }
        }
    }
    
    /// Returns the human presentable title of the setting
    public static func title(forSetting key: SettingKey) -> String {
        switch key {
        case .searchBarOnTop:
            "Search Bar on Top"
        case .preferUnread:
            "Shuffle to Unread Comic"
        case .downloadOnView:
            "Download on View"
        case .downloadOnRefresh:
            "Download on Refresh"
        case .useSystemDefaultTheme:
            "Use System Colors"
        }
    }
    
    /// Returns the description of a particular setting for more detail
    public static func description(forSetting key: SettingKey) -> String {
        [
            .searchBarOnTop: "When on, the search bar appears at the top of the list page.",
            .preferUnread: "When on, shuffling to a random comic will go to one that you haven't already read, if such a comic exists.",
            .downloadOnView: "When on, a comic is automatically saved to your device when you open it. (Storage conscious people may leave this off)",
            .downloadOnRefresh: "When on, any comic that is detected on a refresh will be automatically saved to your device. (Storage conscious people may leave this off)",
            .useSystemDefaultTheme : "In my opinion, the comic viewing looks better in light mode. But, a lot of people really like dark mode. I don't love the idea of doing color-inversion on the comics themselves, so this results in a white comic on a black background. I personally think this looks odd, but perhaps you disagree!",
        ][key]!
    }
    
    // MARK: Subscripts
    
    static subscript(_ index: SettingKey) -> Bool {
        get { Self.defaults.bool(forKey: index.rawValue) }
        set { Self.defaults.set(newValue, forKey: index.rawValue) }
    }
    
}
