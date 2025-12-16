
'use strict';

/**
 * todo controller
 */

const { createCoreController } = require('@strapi/strapi').factories;
//exorting from here
module.exports = createCoreController('api::todo.todo');