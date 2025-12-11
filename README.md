# chesster

I'm making my own chess app gosh darn it. Don't think chess is fun? Then build yourself a chess app. Logic!

## To dos

- don't allow duplicate games (same players)
- don't allow duplicate usernames (might be working...)
- get firebasesdk team to allow `createUserWithEmailAndPassword` to not automatically sign user in. It messes with using the `authStateChanges` streambuilder, not to mention email authentication. This isn't a real todo, just complaining. I'll stick to a batch write with some firestore rules, which seems to work.
- figure out how to make the chess game actually work with a streambuilder. Probably like this:
```
1. Flip a coin to choose who's white and black. Not sure if it matters who flips the coin? I should probably look at how chess actually work in real life.
2. Now the game is active and we'll stream "moves" which will hopefully be extract..able from the `pieces` data, perhaps with `docChanges`?
3. It's dawning on me now that this "serverless" approach will allow malicious, cheating scum to send illegal moves and even move out of turn. Ugh guess if this actually takes off (it won't) I'll need to make a server to be the arbiter of truth. Booo! Just don't cheat! Or maybe cheating is the point of the app! It's a hacking app now!
4. When checkmate is achieved (think i still need to write this logic?? sounds kinda hard) blow it all up.
```
- Def work on those firebase rules...just generally