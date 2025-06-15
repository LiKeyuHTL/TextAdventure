% filepath: c:\HTL\POSE_Theorie\TextAdventure\Engine.pl
:- dynamic(player/4).
:- dynamic(object_at/2).
:- dynamic(npc_at/2).
:- dynamic(game_over/0).
:- dynamic(visited/1).
:- dynamic(direction/3).
:- dynamic(in_battle/4).
:- dynamic(burned/0).
:- dynamic(dragon_burn_used/0).
:- dynamic(drone_repaired/0).
:- dynamic(skypirate_help/0).

% Show welcome and help at load
:- initialization(main).
main :-
    write('Welcome to The Machines of the Sky!'), nl,
    write('Type start. to begin your adventure.'), nl,
    help.

% Object locations
object_at('Broken Gear', 'Crash Site').
object_at('Ancient Core', 'Ruined Tower').
object_at('Energy Cell', 'Ruined Tower').
object_at('Plasma Cutter', 'Secret Chamber').
object_at('Broken Gold Pistole', 'Secret Chamber').
object_at('Mysterious Metal', 'Secret Chamber').
object_at('Rare Alloy', 'Floating Docks').
object_at('Dragon Scale', 'Sky Temple').
object_at('Skyship Engine', 'Skyship Dock').

% NPC locations
npc_at('Ancient Console', 'Ruined Tower').
npc_at('Enraged Dragon', 'Sky Temple').
npc_at('Lost Sky Pirate', 'Floating Docks').
npc_at('Mysterious Merchant', 'Merchant House').
npc_at('Security Drone', 'Skyship Dock').

% Locations and paths
direction('Crash Site', east, 'Ruined Tower').
direction('Ruined Tower', north, 'Sky Temple').
direction('Ruined Tower', south, 'Floating Docks').
direction('Ruined Tower', west, 'Crash Site').
direction('Floating Docks', north, 'Ruined Tower').
direction('Floating Docks', east, 'Merchant House').
direction('Floating Docks', south, 'Skyship Dock').
direction('Merchant House', west, 'Floating Docks').
direction('Sky Temple', south, 'Ruined Tower').
direction('Skyship Dock', north, 'Floating Docks').

% Move the player
move(Direction) :-
    player(Name, Location, Health, Inventory),
    direction(Location, Direction, NewLocation),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, NewLocation, Health, Inventory)),
    (visited(NewLocation) -> true ; asserta(visited(NewLocation))),
    ( NewLocation = 'Skyship Dock',
      npc_at('Security Drone', 'Skyship Dock'),
      \+ in_battle('Security Drone', _, _, _)
    ->
        enemy_stats('Security Drone', EnemyMaxHP, EnemyAttack),
        retractall(in_battle(_,_,_,_)),
        asserta(in_battle('Security Drone', EnemyMaxHP, EnemyMaxHP, EnemyAttack)),
        write('The Security Drone detects you as you arrive and attacks!'), nl,
        show_battle_status('Security Drone', EnemyMaxHP, EnemyMaxHP, EnemyAttack)
    ;
        look
    ).

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
    write('You picked up: '), write(Object), nl.

take :-
    player(Name, Location, Health, Inventory),
    findall(Object, object_at(Object, Location), Objects),
    ( Objects = [] ->
        write('There is nothing to take here.'), nl
    ;
        take_all_objects(Objects, Name, Location, Health, Inventory)
    ).

take_all_objects([], Name, Location, Health, Inventory) :-
    retract(player(Name, Location, Health, _)),
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

nteract('Lost Sky Pirate') :-
    player(Name, Location, HP, Inventory),
    ( member('Broken Gold Pistole', Inventory), member('Mysterious Metal', Inventory) ->
        select('Broken Gold Pistole', Inventory, TempInventory),
        select('Mysterious Metal', TempInventory, NewInventory),
        retract(player(Name, Location, HP, Inventory)),
        asserta(player(Name, Location, HP, NewInventory)),
        write('The Sky Pirate grins: "I\'ll take that broken gold pistole and this mysterious metal. I\'ll help you as promised, but don\'t expect me to risk my own neck in a fight!"'), nl,
        asserta(skypirate_help),
        retract(npc_at('Lost Sky Pirate', Location)),
        write('The Sky Pirate is going to help you now in the battle!'), nl
    ; write('The Sky Pirate grins: "You should look for some valuable goods. I heard there\'s something interesting in the broken tower."'), nl,
      write('Maybe you should analyze the Ruined Tower for hidden secrets.'), nl
    ).

interact('Mysterious Merchant') :-
    player(Name, Location, HP, Inventory),
    ( member('Mysterious Metal', Inventory) ->
        select('Mysterious Metal', Inventory, NewInventory),
        retract(player(Name, Location, HP, Inventory)),
        asserta(player(Name, Location, HP, ['Magicsteel Armour'|NewInventory])),
        write('The Mysterious Merchant takes your Mysterious Metal and hands you a shimmering Magicsteel Armour!'), nl,
        write('You feel protected. (You will take 20 less damage from attacks.)'), nl
    ; member('Plasma Cutter', Inventory) ->
        write('The Mysterious Merchant says: "That Plasma Cutter looks worn. You could repair and upgrade it with a Rare Alloy, a Broken Gear, and an Ancient Core."'), nl,
        write('Hint: Use the command repair. after you have collected all three parts.'), nl
    ; write('The Mysterious Merchant says: "Bring me something rare and I might have something special for you."'), nl
    ).

interact('Security Drone') :-
    write('The Security Drone beeps: "Unauthorized access detected. Initiating defense protocol."'), nl,
    player(_, Location, _, _),
    npc_at('Security Drone', Location),
    enemy_stats('Security Drone', EnemyMaxHP, EnemyAttack),
    retractall(in_battle(_,_,_,_)),
    asserta(in_battle('Security Drone', EnemyMaxHP, EnemyMaxHP, EnemyAttack)),
    write('The Security Drone flashes red and attacks you!'), nl,
    show_battle_status('Security Drone', EnemyMaxHP, EnemyMaxHP, EnemyAttack).

% Player abilities
repair :-
    player(Name, Location, Health, Inventory),
    Location = 'Skyship Dock',
    member('Skyship Engine', Inventory),
    member('Ancient Core', Inventory),
    member('Energy Cell', Inventory),
    select('Skyship Engine', Inventory, Temp1),
    select('Ancient Core', Temp1, Temp2),
    select('Energy Cell', Temp2, NewInventory),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, Health, NewInventory)),
    write('You install the Skyship Engine, Ancient Core, and Energy Cell into the skyship.'), nl,
    write('The engines roar to life and the ship lifts off!'), nl,
    write('Congratulations! You have repaired the skyship and escaped the island!'), nl,
    asserta(game_over), !.

repair :-
    player(Name, Location, Health, Inventory),
    Location = 'Skyship Dock',
    write('You do not have all the parts needed to repair the skyship.'), nl, !.

repair :-
    player(Name, Location, Health, Inventory),
    member('Plasma Cutter', Inventory),
    member('Rare Alloy', Inventory),
    member('Broken Gear', Inventory),
    select('Plasma Cutter', Inventory, Temp1),
    select('Rare Alloy', Temp1, Temp2),
    select('Broken Gear', Temp2, NewInventory),
    retract(player(Name, Location, Health, Inventory)),
    asserta(player(Name, Location, Health, ['Plasma Cutter+'|NewInventory])),
    write('You combine the Energy Cell and Broken Gear with your Plasma Cutter.'), nl,
    write('It transforms into a powerful Plasma Cutter+!'), nl, !.

repair :-
    write('You don\'t have the right parts to upgrade your Plasma Cutter or repair anything here.'), nl.

% Start a battle if an enemy is present and not already in battle
attack :-
    in_battle(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack), !,
    continue_battle(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack).
attack :-
    player(_, Location, _, _),
    npc_at('Enraged Dragon', Location),
    enemy_stats('Enraged Dragon', EnemyMaxHP, EnemyAttack),
    retractall(in_battle(_,_,_,_)),
    retractall(dragon_burn_used),
    DragonStartHP is EnemyMaxHP - 20,
    asserta(in_battle('Enraged Dragon', DragonStartHP, EnemyMaxHP, EnemyAttack)),
    write('You catch the Enraged Dragon off guard! It starts the battle with 20 less HP.'), nl,
    show_battle_status('Enraged Dragon', DragonStartHP, EnemyMaxHP, EnemyAttack).
attack :-
    player(_, Location, _, _),
    npc_at('Security Drone', Location),
    enemy_stats('Security Drone', EnemyMaxHP, EnemyAttack),
    retractall(in_battle(_,_,_,_)),
    retractall(drone_repaired),
    asserta(in_battle('Security Drone', EnemyMaxHP, EnemyMaxHP, EnemyAttack)),
    write('A wild Security Drone appears!'), nl,
    show_battle_status('Security Drone', EnemyMaxHP, EnemyMaxHP, EnemyAttack).
attack :-
    player(_, Location, _, _),
    npc_at(Enemy, Location),
    enemy_stats(Enemy, EnemyMaxHP, EnemyAttack),
    retractall(in_battle(_,_,_,_)),
    (Enemy = 'Enraged Dragon' -> retractall(dragon_burn_used) ; true),
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
    write('Type attack. to attack!'), nl.

% Continue the battle phase after player enters attack.
continue_battle(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack) :-
    player(PlayerName, PlayerLoc, PlayerHP, Inventory),
    player_attack(Inventory, Damage),
    ( skypirate_help ->
        TotalDamage is Damage + 20,
        write('You attack '), write(Enemy), write(' for '), write(Damage), write(' damage!'), nl,
        write('The Sky Pirate helps and deals 20 extra damage!'), nl
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
            ( skypirate_help, npc_at('Lost Sky Pirate', PlayerLoc) ->
                retract(npc_at('Lost Sky Pirate', PlayerLoc))
            ; true ),
            retractall(in_battle(_,_,_,_)),
            retract(player(PlayerName, PlayerLoc, PlayerHP, Inventory)),
            asserta(player(PlayerName, PlayerLoc, 100, Inventory)),
            write('You heal yourself after the battle. Your HP is restored to 100.'), nl
        ; enemy_turn(Enemy, FinalEnemyHP, EnemyMaxHP, EnemyAttack)
        )
    ; enemy_turn(Enemy, NewEnemyHP, EnemyMaxHP, EnemyAttack)
    ).

% Player attack damage (stronger if Plasma Cutter+)
player_attack(Inventory, 60) :- member('Plasma Cutter+', Inventory), !.
player_attack(Inventory, 40) :- member('Plasma Cutter', Inventory), !.
player_attack(_, 30).

% Enemy turn, then show updated life bars and wait for next attack
enemy_turn(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack) :-
    player(PlayerName, PlayerLoc, PlayerHP, Inventory),
    ( Enemy = 'Enraged Dragon', \+ dragon_burn_used ->
        write('The Enraged Dragon breathes fire! You are burned and will take extra damage next round.'), nl,
        asserta(burned),
        asserta(dragon_burn_used)
    ; true ),
    ( Enemy = 'Security Drone', EnemyHP < 70, \+ drone_repaired ->
        NewEnemyHP is min(EnemyHP + 50, EnemyMaxHP),
        asserta(drone_repaired),
        write('The Security Drone activates its self-repair protocol and restores 50 HP!'), nl,
        enemy_turn(Enemy, NewEnemyHP, EnemyMaxHP, EnemyAttack)
    ; 
        ( member('Magicsteel Armour', Inventory) ->
            ReducedAttack is max(0, EnemyAttack - 20)
        ;   ReducedAttack = EnemyAttack
        ),
        ( burned ->
            TotalAttack is ReducedAttack + 5,
            retract(burned),
            write('You suffer 5 extra burn damage!'), nl
        ;   TotalAttack = ReducedAttack
        ),
        write(Enemy), write(' attacks you for '), write(TotalAttack), write(' damage!'), nl,
        NewPlayerHP is PlayerHP - TotalAttack,
        retract(player(PlayerName, PlayerLoc, PlayerHP, Inventory)),
        ( NewPlayerHP =< 0 ->
            asserta(player(PlayerName, PlayerLoc, 1, Inventory)),
            retractall(in_battle(_,_,_,_)),
            retractall(dragon_burn_used),
            retractall(drone_repaired),
            write('You have been defeated by '), write(Enemy), write('!'), nl,
            write('But you miraculously escape from death and flee the battle!'), nl,
            write('You barely survive, but the battle is over as if it never happened.'), nl
        ;
            asserta(player(PlayerName, PlayerLoc, NewPlayerHP, Inventory)),
            retractall(in_battle(_,_,_,_)),
            asserta(in_battle(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack)),
            ( skypirate_help ->
                write('The Sky Pirate uses his skill and shoots the enemy for 10 extra damage after the attack!'), nl,
                NewEnemyHP2 is EnemyHP - 10,
                ( NewEnemyHP2 =< 0 ->
                    write('You defeated '), write(Enemy), write('!'), nl,
                    ( Enemy = 'Enraged Dragon' ->
                        asserta(dragon_help),
                        write('The dragon bows its head: "You have proven your strength. I will help you reach your destinations quicker."'), nl,
                        write('Hint: You can now use fly(\'Location\'). to travel instantly to any main location!'), nl
                    ; true ),
                    retract(npc_at(Enemy, PlayerLoc)),
                    retractall(in_battle(_,_,_,_)),
                    retract(player(PlayerName, PlayerLoc, 100, Inventory)),
                    asserta(player(PlayerName, PlayerLoc, 100, Inventory)),
                    write('You heal yourself after the battle. Your HP is restored to 100.'), nl
                ; 
                    retractall(in_battle(_,_,_,_)),
                    asserta(in_battle(Enemy, NewEnemyHP2, EnemyMaxHP, EnemyAttack)),
                    show_battle_status(Enemy, NewEnemyHP2, EnemyMaxHP, EnemyAttack)
                )
            ; 
                show_battle_status(Enemy, EnemyHP, EnemyMaxHP, EnemyAttack)
            )
        )
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
analyze :-
    player(_, Location, _, _),
    Location = 'Skyship Dock',
    write('You examine the damaged skyship.'), nl,
    write('To repair it, you will need:'), nl,
    write('  - Skyship Engine'), nl,
    write('  - Ancient Core'), nl,
    write('  - Energy Cell'), nl,
    write('Hint: Collect all these parts and use the command repair. at the Skyship Dock to escape!'), nl, !.

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
        retract(npc_at('Lost Sky Pirate', Location)),
        write('The Sky Pirate is going to help you now in the battle!'), nl
    ; write('The Sky Pirate says: "You should look for some valuable goods. I heard there\'s something interesting in the broken tower."'), nl,
      write('Hint: Use analyze. in the ruined tower.'), nl
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
    show_location_masked('Secret Chamber'),
    show_location_masked('Sky Temple'),
    show_location_masked('Floating Docks'),
    show_location_masked('Merchant House'),
    show_location_masked('Skyship Dock'),
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
    write('  inventory.     - Check your inventory'), nl,
    write('  interact(NPC). - interact an NPC'), nl,
    write('  repair.        - Attempt to fix ancient machinery'), nl,
    write('  attack.        - Attack the Security Drone (requires Plasma Cutter)'), nl,
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
    retractall(visited(_)),
    asserta(visited('Crash Site')),
    nl, write('Welcome, '), write(PlayerName), write('.'), nl,
    look.