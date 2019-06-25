# SimpleDrawer ![alt text](https://travis-ci.com/jangelsb/SimpleDrawer.svg?branch=master "TravisCI `master` Build Status")

An iOS Framework that allows for a view controller to be embedded in a "drawer" (similar to Apple Maps, Shortcuts, the Stocks app, etc) -- but as a pull down drawer!

<br>

#### It is just about done, but has a couple things I still want to fix:
* Margin / safe area fixes
* Optional drawer handle indicator
* ~~When a user swipes up really fast when the drawer is open but the scroll view is not at the bottom, causing the scroll view inside the drawer to bounce really high. Then swiping up again the drawer to animate closed. The handle should animate with the velocity of the swipe, but currently teleports to the location of the gesture.~~
* iPad Support
* *Bonus: specify orientation (pull up or pull down drawer)*
