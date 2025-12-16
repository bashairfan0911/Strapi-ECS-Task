'use strict';

/**
 * todo router
 */

const { createCoreRouter } = require('@strapi/strapi').factories;
//exporting
module.exports = createCoreRouter('api::todo.todo');
