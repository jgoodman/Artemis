# ARTEMIS

A game engine for a "choose your own adventure" type story game

# FORWARD

I've always wanted to make a game with WordPress; Not sure why but the idea has amused me for a long time.
Welp, my dreams are coming true! I figured that WordPress will be handling the front end while I can still
code any needed features in the backend. Most of this repo is the latter, a backend REST API that the
included WP plugin talks to.

# INSTALLATION

TBD

# ARCHITECURE OVERVIEW

## cgi-bin/artemis

The controller which handles and routes HTTP requests to Artemis perl modules. This utilizes the Mojolicious framework. 

## lib/Artemis

The model aiming to be domain-driven (I could be failing that already). These are Perl modules by the way which interfaces
with MySQL.

### Artemis::Action

Represents "doing" something in the gameworld. Often composed of conditions and operations. When you _execute_ an action,
The conditions are first evaluated; If they return true then the operations manipulate the game in some way, otherwise
an error is thrown. Some example actions are EnterSymposium, Move, Cast, Damage.

### Artemis::Board

Extends [Games::Board](http://search.cpan.org/~rjbs/Games-Board/lib/Games/Board.pm) CPAN Module; This module handles
the locations of Entites on a "world" board or combat boards (more broadly reffered to as symposiums).

### Artemis::Entity

A person, place, or thing that is in existance within the game world we are making.

### Artemis::Matriarch

The background director that automates similiar to a game master. Does this by making requests in the Symposium queue.

### Artemis::Symposium

A queue manger for turn-based events such as combat. Handles requests and executes them.

## wp-content/plugins/artemis.php

Plugin allowing WordPress to integrate with the Artemis API. Wordpress will be handling presentation
along with user management and authentication.

FrontEnd WordPress Screenshot

![A screenshot of the front end](images/FrontEnd_ScreenShot.png "WordPress ScreenShot")


