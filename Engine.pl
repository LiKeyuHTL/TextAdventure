% filepath: c:\HTL\POSE_Theorie\TextAdventure\Engine.pl
:- dynamic(player/4).
:- dynamic(object_at/2).
:- dynamic(npc_at/2).
:- dynamic(main_quest/1).
:- dynamic(game_over/0).
:- dynamic(visited/1).
:- dynamic(direction/3).
:- dynamic(in_battle/4).

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
object_at('Plasma Cutter', 'Secret Chamber').
object_at('Broken Gold Pistole', 'Secret Chamber').
object_at('Mysterious Metal', 'Secret Chamber').
object_at('Skyforge Key', 'Ancient Workshop').
object_at('Rare Alloy', 'Floating Docks').
object_at('Dragon Scale', 'Sky Temple').
object_at('Skyship Engine', 'Ancient Workshop').

% NPC locations
npc_at('Ancient Console', 'Ruined Tower').
npc_at('Enraged Dragon', 'Sky Temple').
npc_at('Lost Sky Pirate', 'Floating Docks').
npc_at('Mysterious Merchant', 'Mysterious Workshop').
npc_at('Security Drone', 'Skyship Dock').
npc_at('Skyforge Keeper', 'Skyforge').

% Locations and paths
direction('Crash Site', east, 'Ruined Tower').
direction('Ruined Tower', north, 'Sky Temple').
direction('Ruined Tower', south, 'Floating Docks').
direction('Ruined Tower', west, 'Crash Site').
direction('Floating Docks', north, 'Ruined Tower').
direction('Floating Docks', east, 'Mysterious Workshop').
direction('Floating Docks', south, 'Skyship Dock').
direction('Mysterious Workshop', west, 'Floating Docks').
direction('Sky Temple', east, 'Skyforge').
direction('Sky Temple', south, 'Ruined Tower').
direction('Skyship Dock', north, 'Floating Docks').
direction('Skyforge', west, 'Sky Temple').

% Move the player
move(Direction) :-
    player(Name, Location, Health, Inventory),
    direction(Location, Direction, NewLocation),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, NewLocation, Health, Inventory)),
    (visited(NewLocation) -> true ; asserta(visited(NewLocation))),
    look.

% Look around
look :-
    player(_, Location, _, _),
    write('You are in: '), write(Location), nl,
    list_objects(Location),
    list_npcs(Location),
    list_paths_with_names(Location), nl.

% List available paths with destination names (show ??? for unreached locations)
list_paths_with_names(Location) :-
    findall(Direction-Dest, direction(Location, Direction, Dest), Paths),
    (Paths = [] ->
        write('No paths from here.'), nl
    ;
        write('Paths:'), nl,
        show_paths_with_mask(Paths)
    ).

show_paths_with_mask([]).
show_paths_with_mask([Direction-Dest|Rest]) :-
    (visited(Dest) ->
        write('  '), write(Direction), write(': '), write(Dest), nl
    ;
        write('  '), write(Direction), write(': ???'), nl
    ),
    show_paths_with_mask(Rest).  

% List objects in the area
list_objects(Location) :-
    findall(Object, object_at(Object, Location), Objects),
    (Objects \= [] -> (write('You see: '), write(Objects), nl) ; true).

% List NPCs in the area
list_npcs(Location) :-
    findall(NPC, npc_at(NPC, Location), NPCs),
    (NPCs \= [] -> (write('You encounter: '), write(NPCs), nl) ; true).

% Pick up objects (Add to inventory)
take(Object) :-
    player(Name, Location, Health, Inventory),
    object_at(Object, Location),
    retract(object_at(Object, Location)),
    append([Object], Inventory, NewInventory),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, Health, NewInventory)),
    write('You picked up: '), write(Object), nl,
    check_story_progress.

take :-
    player(Name, Location, Health, Inventory),
    findall(Object, object_at(Object, Location), Objects),
    ( Objects = [] ->
        write('There is nothing to take here.'), nl
    ;
        take_all_objects(Objects, Name, Location, Health, Inventory)
    ).

take_all_objects([], Name, Location, Health, Inventory) :-
    asserta(player(Name, Location, Health, Inventory)),
    write('You picked up everything here.'), nl.
take_all_objects([Object|Rest], Name, Location, Health, Inventory) :-
    retract(object_at(Object, Location)),
    append([Object], Inventory, NewInventory),
    take_all_objects(Rest, Name, Location, Health, NewInventory).

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

% Unique NPC dialogues
interact('Ancient Console') :-
    write('The Ancient Console displays fragments of information about the island.'), nl,
    write('You piece together the story from the console and your own discoveries:'), nl,
    write('"This island was once the secret forge of the Akians, a kingdom bent on world domination.'), nl,
    write('Here, new weapons were created for their armies under the rule of a tyrant.'), nl,
    write('As the war turned against the Akians, the tyrant sought a final, desperate measure:'), nl,
    write('He planned to use a piece of the moon as a meteor to destroy his enemies.'), nl,
    write('This island was chosen as the test site for the doomsday weapon.'), nl,
    write('But something went wrong. The test failed, and the entire island vanished from the world."'), nl,
    write('You feel the weight of ancient history and the danger that once threatened all kingdoms.'), nl, !.

interact('Enraged Dragon') :-
    write('The dragon growls. "You awakened the old spirits, mortal. Prepare yourself."'), nl,
    player(_, Location, _, _),
    npc_at('Enraged Dragon', Location),
    enemy_stats('Enraged Dragon', EnemyMaxHP, EnemyAttack),
    retractall(in_battle(_,_,_,_)),
    asserta(in_battle('Enraged Dragon', EnemyMaxHP, EnemyMaxHP, EnemyAttack)),
    write('The Enraged Dragon roars and attacks!'), nl,
    show_battle_status('Enraged Dragon', EnemyMaxHP, EnemyMaxHP, EnemyAttack).

interact('Lost Sky Pirate') :-
    player(Name, Location, HP, Inventory),
    ( member('Broken Gold Pistole', Inventory), member('Mysterious Metal', Inventory) ->
        select('Broken Gold Pistole', Inventory, TempInventory),
        select('Mysterious Metal', TempInventory, NewInventory),
        retract(player(Name, Location, HP, Inventory)),
        asserta(player(Name, Location, HP, NewInventory)),
        write('The Sky Pirate grins: "I\'ll take that broken gold pistole and this mysterious metal. I\'ll help you as promised, but don\'t expect me to risk my own neck in a fight!"'), nl,
        asserta(skypirate_help),
        write('The Sky Pirate is going to help you now in the battle!'), nl
    ; write('The Sky Pirate grins: "You should look for some valuable goods. I heard there\'s something interesting in the broken tower."'), nl,
      write('Maybe you should analyze the Ruined Tower for hidden secrets.'), nl
    ).

interact('Security Drone') :-
    write('The drone hovers. "INTRUDER ALERT! Leave immediately!"'), nl.

interact('Mysterious Merchant') :-
    write('The merchant grins. "I have rare goods. But they don’t come cheap."'), nl.

interact('Skyforge Keeper') :-
    write('The Skyforge Keeper speaks: "Bring me the Rare Alloy and Dragon Scale, and I will craft a weapon of legend."'), nl.

% Player abilities
repair :-
    player(Name, Location, Health, Inventory),
    member('Plasma Cutter', Inventory),
    member('Broken Gear', Inventory),
    member('Ancient Core', Inventory),
    select('Plasma Cutter', Inventory, Temp1),
    select('Broken Gear', Temp1, Temp2),
    select('Ancient Core', Temp2, NewInventory),
    asserta(player(Name, Location, Health, ['Plasma Cutter+'|NewInventory])),
    retract(player(Name, Location, Health, Inventory)),
    write('You combine the Broken Gear and Ancient Core with your Plasma Cutter.'), nl,
    write('It transforms into a powerful Plasma Cutter+!'), nl, !.

repair :-
    write('You don\'t have the right parts to repair or upgrade anything.'), nl.

trade :-
    player(_, Location, _, Inventory),
    npc_at('Mysterious Merchant', Location),
    member('Energy Cell', Inventory),
    retract(player(_, Location, _, Inventory)),
    select('Energy Cell', Inventory, NewInventory),
    asserta(player(_, Location, _, ['Plasma Cutter' | NewInventory])),
    write('You trade the Energy Cell for a Plasma Cutter!'), nl.

% Start a battle if an enemy is present and not already in battle
attack :-
    in_battle(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack), !,
    continue_battle(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack).
attack :-
    player(_, Location, _, _),
    npc_at('Enraged Dragon', Location),
    enemy_stats('Enraged Dragon', EnemyMaxHP, EnemyAttack),
    retractall(in_battle(_,_,_,_)),
    DragonStartHP is EnemyMaxHP - 20,
    asserta(in_battle('Enraged Dragon', DragonStartHP, EnemyMaxHP, EnemyAttack)),
    write('You catch the Enraged Dragon off guard! It starts the battle with 20 less HP.'), nl,
    show_battle_status('Enraged Dragon', DragonStartHP, EnemyMaxHP, EnemyAttack).
attack :-
    player(_, Location, _, _),
    npc_at(Enemy, Location),
    enemy_stats(Enemy, EnemyMaxHP, EnemyAttack),
    retractall(in_battle(_,_,_,_)),
    asserta(in_battle(Enemy, EnemyMaxHP, EnemyMaxHP, EnemyAttack)),
    write('A wild '), write(Enemy), write(' appears!'), nl,
    show_battle_status(Enemy, EnemyMaxHP, EnemyMaxHP, EnemyAttack).
attack :-
    write('There is nothing to attack here.'), nl.

% Show battle status and wait for player to enter attack command
show_battle_status(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack) :-
    player(PlayerName, _, PlayerHP, _),
    write('--- BATTLE ---'), nl,
    write(PlayerName), write(' HP: '), show_life_bar(PlayerHP, 100), write(' ('), write(PlayerHP), write('/100)'), nl,
    write(Enemy), write(' HP: '), show_life_bar(EnemyHP, EnemyMaxHP), write(' ('), write(EnemyHP), write('/'), write(EnemyMaxHP), write(')'), nl,
    write('Type attack. to attack!'), nl,
    fail.

% Continue the battle phase after player enters attack.
continue_battle(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack) :-
    player(PlayerName, PlayerLoc, PlayerHP, Inventory),
    player_attack(Inventory, Damage),
    ( skypirate_help ->
        TotalDamage is Damage + 10,
        write('You attack '), write(Enemy), write(' for '), write(Damage), write(' damage!'), nl,
        write('The Sky Pirate helps and deals 10 extra damage!'), nl
    ;
        TotalDamage = Damage,
        write('You attack '), write(Enemy), write(' for '), write(Damage), write(' damage!'), nl
    ),
    NewEnemyHP is EnemyHP - TotalDamage,
    ( NewEnemyHP =< 0 ->
        ( skypirate_help ->
            write('The Sky Pirate uses Quickshot and deals 10 final damage!'), nl,
            FinalEnemyHP is NewEnemyHP - 10
        ;
            FinalEnemyHP = NewEnemyHP
        ),
        ( FinalEnemyHP =< 0 ->
            write('You defeated '), write(Enemy), write('!'), nl,
            ( Enemy = 'Enraged Dragon' ->
                asserta(dragon_help),
                write('The dragon bows its head: "You have proven your strength. I will help you reach your destinations quicker."'), nl,
                write('Hint: You can now use fly(\'Location\'). to travel instantly to any main location!'), nl
            ; true ),
            retract(npc_at(Enemy, PlayerLoc)),
            retractall(in_battle(_,_,_,_)),
            retract(player(PlayerName, PlayerLoc, PlayerHP, Inventory)),
            asserta(player(PlayerName, PlayerLoc, 100, Inventory)),
            ( skypirate_help -> retract(skypirate_help) ; true ),
            write('You heal yourself after the battle. Your HP is restored to 100.'), nl,
            check_story_progress
        ;   enemy_turn(Enemy, FinalEnemyHP, EnemyMaxHP, EnemyAttack)
        )
    ; enemy_turn(Enemy, NewEnemyHP, EnemyMaxHP, EnemyAttack)
    ).

% Player attack damage (stronger if Plasma Cutter+)
player_attack(Inventory, 50) :- member('Plasma Cutter+', Inventory), !.
player_attack(Inventory, 30) :- member('Plasma Cutter', Inventory), !.
player_attack(_, 10).

% Enemy turn, then show updated life bars and wait for next attack
enemy_turn(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack) :-
    player(PlayerName, PlayerLoc, PlayerHP, Inventory),
    write(Enemy), write(' attacks you for '), write(EnemyAttack), write(' damage!'), nl,
    NewPlayerHP is PlayerHP - EnemyAttack,
    retract(player(PlayerName, PlayerLoc, PlayerHP, Inventory)),
    ( NewPlayerHP =< 0 ->
        asserta(player(PlayerName, PlayerLoc, 100, Inventory)),
        retractall(in_battle(_,_,_,_)),
        write('You have been defeated by '), write(Enemy), write('!'), nl,
        write('But you miraculously escape from death and flee the battle!'), nl,
        write('You heal yourself after the battle. Your HP is restored to 100.'), nl
    ;
        asserta(player(PlayerName, PlayerLoc, NewPlayerHP, Inventory)),
        retractall(in_battle(_,_,_,_)),
        asserta(in_battle(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack)),
        show_battle_status(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack)
    ).

% Show a simple ASCII life bar
show_life_bar(Value, Max) :-
    BarLen is 20,
    Filled is max(0, min(BarLen, round((Value / Max) * BarLen))),
    Empty is BarLen - Filled,
    forall(between(1, Filled, _), write('#')),
    forall(between(1, Empty, _), write('-')).

% Enemy stats (add more as needed)
enemy_stats('Enraged Dragon', 200, 40).
enemy_stats('Security Drone', 190, 55).

analyze :-
    player(_, Location, _, _),
    Location = 'Ruined Tower',
    (   \+ direction('Ruined Tower', east, 'Secret Chamber')
    ->  write('You notice strange markings and a hidden mechanism on the wall.'), nl,
        write('It looks like there could be a secret chamber to the east.'), nl,
        asserta(direction('Ruined Tower', east, 'Secret Chamber')),
        asserta(direction('Secret Chamber', west, 'Ruined Tower')),
        write('You discover a hidden passage to the east!'), nl
    ;   true
    ),
    write('The Ancient Console looks broken. Maybe you could use a Broken Gear and an Ancient Core to upgrade your Plasma Cutter.'), nl,
    analyze_npcs(Location), !.
analyze :-
    player(_, Location, _, _),
    (   object_at(Object, Location)
    ->  write('You analyze the area and spot: '), write(Object), nl,
        write('It appears to be ancient technology. Maybe it can be repaired or used.'), nl
    ;   true
    ),
    analyze_npcs(Location), !.

analyze_npcs(Location) :-
    findall(NPC, npc_at(NPC, Location), NPCs),
    ( NPCs = [] -> true
    ; write('You analyze the NPCs here:'), nl,
      forall(member(N, NPCs), describe_npc(N))
    ).

describe_npc('Ancient Console') :-
    write('  Ancient Console: Might reveal the secrets of the island if you interact with it.'), nl.
describe_npc('Enraged Dragon') :-
    write('  Enraged Dragon: A powerful foe. Prepare for a tough battle!'), nl.
describe_npc('Lost Sky Pirate') :-
    write('  Lost Sky Pirate: Maybe you can get his help for a price.'), nl.
describe_npc('Security Drone') :-
    write('  Security Drone: Dangerous. You may need a weapon to defeat it.'), nl.
describe_npc('Mysterious Merchant') :-
    write('  Mysterious Merchant: Trades rare items for the right price and can help repair or upgrade technology.'), nl.
describe_npc('Skyforge Keeper') :-
    write('  Skyforge Keeper: Can craft legendary weapons if you bring rare materials.'), nl.
describe_npc(NPC) :-
    write('  '), write(NPC), write(': No special information.'), nl.

status :-
    player(Name, _, HP, Inventory),
    write('Status for '), write(Name), write(':'), nl,
    write('HP: '), show_life_bar(HP, 100), write(' ('), write(HP), write('/100)'), nl,
    player_attack(Inventory, Damage),
    write('Attack Damage: '), write(Damage), nl.

read('Note') :-
    player(_, Location, _, Inventory),
    (   member('Note', Inventory)
    ;   object_at('Note', Location)
    ),
    write('The note reads: "The machines remember. Only the worthy may claim the sky."'), nl.
read('Note') :-
    write('You do not see a note here.'), nl.

% Player skill: negotiate (with Sky Pirate)
negotiate :-
    player(Name, Location, HP, Inventory),
    npc_at('Lost Sky Pirate', Location),
    ( member('Broken Gold Pistole', Inventory) ->
        select('Broken Gold Pistole', Inventory, NewInventory),
        retract(player(Name, Location, HP, Inventory)),
        asserta(player(Name, Location, HP, NewInventory)),
        write('You hand over the broken gold pistole. The Sky Pirate nods: "Alright, I\'ll help you out, but I\'m not risking my life!"'), nl,
        asserta(skypirate_help),
        write('The Sky Pirate is going to help you now in the battle!'), nl
    ; write('The Sky Pirate says: "You should look for some valuable goods. I heard there\'s something interesting in the broken tower."'), nl,
      write('Maybe you should analyze the Ruined Tower for hidden secrets.'), nl
    ).
negotiate :-
    write('There is no one here to negotiate with.'), nl.

% Fly command (only available after defeating the dragon)
fly(Destination) :-
    dragon_help,
    player(Name, Location, HP, Inventory),
    ( Location = Destination ->
        write('You are already at that location.'), nl
    ;   asserta(player(Name, Destination, HP, Inventory)),
        retract(player(Name, Location, HP, Inventory)),
        asserta(visited(Destination)),
        write('The dragon carries you swiftly to '), write(Destination), write('.'), nl,
        look
    ).
fly(_) :-
    write('You do not have the dragon\'s help yet.'), nl.

% Enraged Dragon skills
breathe_fire :-
    player(Name, Location, Health, Inventory),
    npc_at('Enraged Dragon', Location),
    NewHealth is Health - 40,
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, NewHealth, Inventory)),
    write('The dragon breathes fire! You are burned and lose 40 health.'), nl,
    check_health.

% Lost Sky Pirate skills
quickshot :-
    player(Name, Location, Health, Inventory),
    npc_at('Lost Sky Pirate', Location),
    NewHealth is Health - 20,
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, NewHealth, Inventory)),
    write('The Sky Pirate fires a quick shot! You lose 20 health.'), nl,
    check_health.

navigate :-
    player(_, Location, _, _),
    npc_at('Lost Sky Pirate', Location),
    write('The Sky Pirate shows you a hidden path through the ruins.'), nl.

% Movement commands
n :- move(north).
s :- move(south).
e :- move(east).
w :- move(west).

% Show map with ??? for unvisited locations
map :-
    write('--- MAP OF THE MACHINES OF THE SKY ---'), nl,
    show_location_masked('Crash Site'),
    show_location_masked('Ruined Tower'),
    show_location_masked('Sky Temple'),
    show_location_masked('Skyforge'),
    show_location_masked('Floating Docks'),
    show_location_masked('Ancient Workshop'),
    show_location_masked('Skyship Dock'),
    show_location_masked('Secret Chamber'),
    write('-------------------------------------'), nl.

show_location_masked(Location) :-
    (visited(Location) ->
        show_location(Location)
    ;
        write('[???]'), nl,
        % Show available paths, but mask destination names
        findall(Direction-Dest, direction(Location, Direction, Dest), Paths),
        show_masked_paths(Paths),
        nl
    ).

show_masked_paths([]).
show_masked_paths([Direction-_|Rest]) :-
    write('  Path: '), write(Direction), nl,
    show_masked_paths(Rest).

show_location(Location) :-
    write('['), write(Location), write(']'), nl,
    findall(NPC, npc_at(NPC, Location), NPCs),
    (NPCs \= [] -> (write('  NPCs: '), write(NPCs), nl) ; true),
    findall(Object, object_at(Object, Location), Objects),
    (Objects \= [] -> (write('  Objects: '), write(Objects), nl) ; true),
    findall(Direction-Dest, direction(Location, Direction, Dest), Paths),
    show_paths(Paths),
    nl.

show_paths([]).
show_paths([Direction-Dest|Rest]) :-
    (visited(Dest) ->
        write('  Path: '), write(Direction), write(': '), write(Dest), nl
    ;
        write('  Path: '), write(Direction), nl
    ),
    show_paths(Rest).

% HELP FUNCTION
help :-
    write('Available commands:'), nl,
    write('  start.         - Begin your adventure'), nl,
    write('  look.          - Look around your current location'), nl,
    write('  n. s. e. w.    - Move (north, south, east, west)'), nl,
    write('  take(Object).  - Pick up an object'), nl,
    write('  drop(Object).  - Drop an object'), nl,
    write('  inventory.     - Check your inventory'), nl,
    write('  interact(NPC). - interact an NPC'), nl,
    write('  repair.        - Attempt to fix ancient machinery'), nl,
    write('  trade.         - Trade with the Mysterious Merchant'), nl,
    write('  attack.        - Attack the Security Drone (requires Plasma Cutter)'), nl,
    write('  sneak.         - Try to sneak past an enemy'), nl,
    write('  analyze.       - Analyze technology or NPCs in the area'), nl,
    write('  negotiate.     - Negotiate with the Sky Pirate'), nl,
    write('  map.           - Show the locations'), nl,
    write('  help.          - Show this list of commands'), nl.

% Begin the adventure, ask for name, intro, etc.
start :-
    write('...'), nl,
    write('You wake up to the sound of crackling wires and distant thunder.'), nl,
    write('Your head aches. You remember falling...'), nl,
    write('But who are you?'), nl,
    write('What is your name? (Type your name in lowercase or in single quotes, e.g. yoshi. or \'Yo shi\'.) '),
    read(PlayerName),
    retractall(player(_,_,_,_)),
    asserta(player(PlayerName, 'Crash Site', 100, [])),
    retractall(main_quest(_)),
    asserta(main_quest('begin')),
    retractall(visited(_)),
    asserta(visited('Crash Site')),
    nl, write('Welcome, '), write(PlayerName), write('.'), nl,
    look.

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

% --- STORY PROGRESSION LOGIC ---

main_quest('begin'). % Initial state

progress_quest('begin') :-
    player(_, 'Ruined Tower', _, Inventory),
    member('Broken Gear', Inventory),
    member('Ancient Core', Inventory),
    retract(main_quest('begin')),
    asserta(main_quest('machine_awakened')),
    write('As you combine the Broken Gear and Ancient Core, the ancient machine awakens!'), nl,
    write('A hidden passage opens to the north...'), nl,
    asserta(direction('Ruined Tower', north, 'Secret Chamber')).

progress_quest('machine_awakened') :-
    player(_, 'Floating Docks', _, Inventory),
    member('Rare Alloy', Inventory),
    member('Dragon Scale', Inventory),
    retract(main_quest('machine_awakened')),
    asserta(main_quest('forge_ready')),
    write('You have both the Rare Alloy and Dragon Scale!'), nl,
    write('Seek the Skyforge and the Keeper to craft a legendary weapon.'), nl.

progress_quest('forge_ready') :-
    player(_, 'Skyforge', _, Inventory),
    member('Rare Alloy', Inventory),
    member('Dragon Scale', Inventory),
    retract(main_quest('forge_ready')),
    asserta(main_quest('blade_forged')),
    craft_weapon.

progress_quest('blade_forged') :-
    player(_, 'Skyship Dock', _, Inventory),
    member('Skyforge Blade', Inventory),
    member('Skyship Engine', Inventory),
    member('Ancient Core', Inventory),
    member('Energy Cell', Inventory),
    retract(main_quest('blade_forged')),
    asserta(main_quest('ready_to_escape')),
    write('You have everything needed to repair the skyship and escape!'), nl.

progress_quest('ready_to_escape') :-
    player(_, 'Skyship Dock', _, _),
    object_at('Repaired Skyship', 'Skyship Dock'),
    write('You board the repaired skyship. The machines of the island stir as you prepare to leave.'), nl,
    write('Congratulations! You have escaped the island and completed your adventure!'), nl,
    asserta(main_quest('completed')).

% Call this after key actions to check for quest progress
check_story_progress :-
    main_quest(State),
    progress_quest(State), !.
check_story_progress.

% Health and game over logic
check_health :-
    player(_, _, Health, _),
    Health =< 0,
    write('You collapse as your wounds overwhelm you. The sky grows dark...'), nl,
    write('GAME OVER.'), nl,
    asserta(game_over), !.
check_health.

% Quest status command
quest :-
    main_quest(State),
    write('Current main quest stage: '), write(State), nl.

% Optionally, add a win command for testing
win :- 
    main_quest('ready_to_escape'),
    write('You have completed the game! Congratulations!'), nl,
    retractall(game_over),
    asserta(game_over).