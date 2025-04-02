:- dynamic(player/4).
:- dynamic(object_at/2).
:- dynamic(npc_at/2).

% Player status (Name, Location, Health, Inventory)
player('Hero', 'Crash Site', 100, []).

% Object locations
object_at('Broken Gear', 'Crash Site').
object_at('Ancient Core', 'Ruined Tower').
object_at('Energy Cell', 'Ancient Workshop').
object_at('Plasma Cutter', 'Skyship Dock').

% NPC locations
npc_at('Ancient Research Construct', 'Ruined Tower').
npc_at('Enraged Dragon', 'Sky Temple').
npc_at('Lost Sky Pirate', 'Floating Docks').
npc_at('Mechanic', 'Ancient Workshop').
npc_at('Security Drone', 'Skyship Dock').
npc_at('Mysterious Merchant', 'Floating Docks').

% Locations and paths
direction('Crash Site', east, 'Ruined Tower').
direction('Ruined Tower', west, 'Crash Site').

direction('Ruined Tower', north, 'Sky Temple').
direction('Sky Temple', south, 'Ruined Tower').

direction('Ruined Tower', east, 'Floating Docks').
direction('Floating Docks', west, 'Ruined Tower').

direction('Floating Docks', south, 'Skyship Dock').
direction('Skyship Dock', north, 'Floating Docks').

direction('Ruined Tower', west, 'Ancient Workshop').
direction('Ancient Workshop', east, 'Ruined Tower').

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

% Pick up objects (Add to inventory)
take(Object) :-
    player(Name, Location, Health, Inventory),
    object_at(Object, Location),
    retract(object_at(Object, Location)),
    append([Object], Inventory, NewInventory),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, Health, NewInventory)),
    write('You picked up: '), write(Object), nl.

% Drop objects (Remove from inventory)
drop(Object) :-
    player(Name, Location, Health, Inventory),
    member(Object, Inventory),
    select(Object, Inventory, NewInventory),
    asserta(object_at(Object, Location)),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, Health, NewInventory)),
    write('You dropped: '), write(Object), nl.

% Check Inventory
inventory :-
    player(_, _, _, Inventory),
    (Inventory = [] -> write('Your inventory is empty.'), nl ;
     write('You are carrying: '), write(Inventory), nl).

% NPC interactions
talk(NPC) :-
    player(_, Location, _, _),
    npc_at(NPC, Location),
    interact(NPC).

% Unique NPC dialogues
interact('Ancient Research Construct') :-
    write('The construct scans you. "Unauthorized access detected. Leave or be eliminated."'), nl.

interact('Enraged Dragon') :-
    write('The dragon growls. "You awakened the old spirits, mortal. Prepare yourself."'), nl.

interact('Lost Sky Pirate') :-
    write('The pirate smirks. "Looking for help? It will cost you."'), nl.

interact('Mechanic') :-
    write('The mechanic wipes oil from their hands. "Need something fixed? You better have parts."'), nl.

interact('Security Drone') :-
    write('The drone hovers. "INTRUDER ALERT! Leave immediately!"'), nl.

interact('Mysterious Merchant') :-
    write('The merchant grins. "I have rare goods. But they don’t come cheap."'), nl.

% Player abilities
repair :-
    player(_, _, _, Inventory),
    member('Broken Gear', Inventory),
    member('Ancient Core', Inventory),
    write('You assemble the broken parts... The ancient machine hums to life!'), nl.

trade :-
    player(_, Location, _, Inventory),
    npc_at('Mysterious Merchant', Location),
    member('Energy Cell', Inventory),
    retract(player(_, Location, _, Inventory)),
    select('Energy Cell', Inventory, NewInventory),
    asserta(player(_, Location, _, ['Plasma Cutter' | NewInventory])),
    write('You trade the Energy Cell for a Plasma Cutter!'), nl.

attack :-
    player(_, Location, _, Inventory),
    npc_at('Security Drone', Location),
    member('Plasma Cutter', Inventory),
    retract(npc_at('Security Drone', Location)),
    write('You destroy the drone with the Plasma Cutter! The path is clear.'), nl.

sneak :-
    player(_, Location, _, _),
    npc_at('Security Drone', Location),
    write('You carefully sneak past the drone, avoiding its sensors.'), nl.

% Movement commands
w :- move(north).
s :- move(south).
d :- move(east).
a :- move(west).

% HELP FUNCTION
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
    write('  trade.         - Trade with the Mysterious Merchant'), nl,
    write('  attack.        - Attack the Security Drone (requires Plasma Cutter)'), nl,
    write('  sneak.         - Try to sneak past an enemy'), nl,
    write('  help.          - Show this list of commands'), nl.

% Start the game
start :-
    write('Welcome to The Machines of the Sky!'), nl,
    help,  % Show help menu at the start
    look.


% Enhanced Repair Function
repair :-
    player(_, Location, _, Inventory),
    (
        % Fixing the Ancient Machine
        (member('Broken Gear', Inventory), member('Ancient Core', Inventory)) ->
        (
            write('You assemble the broken parts... The ancient machine hums to life!'), nl,
            write('A hidden passage is revealed!'), nl,
            retract(object_at('Broken Gear', Location)),
            retract(object_at('Ancient Core', Location)),
            asserta(direction(Location, north, 'Secret Chamber'))
        );

        % Upgrading the Plasma Cutter
        (member('Plasma Cutter', Inventory), member('Energy Cell', Inventory)) ->
        (
            write('You insert the Energy Cell into the Plasma Cutter... It glows with new power!'), nl,
            write('Your attacks are now stronger!'), nl,
            retract(object_at('Energy Cell', Location)),
            asserta(object_at('Plasma Cutter+', Location))
        );

        % Repairing the Skyship
        (member('Skyship Engine', Inventory), member('Ancient Core', Inventory), member('Energy Cell', Inventory)) ->
        (
            write('You install the Skyship Engine, connecting it with the Ancient Core...'), nl,
            write('The ship roars to life! You have a way home!'), nl,
            write('Congratulations! You can now escape!'), nl,
            retract(object_at('Skyship Engine', Location)),
            retract(object_at('Ancient Core', Location)),
            retract(object_at('Energy Cell', Location)),
            asserta(object_at('Repaired Skyship', 'Skyship Dock'))
        );

        % No valid repair combination
        write('You don’t have the right parts to repair anything.'), nl
    ).