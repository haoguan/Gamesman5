# Coffee
window.GCAPI or= {}

window.GCAPI.GameNotifier = class
  constructor: (@canvas, @conf) ->
    @showMoveValues = false
  drawBoard: (board, game) ->
    alert("GameNotifier must implement drawBoard")
  drawMoves: (data, game) ->
    alert("GameNotifier must implement drawMoves")
  setShowMoveValues: (@showMoveValues) ->

reduce = (num, denom) ->
  gcd = (a, b) ->
    return if b then gcd(b, a%b) else a
  d = gcd(num, denom)
  return [num / d, denom / d]

window.GCAPI.getAspectRatio = (p) ->
  dim = game.getDimensions(p)
  return reduce(dim[0], dim[1])

window.GCAPI.Game = class Game
  constructor: (name, parameters, notifierClass, board) ->
    @gameName = name
    @params = parameters
    @notifier = notifierClass
    @previousBoards = []
    @nextBoards = []
    @currentBoard = board
    @baseUrl = "http://nyc.cs.berkeley.edu:8080/gcweb/service/gamesman/puzzles/"

  setDrawProcedure: (draw) ->
    @draw = draw

  getUrlTail: (board) ->
    retval = ""
    for own k,v of @params
      retval += ";" + k + "=" + v
    retval += ";board=" + escape(board)
    return retval

  getBoardValues: (board, notifier) ->
    requestUrl = @baseUrl + @gameName + "/getMoveValue" + @getUrlTail(board)

    $.ajax requestUrl,
            dataType: "json",
            success: (data) ->
              notifier(data, @)

  getPossibleMoves: (board, notifier) ->
    requestUrl = @baseUrl + @gameName + "/getNextMoveValues" + @getUrlTail(board)
    me = @

    $.ajax requestUrl,
            dataType: "json"
            success: (data) ->
              retval = []
              if data.status == "ok"
                notifier(data.response, me)
              else
                notifier(data, me)

  undo: () ->
    if @previousBoards.length > 0
      @nextBoards.push(@currentBoard)
      @currentBoard = @previousBoards.pop()
      @updateBoard()

  redo: () ->
    if @nextBoards.length > 0
      @previousBoards.push(@currentBoard)
      @currentBoard = @nextBoards.pop()
      @updateBoard()

  startGame: () ->
    @updateBoard()

  makeMove: (move) ->
    @previousBoards.push(@currentBoard)
    @nextBoards = []
    @currentBoard = move.board
    @updateBoard()

  updateBoard: () ->
    @notifier.drawBoard(@currentBoard, @)
    @getPossibleMoves(@currentBoard, @notifier.drawMoves)

  getNotifier: () ->
    @notifier
