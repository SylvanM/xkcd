//
//  Settings.swift
//  xkcd
//
//  Created by Sylvan Lee Martin on 7/1/26.
//

import Foundation

/// A UserDefauts wrapper handling basic user settings
class Settings {
    
    private enum SettingKey: String {
        case searchBarOnTop = "searchBarOnTop"
        case preferUnread = "preferUnread"
        case downloadOnView = "downloadOnView"
        case downloadOnRefresh = "downloadOnRefresh"
    }
    
    private static let defaultSettings: [SettingKey : Bool] = [
        .searchBarOnTop     : true,
        .preferUnread       : true,
        .downloadOnView     : false,
        .downloadOnRefresh  : false,
    ]
    
    private static let defaults = UserDefaults.standard
    
    /// Whether or not the user wants the search bar on the top of the list page
    public static var searchBarOnTop: Bool {
        get { Self.defaults.bool(forKey: SettingKey.searchBarOnTop.rawValue) }
        set { Self.defaults.set(newValue, forKey: SettingKey.searchBarOnTop.rawValue) }
    }
    
    /// Whether or not the user wants to shuffle to an unread comic instead of a truly random one
    public static var preferUnread: Bool {
        get { Self.defaults.bool(forKey: SettingKey.preferUnread.rawValue) }
        set { Self.defaults.set(newValue, forKey: SettingKey.preferUnread.rawValue) }
    }
    
    /// Whether or not we should SAVE each comic when they're being viewed
    public static var downloadOnView: Bool {
        get { Self.defaults.bool(forKey: SettingKey.downloadOnView.rawValue) }
        set { Self.defaults.set(newValue, forKey: SettingKey.preferUnread.rawValue) }
    }
    
    /// Whether or not we automatically download the new comics that we detect upon refreshing
    public static var downloadOnRefresh: Bool {
        get { Self.defaults.bool(forKey: SettingKey.downloadOnRefresh.rawValue) }
        set { Self.defaults.set(newValue, forKey: SettingKey.downloadOnRefresh.rawValue) }
    }
    
    // MARK: Class Functions
    
    /// Sets all un-set preferences to the app defaults
    public static func writeDefaults(overwritingUserSettings: Bool = false) {
        for (setting, defaultValue) in defaultSettings {
            if Self.defaults.object(forKey: setting.rawValue) == nil || overwritingUserSettings {
                Self.defaults.set(defaultValue, forKey: setting.rawValue)
            }
        }
    }
    
}
