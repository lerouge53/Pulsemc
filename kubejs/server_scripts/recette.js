ServerEvents.recipes(event => {
    event.recipes.create.compacting('minecraft:diamond', 'kubejs:reiforced_carbon').superheated()
})

ServerEvents.recipes(event => {
    event.recipes.create.mixing('kubejs:reiforced_carbon', 'minecraft:coal_block').heated()
    event.recipes.create.mixing('minecraft:red_sand', ['minecraft:orange_dye', 'minecraft:sand'])
    event.recipes.create.mixing('kubejs:circuit_board_kit', ['#forge:wires/insulated_copper', 'minecraft:redstone'])
})

ServerEvents.recipes(event => {
    event.recipes.create.deploying('kubejs:incomplete_circuit_advanced',['electrodynamics:circuitbasic', 'minecraft:diamond'])
    event.recipes.create.deploying('kubejs:incomplete_circuit_elite',['electrodynamics:circuitadvanced', 'minecraft:lapis_block'])
    event.recipes.create.deploying('kubejs:incomplete_circuit_ultimate',['electrodynamics:circuitelite', '#forge:dusts/obsidian'])
    event.recipes.create.deploying('electrodynamics:circuitbasic', ['#forge:plates\steel', 'kubejs:circuit_board_kit'])
})

ServerEvents.recipes(event => {
    event.recipes.create.pressing('electrodynamics:circuitadvanced', 'kubejs:incomplete_circuit_advanced')
    event.recipes.create.pressing('electrodynamics:circuitelite', 'kubejs:incomplete_circuit_elite')
    event.recipes.create.pressing('electrodynamics:circuitultimate', 'kubejs:incomplete_circuit_ultimate')
})

ServerEvents.recipes(event => {
    event.recipes.create.crushing([Item.of('kubejs:crushed_granite').withChance(0.75), Item.of('minecraft:red_sand').withChance(0.5)], 'minecraft:granite')
})

ServerEvents.recipes(event => {
    event.recipes.create.splashing([Item.of('minecraft:iron_nugget', 9), Item.of('minecraft:zinc_nugget', 9)], 'kubejs:crushed_granite')
})
