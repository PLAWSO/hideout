A game for the arcade cabinet.


# Overview
The only thing I'm sure about at this point is that Void Calibur will be a 2D scroller, with a space-y theme. As this is a first draft, everything else is subject to change. I want it small in scope, shooting for a minimum-viable-experience on March 22nd (two weeks). Most decisions will be impacted, if not solely decided, by that deadline, and the desire to have the game work on mobile devices.

# Gameplay
The player will control (see [Inputs](#Inputs)) a spaceship, switching it between three different parallel tracks, in order to avoid obstacles and score points. The tracks will run horizontally, with the spaceship (positioned on the left side of the screen) flying to the right through the obstacles.

The player should be scored by something like "enemy ships destroyed" or "near misses", not for how long they survive, the primary benefit of which is keeping runs short. If the player can survive, a full run should last about 3 minutes and definitively end, like an arcade game. This scoring method has the added benefit of keeping the entire run interesting, as scoring opportunities can be skill-locked throughout. Replayability should be emphasized with a [Leaderboard](#Leaderboard).

I want the game to be snappy. The spaceship should instantly switch between tracks and the speed at which the obstacles begin the game with should be quite high. It should be difficult. I don't think having "lives" is necessary; if the player collides with an obstacle, the game should end.

Obstacles could come in the form of asteroids, other space ships (friend or foe), or mines. Having them vary in size or speed could be interesting.

# Inputs
There will be 3 inputs: up, down, and shoot, with two control schemes: touch and keyboard. 

For touch, the top left quadrant of the screen will move the spaceship up, the bottom left quadrant will move the spaceship down, and the right half of the screen will shoot.

For keyboard, the "W" and "S" keys will be used to move the spaceship and "Space" will shoot.

Pressing up or down will move the spaceship to the respective track, and releasing both buttons will return the spaceship to the center track.

I'll need to work out how the input method will be determined. Both methods could always be available, or touch inputs could be disabled if a keyboard is detected. I'd like both options to always be available, but the touch inputs will have to jive with the GUI used to navigate the hideout.

# Music / SFX
I have no experience with music or sound effects, but they're core to the experience. One track playing on loop should suffice for music, sound effects will need to be created for:
1. Game start
2. Moving
3. Shooting
4. Destroying an obstacle
5. Running into an obstacle
6. Game over
7. Game complete

# Assets
Textures will need to be created for:
1. Spaceship
2. Obstacles (unsure which at this point)
3. Background
4. Projectiles

# GUI
The following screens will be required:

### Title
Should display:
1. Title
2. Start button
3. High scores
4. Background sample gameplay

This should be the default state if the arcade machine is unfocused.

### Controls
Should communicate the controls with graphics prior to the game being started.

### In-Game
Should display the player's current score.

### Enter Username
Displayed after the player's first run, it should capture the player's username (see [Usernames](#Usernames) and [Leaderboard](#Leaderboard))

### Game Over
Should display:
1. Game over message
2. The last run's score
3. The player's highest score
4. The player's absolute ranking on the leaderboard

It should also allow the player to restart.

### Game Complete
Ditto Game Over, but with a "You're Winner" message

# Usernames
The username gathered from the [Enter Name](###Enter_Name) screen will be stored in the browser's localStorage. It will be used when inserting records into the database and for determing the player's current ranking. This comes with the obvious drawbacks of players being able to edit their username in order to enter runs under different names or appear as though they are making runs they aren't. The only "real" solution to these problems is requiring players to sign in, and I don't want that level of friction. Seeing as that's essentially how arcade cabinets work, with the only method of discerning who made a run being the username, I'm okay with that compromise.

# Leaderboard
The site currently has no backend or DB. I'll likely use Vercel for the backend since that's where the site is hosted, and I'll seek out a free option for hosting the DB.

The DB will only need a table Run, in which a record is inserted for each run of the game (win or lose). It will look like this:
| Column | Data Type | Required |
| ------ | --------- | -------- |
| RunId | int | Yes |
| Username | varchar(10) | Yes |
| Score | int | Yes |
| Completed | bool | Yes |
| DoneOn | datetime | Yes |

Queries for the following actions will be required:
1. Inserting a record
2. Getting the absolute ranking of the player's highest score
3. Getting the top (3/5/10) high scores
