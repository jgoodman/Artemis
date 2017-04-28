# ARTEMIS

A backend REST API that serves as a game engine for "choose your own adventure" type story games.

The intent is to have a CMS (WordPress) to handle the front end while the backend API
provides enforcement of game logic. Included within this repo is a WordPress plugin which interfaces
with the API.

Your frontend does not have to be WordPress. The selling point of this engine is to liberate you to
using whatever system or tools that you want to use for your frontend. Code your game as a Desktop
App in Java or use Unity instead, your restrictions are being able to make HTTP requests and
following the Artemis paradigm.

# INSTALLATION

TODO: Would like to write out a Makefile to handle installation and deployment

# CONFIGURATION

Copy the Artemis/config-sample to Artemis/config. This file will contain settings such as what
storage driver to use and connection information. Modify this file accordingly so.

# ARCHITECURE OVERVIEW

The backend takes a MVC approach hence this section being organized accordingly so.

## View

### cgi-bin/artemis

Utilizes the Mojolicious framework, this handles and routes HTTP requests to the controller layer (Artemis modules)

## Controller

Perl modules by the way which interface with the Model. Still deciding if these should be in moved to an
Artemis::Controller:: namespace as of April 12, 2017.

### Artemis::Actions

Represents "doing" something in the gameworld. Often composed of conditions and operations. When you _execute_ an action,
The conditions are first evaluated; If they return true then the operations manipulate the game in some way, otherwise
an error is thrown. Some example actions are "EnterSymposium", "Move", "Cast", "Damage".

### Artemis::Board

Extends [Games::Board](http://search.cpan.org/~rjbs/Games-Board/lib/Games/Board.pm) CPAN Module; This module handles
the locations of Entites on a "world" board or combat boards (more broadly reffered to as symposiums).

### Artemis::Entity

A person, place, or thing that is in existance within the game world we are making.

### Artemis::Matriarch

The background director that automates similiar to a game master. Does this by making requests in the Symposium queue.

### Artemis::Symposium

A queue manger for turn-based events such as combat. Handles requests and executes them.

## Artemis::Model

A unified interface for multiple storage drivers (residing in the Artemis::Storage namespace). The controller passes
in a data structure and the model breaks in down to smaller components. Each component is then supplied to the
storage driver to be saved. The model also retrieves, updates, or deletes records through deletation of the
storage driver.

### Artemis::Storage::MySQL

Driver to create, retrieve, update, or delete a record via MySQL database

### Artemis::Storage::FileSystem

Driver to create, retrieve, update, or delete a record via filesystem

### Artemis::Storage::Mock

A mocked driver interface used for testing (does nothing

## Client

### wp-content/plugins/artemis.php

Plugin allowing WordPress to integrate with the Artemis API. Wordpress will be handling presentation
along with user management and authentication.

FrontEnd WordPress Screenshot

![A screenshot of the front end](images/FrontEnd_ScreenShot.png "WordPress ScreenShot")

# EXAMPLES

As of April 9, 2017, much of Artemis' functionality is still in development when this section was written.

In the curl examples, assume _localhost_ as the address which Artemis is running at.

## Character

This section pertains to character manipulation

### Create

    curl -X POST localhost/cgi-bin/artemis/character

Returns the newly created CharacterId

### Retrieve

    curl localhost/cgi-bin/artemis/character/:CharacterId

Returns stats and other information for given CharacterId

### Update

Resources to update the character

#### Move

    curl -X PUT localhost/cgi-bin/artemis/character/:CharacterId/location/:LocationId

Moves a character to a new location. Restraints are that the previous location has been listed as valid
within the new location. If attempting an illegal move then an error occurs.

# TESTS

Unit tests are location in the t directory of this repo. A requirement to running some of these tests is
having Test::Class installed.

