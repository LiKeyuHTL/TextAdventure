:- dynamic(player/4).  % Added inventory as the fourth parameter
:- dynamic(object_at/2).
:- dynamic(npc_at/2).

% Player status (Name, Location, Health, Inventory)
player('Hero', 'Crash Site', 100, []).

% Object locations
object_at('Broken Gear', 'Crash Site').
object_at('Ancient Core', 'Ruined Tower').

% NPC locations
npc_at('Ancient Research Construct', 'Ruined Tower').
npc_at('Enraged Dragon', 'Sky Temple').
npc_at('Lost Sky Pirate', 'Floating Docks').

% Locations and paths
direction('Crash Site', east, 'Ruined Tower').
direction('Ruined Tower', west, 'Crash Site').

direction('Ruined Tower', north, 'Sky Temple').
direction('Sky Temple', south, 'Ruined Tower').

direction('Ruined Tower', east, 'Floating Docks').
direction('Floating Docks', west, 'Ruined Tower').

% Move the player
move(Direction) :-
    player(Name, Location, Health, Inventory),
    direction(Location, Direction, NewLocation),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, NewLocation, Health, Inventory)),
    look.

% Look around
look :-
    player(_, Location, _, _),
    write('You are in: '), write(Location), nl,
    list_objects(Location),
    list_npcs(Location),
    list_paths(Location).

% List objects in the area
list_objects(Location) :-
    findall(Object, object_at(Object, Location), Objects),
    (Objects \= [] -> (write('You see: '), write(Objects), nl) ; true).

% List NPCs in the area
list_npcs(Location) :-
    findall(NPC, npc_at(NPC, Location), NPCs),
    (NPCs \= [] -> (write('You encounter: '), write(NPCs), nl) ; true).

% List available paths
list_paths(Location) :-
    findall(Direction, direction(Location, Direction, _), Directions),
    write('Paths lead: '), write(Directions), nl.

% **Pick up objects (Add to inventory)**
take(Object) :-
    player(Name, Location, Health, Inventory),
    object_at(Object, Location),
    retract(object_at(Object, Location)),
    append([Object], Inventory, NewInventory),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, Health, NewInventory)),
    write('You picked up: '), write(Object), nl.

% **Drop objects (Remove from inventory)**
drop(Object) :-
    player(Name, Location, Health, Inventory),
    member(Object, Inventory),
    select(Object, Inventory, NewInventory),
    asserta(object_at(Object, Location)),  % Object returns to the world
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, Health, NewInventory)),
    write('You dropped: '), write(Object), nl.

% **Check Inventory**
inventory :-
    player(_, _, _, Inventory),
    (Inventory = [] -> write('Your inventory is empty.'), nl ;
     write('You are carrying: '), write(Inventory), nl).

% NPC interactions
talk(NPC) :-
    player(_, Location, _, _),
    npc_at(NPC, Location),
    interact(NPC).

interact('Ancient Research Construct') :-
    write('The construct scans you. "Unauthorized access detected. Leave or be eliminated."'), nl.

interact('Enraged Dragon') :-
    write('The dragon growls. "You awakened the old spirits, mortal. Prepare yourself."'), nl.

interact('Lost Sky Pirate') :-
    write('The pirate smirks. "Looking for help? It will cost you."'), nl.

% **Player abilities**
repair :-
    write('You attempt to repair the ancient machinery...'), nl,
    write('Some gears shift, but you need more parts.'), nl.

analyze :-
    write('You analyze the surroundings...'), nl,
    write('Strange energy pulses through the ruins. This technology is ancient but functional.'), nl.

negotiate :-
    player(_, Location, _, _),
    npc_at('Lost Sky Pirate', Location),
    write('The pirate considers your offer... "Alright, I might help you, if the price is right."'), nl.

% Movement commands
n :- move(north).
s :- move(south).
o :- move(east).
w :- move(west).

% **HELP FUNCTION**
help :-
    write('Available commands:'), nl,
    write('  start.         - Begin your adventure'), nl,
    write('  look.          - Look around your current location'), nl,
    write('  n. s. o. w.    - Move (north, south, east, west)'), nl,
    write('  take(Object).  - Pick up an object'), nl,
    write('  drop(Object).  - Drop an object'), nl,
    write('  inventory.     - Check your inventory'), nl,
    write('  talk(NPC).     - Talk to an NPC'), nl,
    write('  repair.        - Attempt to fix ancient machinery'), nl,
    write('  analyze.       - Analyze your surroundings'), nl,
    write('  negotiate.     - Try to negotiate with the Sky Pirate'), nl,
    write('  help.          - Show this list of commands'), nl.

% **Start the game**
start :-
    write('Welcome to The Machines of the Sky!'), nl,
    help,  % Show help menu at the start
    look.
