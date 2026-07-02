# xkcd

My favorite xkcd viewer app got taken off the app store, so I wasn't able to 
read comics on my new phone the way I liked. To get back at the world,
I decided to just create my own app that was basically the same functionality
anyway. It turns out it's a pretty simple app. 

The old app I belive was written in Objective-C. The world has changed,
so this one is now written in SwiftUI! How fun! I'd never used SwiftUI
before this so this was a good learning experience.

## Is this kosher?

Randall Munroe has pretty generous
[rules](https://xkcd.com/license.html) about using his work in non-commercial
settings. I'm not making any money from this app (in fact only losing money)
so I think this counts. 

## Philosophy

Alas, it appears that coding is a dying skill. This is a shame, since I have loved coding since I was maybe 7, 
and my enjoyment of it only grew since then. 

At work, I will use coding agents (like Claude Code) because it would be irresponsible for me not to. Even though
I believe that LLMs write *worse* code than any software engineer worth their salt, they can write it *so much faster*, and 
that's what matters. This app is purely for fun, with no rush to deploy, so every single line was written by me, 
because coding in Swift and in Xcode is one of life's greatest joys. 

## TODO's

These are changes I wish to make in future updates.

### Features I want to add

* Search bar - don't just search comic titles, but store the text in comics to search over that as well.
* Favorites
* Random Comic - With a setting to "prefer unread," so you can shuffle to a random unread comic!

### Changes I want to make

* Don't store image data in SwiftData, store a URL to the image on device instead.
* Make it optional whether or not the user saves an image forever. Some people don't want their storage used up by thousands of webcomics (though I personally do)
* Somehow a comic should be able to be downloaded without being read. I want to be able to read comics I haven't seen before while I'm camping.


