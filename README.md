# xkcd

My favorite xkcd viewer app got taken off the app store, so I wasn't able to 
read comics on my new phone the way I liked. To get back at the world,
I decided to just create my own app that was basically the same functionality
anyway. It turns out it's a pretty simple app. 

The old app I belive was written in Objective-C. The world has changed,
so this one is now written in SwiftUI! How fun! I'd never used SwiftUI
before this so this was a good learning experience.

## Is this legal?

I'm like 99.9% sure that this is all kosher. Randall Munroe has pretty generous
[rules](https://xkcd.com/license.html) about using his work in non-commercial
settings. I'm not making any money from this app (in fact only losing money)
so I think this counts.

## TODO's

* Don't store image data in SwiftData, store a URL to the image on device instead.
* Make it optional whether or not the user saves an image forever. Some people don't want their storage used up by thousands of webcomics (though I personally do)
