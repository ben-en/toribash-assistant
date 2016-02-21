# toribash-assistant

####Original author was dotproduct: http://forum.toribash.com/member.php?u=4353489

A fork of toribash assistant from http://forum.toribash.com/showthread.php?t=492156


Text copied directly from the forum, formatting did not follow. Some notes before the paste:

I found the emoting annoying, and disabled it with prejudice

Buttons show by default

Currently using 'b' key for show/hiding buttons


```
Joint Control Features
Buttons for all your joints, always in the same place. Depending on which quadrant of the button you click, you get Extend (E), Contract (C), Hold (X) or Relax (O).
Shoulders are labeled (R)aise and (L)ower, chest and lumbar (R)ight and (L)eft, neck and abs (F)orward and (B)ack.
Hold down the mouse button and drag across several joints to extend (raise) or contract (lower) them all at once. For instance, you can extend the glute, hip, knee, and ankle on one side with a single swipe. It's super effective!
Copy, Paste, and Mirror buttons do what they sound like.
You can drag the little [+] button at the bottom to reposition the GUI where you want it.
When time is running out, a visible bar near the GUI appears to alert you.
Move commit system: when you have a decent move set up, press Q to commit it. Then you can play around with your joints and try to find something better. If time runs out while you're doing that, your original move is automatically restored. If you do find something better, press Q to commit that one instead. You can also press shift+Q to go back to your last committed move.
Hovering over a joint in the GUI will highlight the corresponding joint on your Tori for easy identification.
Fractures and dismembers are now indicated on the GUI.
SpaceGuard: the spacebar is disabled for one second at the beginning of a match. It should prevent accidentally spacing the first move.
Mouseless Tori Control: You can now control all your joints with the keyboard! I've used the excellent layout suggested by snake that was implemented by Daanado in his mouseless Tori control script. Thanks and big credit to both of them! Here is an awesome guide by snake for the mouseless controls.

Move Memory Features
Totally revamped move memory system
You can now easily and conveniently save, rename, delete, rearrange, and activate saved move sequences.
Click here to see how it works
Dedicated onscreen buttons to load your own last opener and the opener of your most recent opponent.

Silly Features
Every five moves, your character emotes a random kung-fu-sounding move name, for example:
Drunken bandit foot
Turtle breath rebuke
Monkey turns away the sword
Seven scrolls style
Harmonious blade of the leopard
Pig knuckle cut
Magnificent mantis technique
Over 9,000 philosopher stance
You can now set the frequency of these emotes. Typing /ta set movenames N will make it happen every N moves. Setting this to zero will disable them completely.

Upcoming Features
At this point it does everything I've planned, and I consider it feature-complete.
But I'm still open to suggestions. If there's something you think would make it better, please let me know!

Known Bugs
SpaceGuard is not perfect. Sometimes it lets one through--I think it's because the match_begin event fires a tiny bit after you gain control of your Tori. I don't know if this is something I can fix or not, but I'm thinking about it. Still, it will catch most of them. Unfortunately, when it does let one through, your match will be desynchronized with the server. You can still play, but it will be hard to win because what you will be seeing will be different from the server's version.
Your name will be be printed in the chat box when you load the script. For some reason, the function that lets me find your player name also writes it to the screen, and there's nothing I can do about it.

How to Install
Save ta.lua to your Toribash/data/script folder.
In Toribash, go to Free Play and type /ls ta.lua. You should get a message like Toribash Assistant 0.x by dotproduct.
If this is the first time you've run it since 0.3, you will be asked to set up key bindings for mouseless control. Just follow the prompts in the chat box. You only have to do it once; after that, your settings are saved.
Start a new match by pressing Ctrl-N. The joint controls should appear. Have fun!

This is an alpha release--I'm sure there are bugs! I'd love to hear if you use this and especially about any bugs you might find.
```

https://dl.dropboxusercontent.com/u/1189614/web-images/ta-ss-05.png
