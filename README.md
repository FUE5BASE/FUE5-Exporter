![FUE5](https://user-images.githubusercontent.com/127543827/235319284-d7505107-d0af-4275-a5be-f65301345823.jpg)

# FUE5 Exporter
Factorio mod relevant for [FUE5](https://github.com/FUE5BASE/FUE5). Adds shortcut to the game which puts selection tool to your cursor. 

## Selection tool
Selection tool has two modes:
 1) Main mode (selecting with no modifier keys) exports selected buildings to JSON.
 2) Alt mode (selection with Shift key) is used for debugging. It doesn't export selected buildings to JSON but prints bunch of stuff useful for quick debugging.

## Caveats

### Exporting trains
In order to export a train it has to be in the selection and in automatic mode. The mod will search for intersection of train path and selected area. It then exports first segment of that intersection for each train.

### Exporting items on belts
Items found on belts in selected area will be rendered inside FUE5. But that also means that if there are no items on the belts there will be no items on belts in FUE5.

[List of supported items](https://github.com/FUE5BASE/FUE5/tree/main/Content/MyStuff/ENTITIES/ITEMS)

## Output location
Selected area will be exported to JSON file `exported-entities.json` located in `script-output` directory of the game. Usually in `%APPDATA%/Factorio/script-output`

The exported JSON file should be put into `/Content/MyStuff/JSON` folder in the FUE5 to automatically load it.
