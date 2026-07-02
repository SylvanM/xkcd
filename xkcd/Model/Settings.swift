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
    }
    
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
    
}
