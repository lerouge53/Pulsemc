ServerEvents.recipes(event => {
    // Étape 1 : 40 cycles de compression pour transformer la pierre en partially_compressed_stone
    event.recipes.create.sequenced_assembly(
        'kubejs:partially_compressed_stone', // Output : partially_compressed_stone
        'minecraft:stone',                   // Input : Pierre
        [
            event.recipes.create.pressing('kubejs:compressed_stone', 'kubejs:compressed_stone')
        ]
    ).transitionalItem('kubejs:compressed_stone')
     .loops(40); // 40 cycles de compression

    // Étape 2 : Ajouter du gravier avec un déployeur pour obtenir un lingot de fer
    event.recipes.create.deploying(
        'minecraft:iron_ingot',              // Output : 1 lingot de fer
        ['kubejs:partially_compressed_stone', 'minecraft:gravel'] // Input : partially_compressed_stone + gravier
    );
});
