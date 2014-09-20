'use strict'

###*
 # @ngdoc service
 # @name blicblockApp.tetromino
 # @description
 # # tetromino
 # Service in the blicblockApp.
###
angular.module('blicblockApp')
  .service 'Tetromino', ['$rootScope', ($rootScope) ->
    class Tetromino
      constructor: ->
        @blocks = []
        @info =
          cols: 5
          rows: 7
          score_value: 1000

      check_for_tetrominos: ->
        for block in @blocks
          @check_for_straight_tetromino block
          @check_for_l_tetromino block

      remove_blocks: (to_remove) ->
        ids_to_remove = to_remove.map((b) -> b.id)
        idx = @blocks.length - 1
        while idx >= 0
          if ids_to_remove.indexOf(@blocks[idx].id) > -1
            @blocks.splice(idx, 1)
          idx--
        $rootScope.$broadcast 'increment_score', {amount: @info.score_value}
        @check_for_tetrominos()

      lookup: (x, y, color) ->
        @blocks.filter((b) -> b.x == x && b.y == y && b.color == color)[0]

      # ****
      check_for_straight_hor_tetromino: (start_block) ->
        y = start_block.y
        return if y >= @info.cols - 3
        x = start_block.x
        color = start_block.color
        block2 = @lookup(x, y + 1, color)
        return unless block2
        block3 = @lookup(x, y + 2, color)
        return unless block3
        block4 = @lookup(x, y + 3, color)
        return unless block4
        @remove_blocks [start_block, block2, block3, block4]

      # *
      # *
      # *
      # *
      check_for_straight_ver_tetromino: (start_block) ->
        x = start_block.x
        return if x >= @info.rows - 3
        y = start_block.y
        color = start_block.color
        block2 = @lookup(x + 1, y, color)
        return unless block2
        block3 = @lookup(x + 2, y, color)
        return unless block3
        block4 = @lookup(x + 3, y, color)
        return unless block4
        @remove_blocks [start_block, block2, block3, block4]

      check_for_straight_tetromino: (start_block) ->
        @check_for_straight_hor_tetromino start_block
        @check_for_straight_ver_tetromino start_block

      #  *       **
      #  *  *    *   ***
      # **  ***  *     *
      check_for_left_l_tetromino: (start_block) ->

      # *        **
      # *     *   *  ***
      # **  ***   *  *
      check_for_right_l_tetromino: (start_block) ->

      check_for_l_tetromino: (start_block) ->
        @check_for_left_l_tetromino start_block
        @check_for_right_l_tetromino start_block

    new Tetromino()
  ]
