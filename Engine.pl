% filepath: c:\HTL\POSE_Theorie\TextAdventure\Engine.pl
:- dynamic(player/4).
:- dynamic(object_at/2).
:- dynamic(npc_at/2).

% Show welcome and help at load
:- initialization(main).
main :-
    write('Welcome to The Machines of the Sky!'), nl,
    write('Type start. to begin your adventure.'), nl,
    help.

% Object locations
object_at('Broken Gear', 'Crash Site').
object_at('Ancient Core', 'Ruined Tower').
object_at('Energy Cell', 'Ancient Workshop').
object_at('Plasma Cutter', 'Skyship Dock').
object_at('Skyforge Key', 'Ancient Workshop').
object_at('Rare Alloy', 'Floating Docks').
object_at('Dragon Scale', 'Sky Temple').

% NPC locations
npc_at('Ancient Research Construct', 'Ruined Tower').
npc_at('Enraged Dragon', 'Sky Temple').
npc_at('Lost Sky Pirate', 'Floating Docks').
npc_at('Mechanic', 'Ancient Workshop').
npc_at('Security Drone', 'Skyship Dock').
npc_at('Mysterious Merchant', 'Floating Docks').
npc_at('Skyforge Keeper', 'Skyforge').

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
direction('Sky Temple', east, 'Skyforge').
direction('Skyforge', west, 'Sky Temple').

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

interact('Skyforge Keeper') :-
    write('The Skyforge Keeper speaks: "Bring me the Rare Alloy and Dragon Scale, and I will craft a weapon of legend."'), nl.

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

% Player skill: analyze
analyze :-
    player(_, Location, _, _),
    (   object_at(Object, Location)
    ->  write('You analyze the area and spot: '), write(Object), nl,
        write('It appears to be ancient technology. Maybe it can be repaired or used.'), nl
    ;   npc_at(NPC, Location)
    ->  write('You analyze '), write(NPC), write('. Weaknesses or functions detected.'), nl
    ;   write('There is nothing unusual to analyze here.'), nl
    ).

% Player skill: negotiate (with Sky Pirate)
negotiate :-
    player(_, Location, _, _),
    npc_at('Lost Sky Pirate', Location),
    write('You negotiate with the Sky Pirate. He offers you a safe route for a price.'), nl.
negotiate :-
    write('There is no one here to negotiate with.'), nl.

% Ancient Research Construct skills
scan :-
    player(_, Location, _, _),
    npc_at('Ancient Research Construct', Location),
    write('The construct scans you. Threat level: moderate. It watches your every move.'), nl.

lockdown :-
    player(_, Location, _, _),
    npc_at('Ancient Research Construct', Location),
    write('The construct activates a lockdown! Exits are sealed.'), nl.

% Enraged Dragon skills
breathe_fire :-
    player(Name, Location, Health, Inventory),
    npc_at('Enraged Dragon', Location),
    NewHealth is Health - 40,
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, NewHealth, Inventory)),
    write('The dragon breathes fire! You are burned and lose 40 health.'), nl.

% Lost Sky Pirate skills
quickshot :-
    player(Name, Location, Health, Inventory),
    npc_at('Lost Sky Pirate', Location),
    NewHealth is Health - 20,
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, NewHealth, Inventory)),
    write('The Sky Pirate fires a quick shot! You lose 20 health.'), nl.

navigate :-
    player(_, Location, _, _),
    npc_at('Lost Sky Pirate', Location),
    write('The Sky Pirate shows you a hidden path through the ruins.'), nl.

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
    write('  analyze.       - Analyze technology or NPCs in the area'), nl,
    write('  negotiate.     - Negotiate with the Sky Pirate'), nl,
    write('  scan.          - (NPC) Construct scans you'), nl,
    write('  lockdown.      - (NPC) Construct locks down the area'), nl,
    write('  breathe_fire.  - (NPC) Dragon breathes fire'), nl,
    write('  quickshot.     - (NPC) Pirate fires a quick shot'), nl,
    write('  navigate.      - (NPC) Pirate finds a safe path'), nl,
    write('  help.          - Show this list of commands'), nl.

% Begin the adventure, ask for name, intro, etc.
start :-
    write('...'), nl,
    write('You wake up to the sound of crackling wires and distant thunder.'), nl,
    write('Your head aches. You remember falling...'), nl,
    write('But who are you?'), nl,
    write('What is your name? '),
    read(PlayerName),
    retractall(player(_,_,_,_)),
    asserta(player(PlayerName, 'Crash Site', 100, [])),
    nl, write('Welcome, '), write(PlayerName), write('.'), nl,
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

% Unlocking the Skyforge
unlock_skyforge :-
    player(_, Location, _, Inventory),
    Location = 'Sky Temple',
    member('Skyforge Key', Inventory),
    asserta(direction('Sky Temple', east, 'Skyforge')),
    write('You unlock the path to the Skyforge!'), nl.

% Crafting the Skyforge Weapon
craft_weapon :-
    player(_, Location, _, Inventory),
    Location = 'Skyforge',
    member('Rare Alloy', Inventory),
    member('Dragon Scale', Inventory),
    retract(player(_, Location, _, Inventory)),
    select('Rare Alloy', Inventory, TempInventory),
    select('Dragon Scale', TempInventory, NewInventory),
    asserta(player(_, Location, _, ['Skyforge Blade' | NewInventory])),
    write('The Skyforge Keeper crafts the Skyforge Blade for you!'), nl.