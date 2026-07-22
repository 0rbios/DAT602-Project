# DAT602 Project - WIP Document

#### Table of Contents

- [Game Summary](#game-summary)
- [Players](#players)
  - [Account Types](#account-types)
    - [Overview](#overview)
    - [Administrator](#administrators)
    - [Admin Abilities](#administrative-abilities)
    - [Player](#player)
    - [Player Abilties](#player-abilities)
    - [Login](#login)
- [Stats](#stats)
  - [Overview](#overview-1)
  - [Strength](#strength)
  - [Speed](#speed)
  - [Health](#health)
  - [Energy](#energy)
- [Classes](#classes)
  - [Overview](#overview-2)
  - [Gorilla](#gorilla)
  - [Cheetah](#cheetah)
  - [Eagle](#eagle)
  - [Tiger](#tiger)
- [Abilities](#abilities)
  - [Overview](#overview-3)
  - [Energy](#energy-1)
  - [Using Abilties](#using-abilties)
  - [Ability Availability](#ability-availability)
- [Score](#score)
  - [Overview](#overview-4)
- [Combat](#combat)
  - [Overview](#overview-5)
- [Map](#map)
  - [Tiles](#tiles)
    - [Overview](#overview-6)
    - [Home Tile](#home-tile)
    - [Spawning](#spawning)
  - [Movement](#movement)
    - [Overview](#overview-7)
- [Pickups](#pickups)
  - [Overview](#overview-8)
  - [Glitch Abilities](#glitch-abilities)
    - [Overview](#overview-9)
- [Chat](#chat)
  - [Overview](#overview-10)
- [Ability Library](#ability-library)
  - [Iron Core](#iron-core)
  - [Steel Core](#steel-core)
  - [Platinum Core](#platinum-core)
  - [Loose Spring](#loose-spring)
  - [Tight Spring](#tight-spring)
  - [Overtightened Spring](#overtightened-spring)
  - [Ping](#ping)
  - [Piston Wreck](#piston-wreck)
  - [Wing Swipe](#wing-swipe)
  - [Claw Strike](#claw-strike)
  - [Hyper-Speed Kick](#hyper-speed-kick)
  - [Jump-Kick](#jump-kick)
  - [Laser](#laser)
  - [Teleport](#teleport)
  - [Speed Shift](#speed-shift)
  - [Iron Plating](#iron-plating)
  - [Steel Pating](#steel-plating)
  - [Platinum Plating](#platinum-plating)
  - [Overcharge](#overcharge)
  - [Cell](#cell)
  - [Double-Cell](#double-cell)
  - [Triple-Cell](#triple-cell)
  - [Quad-Cell](#quad-cell)

## Game Summary

In this game, players take control of a robotic suit. They travel around a tile based map, picking up items which they can load into their suit to increase their power and score. Players can also battle each other to gain score and defend their high-score.

## Players

### Account Types

#### Overview

There are two account types:
- Administrator
- Player

#### Administrators

Adminsistrator accounts have a more back end view of the game which allows them to manage other accounts and game instances.

#### Administrative Abilities

Administrator accounts have the following abilities:
- Lock/Unlock accounts
- Delete accounts
- Change inactive account types (Admin/Player)
- Kick active accounts from the game
- Create new accounts
- Change the information of an existing account

#### Player

Player accounts have a more front end view of the game where they can play with other player accounts and engage with the gameplay.

#### Player Abilities

Users with player accounts have the ability to delete their own account.

#### Login

Each player has a username and password.

When a player attempts to log in, if the username they have entered is not in the database, the user will be asked if they want to make a new account, if they say yes then a new account will be created with the entered username and password.

When a new account is created, the player will automatically be joined into the game.

If the username is in the database but the entered password does not match, the player will be told that the login failed and asked to try again.

If the player inputs a wrong password 5 times, the username they were attempting to log in to will be locked and they will be presented with an administrator email to contact. Locked accounts cannot be logged in to by anyone until an administrator unlocks the account.

If the username and password are correct, the player will be successfully logged in and able to play.

### Stats

#### Overview

There are 4 stats:
- Strength
- Speed
- Health
- Energy

Each player also has a stat total which is determined by the sum of the 4 stat values. (E.g. 2 Strength + 2 Speed + 1 Health + 1 Energy = 6 Stat Total)

#### Strength

Strength is the stat used to determine damage output.

#### Speed

Speed is the stat used to determine thefrequency and movement time for a player to go to different tiles.

#### Health

Health is the player stat that affects the maximum health value a player can have.

#### Energy

Energy is the player stat that affects the speed which players regenerate energy at.

### Classes

#### Overview

There are 4 classes:
- Gorilla
- Cheetah
- Eagle
- Tiger

Each class has an increase (+1) to 2 stats and a decrease (-1) to 2 stats.

Each class also has a unique starting ability.

#### Gorilla

The gorilla class begins with increased strength and health but decreased speed and energy.

The gorilla class starts with the piston wreck ability.

#### Cheetah

The cheetah class begins with increased speed and energy but decreased strength and health.

The cheetah class starts with the hyper-speed kick ability.

#### Eagle

The eagle class begins with increased speed and health but decreased strength and energy.

The eagle class starts with the wing swipe ability.

#### Tiger

The tiger class begins with increased strength and energy but decreased speed and health.

The tiger class starts with the claw strike ability.

### Abilities

#### Overview

Abilities are actions which energy can be enpended to use.

Any class can use any ability.

Each ability has the following details:
- Name
- Description
- Value
- Energy cost
- Use time

Abilities which can be used in combat also have a damage output.

The value of each ability changes the player's score. When an item is removed from the player's inventory, their score will decrease. When an item is added, it will increase.

#### Energy

Every ability uses some amount of energy. Energy regenerates at a speed based on the player's energy stat.

#### Using Abilties

Players can use abilties by clicking on an available ability icon.

#### Ability Availability

Ability availability is based on the following criteria:
- Ability use case
- Energy cost vs energy amount
- Recently used abilities

##### Ability Use Case

If an ability can only be used in combat, but the player is not engaged in combat, then the ability will not be available.

##### Energy Cost VS Energy Amount

If the amount of energy which an ability needs is greater than the player's current energy amount, the ability won't be available.

##### Recently Used Abilities

For a short period (~0.5 Seconds) after an ability is used, it will be unavailable. This is more to avoid ability spam.

### Score

#### Overview

Player score is counted in Netrix ( ~~N~~ ).

Each player has a score which increases as they play.

When a player is defeated, their score resets to 0.

Each player also has a high score which is displayed in the leaderboard.

### Combat

#### Overview

When one player is adjacent to another player, they can click on the other player to engage in combat.

Combat can be exited by clicking on another tile to move away.

When in combat, players use their combat abilities to damage each other and reduce their opponents health.

Winning in combat increases the winning player's score based on the score of the losing player and their stat point total.

## Map

### Tiles

#### Overview

The map is made up of tiles. Each tile can contain 4 items and (with one exception) 1 player.

#### Home Tile

All players initially start on the home tile, this is the only tile which is able to hold multiple players.

#### Spawning

When a player leaves and rejoins the game, they will be placed back on the tile which they were on when they left the game. If this is not possible, then they will be asked to select a new valid tile to spawn on.

### Movement

#### Overview

Players move around the map by clicking on adjacent tiles. If a tile is empty (no other player on it) then the player is able to move to it, otherwise they will engage in combat with the other player.

The amount of time which a player must wait to move is determined by their speed stat, with 0 wait time being the absolute minimum.

Players can still enter combat and access the tiles items while they are waiting to be able to move again.

If two players click on the same empty tile, the first player to click the tile will be the one who moves, the other player will not move.

## Pickups

### Overview

Players pick up items from tiles. Every item grants the user either an ability or stat change.

Players can hold up to 4 ability items and 4 stat items.

To pick up or drop an item, the player clicks on the item and then where what valid inventory slot they want to move it to (this can either be on the player or the tile).

Pickups are NOT dropped on defeat.

### Glitch Abilities

#### Overview

Glitch abilities are pickups which randomly move around the map to empty tiles every second. If a player moves to a tile with a glitch ability, it will temporarily stop moving.

As soon as the player leaves the tile, the glitch ability will move.

## Chat

### Overview

Players are able to send messages through the in-game chat.

Each message has a username, send datetime, and the message text itself.

## Ability Library

The following is a list of each ability and its details:

### Iron Core

#### Type: **Upgrade**

#### Description:

+1 Health | -1 Speed

A forged iron core to increase the durability of a suit.

#### Value: **5 ~~N~~**

---

### Steel Core

#### Type: **Upgrade**

#### Description:

+3 Health | -2 Speed

A forged steel core to better increase the durability of a suit.

#### Value: **10 ~~N~~**

---

### Platinum Core

#### Type: **Upgrade**

#### Description:

+5 Health | -3 Speed

A forged platinum core to greatly increase the durability of a suit.

#### Value: **15 ~~N~~**

---

### Loose Spring

#### Type: **Upgrade**

#### Description:

+1 Health | -1 Strength

A stretched spring, not very springy but bends easily.

#### Value: **5 ~~N~~**

---

### Tight Spring

#### Type: **Upgrade**

#### Description:

+1 Strength | +1 Energy | -2 Health

A firm spring, plenty of potential energy but not very flexible.

#### Value: **10 ~~N~~**

---

### Overtightened Spring

#### Type: **Upgrade**

#### Description:

+3 Energy | +2 Strength | -4 Health

A spring that seems to have somehow been twisted past its usual breaking point. Extremely high potential energy but will not hold up well to stress.

#### Value: **15 ~~N~~**

---

### Ping

#### Type: **Ability (Utility)**

#### Description:

Scan the surrounding area for signals. (Tile inventory will include surrounding tiles as well until player moves)

#### Value: **12 ~~N~~**

#### Energy Cost: **5**

---

### Piston Wreck

#### Type: **Ability (Combat) - Gorilla Starting Ability**

#### Description:

Utilise the added force of the pistons in a suit to increase the power of a punch.

#### Value: **6 ~~N~~**

#### Energy Cost: **1**

#### Base Damage: **2**

---

### Wing Swipe

#### Type: **Ability (Combat) - Eagle Starting Ability**

#### Description:

Swipe a suit's wing (or arm) with the added assistance of its propulsion jet.

#### Value: **6 ~~N~~**

#### Energy Cost: **1**

#### Base Damage: **2**

---

### Claw Strike

#### Type: **Ability (Combat) - Tiger Starting Ability**

#### Description:

Use a suits claws (or fist) to damage a target.

#### Value: **6 ~~N~~**

#### Energy Cost: **1**

#### Base Damage: **2**

---

### Hyper-Speed Kick

#### Type: **Ability (Combat) - Cheetah Starting Ability**

#### Description:

Utilise the fast bearings in a suits legs to kick a target at increased speed.

#### Value: **6 ~~N~~**

#### Energy Cost: **1**

#### Base Damage: **2**

---

### Jump-Kick

#### Type: **Ability (Combat)**

#### Description:

Jump into the air and kick a target.

#### Value: **10 ~~N~~**

#### Energy Cost: **4**

#### Base Damage: **5**

---

### Laser

#### Type: **Ability (Combat)**

#### Description:

Fire a high-powered laser at a target.

#### Value: **16 ~~N~~**

#### Energy Cost: **6**

#### Base Damage: **10**

---

### Teleport

#### Type: **<span style="color:lime"><i>Glitch</i></span> Ability (Utility)**

#### Description:

Phase-shift a suit and its occupant to a different place. (Move to any empty tile on the map)

#### Value: **30 ~~N~~**

#### Energy Cost: **10**

---

### Speed Shift

#### Type: **<span style="color:lime"><i>Glitch</i></span> Upgrade**

#### Description:

+5 Speed

A mechanical switch which makes it substantially faster to shift up (and down) speed levels of a suit.

#### Value: **25 ~~N~~**

---

### Iron Plating

#### Type: **Upgrade**

#### Description:

+1 Health | -1 Energy

Forged iron plating for the exterior of a suit. Seems to interfere with energy conduction.

#### Value: **5 ~~N~~**

---

### Steel Plating

#### Type: **Upgrade**

#### Description:

+3 Health | -2 Energy

Forged steel plating for the exterior of a suit. Seems to interfere with energy conduction.

#### Value: **10 ~~N~~**

---

### Platinum Plating

#### Type: **Upgrade**

#### Description:

+5 Health | -3 Energy

Forged platinum plating for the exterior of a suit. Seems to interfere with energy conduction.

#### Value: **20 ~~N~~**

---

### Overcharge

#### Type: **<span style="color:lime"><i>Glitch</i></span> Upgrade**

#### Description:

+5 Energy

Send an excess amount of energy around the suit, disregarding component damage.

#### Value: **28 ~~N~~**

---

### Cell

#### Type: **Upgrade**

#### Description:

+1 Energy | -1 Strength

An energy cell to store energy for later use. Seems to bounce off of surfaces easily.

#### Value: **3 ~~N~~**

---

### Double-Cell

#### Type: **Upgrade**

#### Description:

+4 Energy | -2 Strength

Two energy cells to store more energy for later use. Seem to bounce off of surfaces easily.

#### Value: **6 ~~N~~**

---

### Triple-Cell

#### Type: **Upgrade**

#### Description:

+6 Energy | -3 Strength

Three energy cells to store a lot more energy for later use. Seem to bounce off of surfaces easily.

#### Value: **12 ~~N~~**

---

### Quad-Cell

#### Type: **Upgrade**

#### Description:

+8 Energy | -5 Strength

Four energy cells to store an overwhelming amount of energy for later use. Seem to bounce off of surfaces easily. One might question the diminishing returns of so many cells.

#### Value: **24 ~~N~~**
