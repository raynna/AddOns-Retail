# AllTheThings

## [4.0.9](https://github.com/DFortun81/AllTheThings/tree/4.0.9) (2024-08-28)
[Full Changelog](https://github.com/DFortun81/AllTheThings/compare/4.0.8...4.0.9) [Previous Releases](https://github.com/DFortun81/AllTheThings/releases)

- safety parse  
- Sweep reported errors  
- Reparsed classic  
- Retail: Parsed  
- Fixed ClassicCost wrapper  
- Coord for Scampering Weave-Rat  
    Weekly HQTs for Restored Coffer Key now have an automatic name (maybe we will move them from HQT so they are available in Dynamic groups -> weekly for easy reference)  
- Stormpike's Orders is a breadcrumb.  
- Fixed a missing /n.  
- REMOVED\_TWW\_PREPATCH\_END changed to REMOVED\_TWW\_LAUNCH (double negative is bit unclear)  
- bit more clear  
- special note to watcher huntpress pet  
- added steelpromo prices  
- added \n to descript  
- updated parrlok description  
- zone rewards description updated. nobody reads thats anyway  
- moved key thingy to world quests  
- wrapping up dragon riding rework & removing the sky racers purse from zone rewards (which was the entire reason i  did the rework)  
- Sort reported tailoring and jewelcrafting treasures  
- deleted expansion feature dragon racing  
- correcting fr spacing  
- dragon racing is no longer an expansion feature (and i didnt want to make a million "if" statement for dragonflight classic (lol) which likely has dragonriding baseline  
    WIP  
- Sort some incription treasures  
- Added a weekly knowledge for BS (TBD on sourcing the actual dropped Item...)  
- Clean some blacksmithing treasure items from unsorted  
- Merge pull request #1754 from Cagomei/Professions-Knowledge-items-pt2  
    Update Blacksmithing.lua  
- Sweep errors with rare drops, coords, missing quests and criteria  
- Updated parser config.  
    Looks like we are playing build 56311 despite 56313 should have been live since yesterday.  
- Dragonflight is over. Say goodbye to season 4 stuff.  
- - Added Honored Soldier's Chainmail to the loot tables for Khaz Algar/Azj-Kahet quests  
    - Removed Honored Soldier's Chainmail from the loot tables for Unsorted  
- Update Blacksmithing.lua  
- Retail: All DF S4 items can no longer be upgraded :sad:  
- Fixed some unnecessary faction assignment to AQD/HQD data groups which was causing Neutral quests with faction-based in-game data (coords,provider,etc.) to be re-assigned as the opposing faction when nested in search results. [This faction assignment is not necessary since all AQD/HQD now pertains to in-game data and not the association of the quest itself to a given faction since Classic ATT versons have removed the auto-combining of different questID's within a single quest object]  
- Delves HQTs.  
- Removed aqd/hqd from 84345 since sourceQuests don't need the distinction  
    Delve Curios marked with a note about how to collect in ATT  
- Add some FirstSkins, rare drops and correct coords and sourcequests  
- Migrate Class: Achievement et al. (#1745)  
    * Retail: Initial conversion of Achievement Lib to stand-alone Class  
    * Retail: Clean out commented code  
    * Fixes and performance improvements  
    Class Caches can now support DefaultFunctions directly instead of always requiring to pass in from the caller  
- Retail: Removed some 'cost' data being applied to Items which actually use Recipes to craft  
- Added TWW quest rewards.  
    Added one Stay awhile and listen.  
- Few more TWW items.  
    Stay awhile and listen corrections.  
- Sorting some TWW items.  
- WotLK Dalaran: Kirin Tor Familiar  
- Sort rare drops, fix source quest, edit note  
- Good nights.  
- Added a test function for Sort method comparisons  
- Parser: Fixed the \_wipe field not being merged into Items (i.e. Artisan's Mettle not wiping requireSkill contamination)  
- Don't show all of Vault of Memory as containing Dornogal content  
    Sourced Algari Scepter  
    Couple Stay awhile adjustments/additions  
- Retail: Fixed an issue with Object tooltips where unknown objects in ATT would show tooltips for known objects in different maps  
- Caesper fixed?  
- Moar BetTer  
- Update AllTheThings.lua  
    This should add World Quest support - worked for me.  
- Merge pull request #1752 from Cagomei/Professions-Knowledge-items  
    JC and Ins profession knowledge items  
- Retail: Adjusted Crafted Item filling within windows to additionally nest the Recipe which provides each Crafted Item when the popout itself has a Reagent or Recipe as the Root (top) of the popout. This should allow for easier understanding & visibility of what to do with a given Reagent without having to do external research (If people find this change really unnecessary in some regard, I can turn it into a toggle option)  
- JC and Ins profession knowledge items  
- Simplified app.ArrayAppend slightly  
- Retail: Revised synchronous FillGroup operation (e.g. tooltips and chat command search results) to perform in the same manner as the asynchronous variant (e.g. filling minilist/popouts) by changing the recursive approach (depth-first) to a layered-loop approach (breadth-first) in an attempt to have overall less-nested search results and tooltips  
- Sort some rare drops and uncomment a quest item  
- Retail: Missing Maps now use a report dialog with some possibly helpful info (instead of requiring the user to screenshot their chat or re-type the message)  
- Fixed quest report using | for unlock dividers (|W is a special character)  
    Made MostRecentQuestTurnIns an app table for external reference  
- Quest report dialog now includes 'WW\_CA' unlock indication for whether the account has completed The War Within campaign thus unlocking Adventure mode and changing quest accessibility for alt characters  
- Added misc items and few HQTs for Delves.  
- enUS shortening of names in tww  
- Update to build order of HAT and HQT.  
- Forgot to remove this.  
- Consolidated all TWW HQTs into the same format and grouped them all together. Timelined everything too.  
    Added all Contract HQTs in professions.  
- Sourced 'Algari Cinch'  
    Coord/breadcrumb for 'To Mourning Rise'  
- Fix errors with rares, quests and coords  
- Best commit message  
- Confirmed Ancient Construct from specific Sturdy Chest  
    Coord fix in Dornogal  
- Sourced 'Salamanther-Scale Greaves'  
    Delves HQT  
- Harvested BNet API Items/Quests  
- Fix Weaving Supplies coord and Tarnished Compass questid  
- Update Queen Xekatha coord for real this time  
- Fix coords for Smelling History  
- Add Hallowfall quest reward and fix some engineering spellids  
- Fixed Amorphous Relic spells (other relics still broken but idk)  
