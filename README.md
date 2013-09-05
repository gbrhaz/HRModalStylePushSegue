# HRModalStylePushSegue

A segue subclass to alter the Push transition from one view controller to another.

This particular transition translates the destination view from the bottom to the top, like the modal transition.

A similar transition can be done with the `CATransition` class, but you're fairly limited with the transitions you make. The other 
issue with this method is the opacity value - they're hardcoded. 

## How to use it?

Simply set the class of the segue in your storyboard.