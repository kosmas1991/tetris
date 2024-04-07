import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:tetris/models/piece.dart';
import 'package:tetris/screens/register_screen.dart';
import 'package:tetris/variables/vars.dart' as table_var;
import 'package:vibration/vibration.dart';

class GameScreen extends StatefulWidget {
  final bool isOnline;
  final bool iAmHost;
  final String couchID;
  const GameScreen(
      {super.key,
      required this.isOnline,
      required this.iAmHost,
      required this.couchID});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class RotateIntent extends Intent {}

class ArrowLeftIntent extends Intent {}

class ArrowRightIntent extends Intent {}

class ArrowDownIntent extends Intent {}

List<List<int>> opponentTable = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
];

class _GameScreenState extends State<GameScreen> {
  //bool fromSpeedSet = false;
  Map<String, dynamic> couchData = {};

  FirebaseFirestore fire = FirebaseFirestore.instance;
  int punishExcept = 0;
  int punish = 0;
  int slowSpeed = 800;
  int fastSpeed = 80;
  Timer ktimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {});
  int counter = 0;
  bool moveRightPressedcont = false;
  bool moveLeftPressedcont = false;
  bool end = false;
  bool resetPressed = false;
  bool speedUp = false;
  Random rand = Random();
  Piece nextPieceToPlay = Omikron;
  Column daUI = Column();
  Column daUISmall = Column();
  Column nextPiece = Column();
  var table = table_var.table;
  var table2 = table_var.table;
  //dummy data
  var tableNextPiece = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0]
  ];
  Piece currentPiece = Omikron;
  Rotation pieceRotation = Rotation.base;
  List<List<int>> currentPiecePosition = [
    [0, 0],
    [0, 0],
    [0, 0],
    [0, 0],
  ];
  int secondChance = 0;

  @override
  Widget build(BuildContext context) {
    switch (nextPieceToPlay.name) {
      case 'Omikron':
        tableNextPiece = [
          [0, 1, 1, 0],
          [0, 1, 1, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0]
        ];
      case 'Giota':
        tableNextPiece = [
          [1, 1, 1, 1],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0]
        ];
      case 'Lamda':
        tableNextPiece = [
          [0, 1, 0, 0],
          [0, 1, 0, 0],
          [0, 1, 1, 0],
          [0, 0, 0, 0]
        ];
      case 'Jey':
        tableNextPiece = [
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 1, 1, 0],
          [0, 0, 0, 0]
        ];
      case 'Sigma':
        tableNextPiece = [
          [0, 1, 1, 0],
          [1, 1, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0]
        ];
      case 'Zetta':
        tableNextPiece = [
          [0, 1, 1, 0],
          [0, 0, 1, 1],
          [0, 0, 0, 0],
          [0, 0, 0, 0]
        ];
      case 'Taf':
        tableNextPiece = [
          [0, 1, 0, 0],
          [1, 1, 1, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0]
        ];
    }
    setState(() {
      daUI = buildTable(table, size: 20, padding: 1, radius: 5);
      nextPiece = buildTable4multi4(tableNextPiece);
    });
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/tetris.jpg',
              fit: BoxFit.fitHeight,
              height: double.infinity,
              width: double.infinity,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 228, 100, 143),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          border: Border.all(color: Colors.black, width: 7),
                        ),
                        child: daUI,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black38,
                            ),
                            height: 90,
                            width: 90,
                            child: Column(
                              children: [
                                Text(
                                  'NEXT',
                                  style: TextStyle(
                                      color: Colors.yellow, fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    nextPiece,
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          widget.isOnline
                              ? Container()
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black38,
                                  ),
                                  child: IconButton(
                                      onPressed: () {
                                        punish = punish + 1;
                                      },
                                      icon: Text(
                                        '+1',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      )),
                                ),
                          widget.isOnline
                              ? Container()
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black38,
                                  ),
                                  child: IconButton(
                                      onPressed: () {
                                        punish = punish + 2;
                                      },
                                      icon: Text(
                                        '+2',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      )),
                                ),
                          widget.isOnline
                              ? Container()
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black38,
                                  ),
                                  child: IconButton(
                                      onPressed: () {
                                        punish = punish + 3;
                                      },
                                      icon: Text(
                                        '+3',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      )),
                                ),
                          widget.isOnline
                              ? Container()
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black38,
                                  ),
                                  child: IconButton(
                                      onPressed: () {
                                        punish = punish + 4;
                                      },
                                      icon: Text(
                                        '+4',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      )),
                                ),
                          widget.isOnline ? daUISmall : Container()
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  widget.isOnline
                      ? Container()
                      : Shortcuts(
                          shortcuts: {
                            LogicalKeySet(LogicalKeyboardKey.keyR):
                                RotateIntent(),
                            LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                                ArrowLeftIntent(),
                            LogicalKeySet(LogicalKeyboardKey.arrowRight):
                                ArrowRightIntent(),
                            LogicalKeySet(LogicalKeyboardKey.arrowDown):
                                ArrowDownIntent(),
                          },
                          child: Actions(
                            actions: {
                              RotateIntent: CallbackAction<RotateIntent>(
                                onInvoke: (intent) {
                                  return rotatePiece();
                                },
                              ),
                              ArrowLeftIntent: CallbackAction<ArrowLeftIntent>(
                                onInvoke: (intent) {
                                  return movePieceLeft();
                                },
                              ),
                              ArrowRightIntent:
                                  CallbackAction<ArrowRightIntent>(
                                onInvoke: (intent) {
                                  return movePieceRight();
                                },
                              ),
                              ArrowDownIntent: CallbackAction<ArrowDownIntent>(
                                  onInvoke: (intent) {
                                return forcedOneDown();
                              })
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    style: ButtonStyle(
                                        side: MaterialStateProperty.all(
                                            BorderSide(width: 5)),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.yellow)),
                                    onPressed: () {
                                      start();
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'Start',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Icon(Icons.play_arrow)
                                      ],
                                    )),
                                TextButton(
                                    onPressed: () {
                                      resetPressed = true;
                                      end ? reset() : null;
                                    },
                                    child: Text(
                                      'Reset',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 117, 41, 36)),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      // needs fix
                                      reset();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Back to Lobby',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 117, 41, 36)),
                                    )),
                              ],
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Listener(
                        onPointerDown: (event) {
                          moveLeftPressedcont = true;
                          Timer.periodic(Duration(milliseconds: 150), (timer) {
                            if (!moveLeftPressedcont) {
                              timer.cancel();
                              return;
                            }
                            timer.tick > 2 ? movePieceLeft() : null;
                          });
                        },
                        onPointerUp: (event) {
                          moveLeftPressedcont = false;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 5),
                            borderRadius: BorderRadius.circular(1000),
                            color: Colors.yellow,
                          ),
                          child: IconButton(
                            onPressed: () {
                              !moveLeftPressedcont ? movePieceLeft() : null;
                            },
                            icon: Icon(Icons.chevron_left_sharp),
                            iconSize: 50,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Listener(
                        onPointerDown: (event) {
                          moveRightPressedcont = true;
                          Timer.periodic(Duration(milliseconds: 150), (timer) {
                            if (!moveRightPressedcont) {
                              timer.cancel();
                              return;
                            }
                            timer.tick > 2 ? movePieceRight() : null;
                          });
                        },
                        onPointerUp: (event) {
                          moveRightPressedcont = false;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 5),
                              borderRadius: BorderRadius.circular(1000),
                              color: Colors.yellow),
                          child: IconButton(
                            onPressed: () {
                              !moveRightPressedcont ? movePieceRight() : null;
                            },
                            icon: Icon(Icons.chevron_right_sharp),
                            iconSize: 50,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Listener(
                        //speedUp
                        onPointerDown: (event) {
                          speedUp = true;
                          Timer(Duration(milliseconds: 300), () {
                            setSpeed();
                          });
                        },
                        //speedDown
                        onPointerUp: (event) {
                          speedUp = false;
                          Timer(Duration(milliseconds: 300), () {
                            setSpeed();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 5),
                              borderRadius: BorderRadius.circular(1000),
                              color: Colors.yellow),
                          child: IconButton(
                              onPressed: () {
                                forcedOneDown();
                              },
                              icon: Icon(
                                Icons.keyboard_double_arrow_down,
                                size: 50,
                              )),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 5),
                            borderRadius: BorderRadius.circular(1000),
                            color: Colors.yellow),
                        child: IconButton(
                            onPressed: rotatePiece,
                            icon: Icon(
                              Icons.rotate_90_degrees_ccw,
                              size: 50,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<List<int>> retriveOpponentTable(Map<String, dynamic> data) {
    List<List<int>> opTable = [];
    List<int> listOfInts = widget.iAmHost
        ? data['guestTable'].cast<int>()
        : data['hostTable'].cast<int>();
    List<int> row = [];
    int counter = 0;
    for (int i in listOfInts) {
      row.add(i);
      counter++;
      if (counter % 10 == 0) {
        opTable.add(row);
        row = [];
      }
    }
    //printError(opTable.toString());
    return opTable;
  }

  @override
  void initState() {
    nextPieceToPlay = allThePieces[rand.nextInt(7)];
    //auto start
    widget.isOnline ? start() : null;
    //
    // Tables DATA LiSTENER

    widget.isOnline
        ? {
            widget.iAmHost
                ? fire
                    .collection('couches')
                    .doc(widget.couchID)
                    .collection('smallTables')
                    .doc('guestTable')
                    .snapshots()
                    .listen((event) {
                    couchData = event.data()!;
                    //printError('couchData is type ${couchData.runtimeType}');

                    opponentTable = retriveOpponentTable(couchData);
                  })
                : fire
                    .collection('couches')
                    .doc(widget.couchID)
                    .collection('smallTables')
                    .doc('hostTable')
                    .snapshots()
                    .listen((event) {
                    couchData = event.data()!;
                    //printError('couchData is type ${couchData.runtimeType}');

                    opponentTable = retriveOpponentTable(couchData);
                  })
          }
        : null;
    //dump Data, to be deleted
    //daUISmall = buildTable(table, size: 8, padding: 0, radius: 0);
    super.initState();
  }

  List<int> tableTo1DList(List<List<int>> table) {
    List<int> list = [];
    for (int i = 0; i < 20; i++) {
      for (int y = 0; y < 10; y++) {
        list.add(table[i][y]);
      }
    }

    return list;
  }

  void refresh() {
    setState(() {
      daUI = buildTable(table, size: 20, padding: 1, radius: 5);
      daUISmall = buildTable(opponentTable, size: 8, padding: 0, radius: 0);
    });
  }

  void reset() {
    ktimer.cancel();
    for (int line = 0; line < 20; line++) {
      for (int number = 0; number < 10; number++) {
        table[line][number] = 0;
      }
    }
    refresh();
    resetPressed = false;
    end = false;
    start();
  }

  void start() {
    punishExcept = rand.nextInt(10);
    gameLoop();
    updateSmallTablesEveryxSeconds(1);
  }

  void updateSmallTablesEveryxSeconds(int secs) {
    //            UPDATE THE SMALL TABLE every x seconds
    Timer.periodic(Duration(seconds: secs), (timer) {
      printError(timer.tick.toString());

      widget.iAmHost
          ? fire
              .collection('couches')
              .doc(widget.couchID)
              .collection('smallTables')
              .doc('hostTable')
              .set(
              {'hostTable': tableTo1DList(table)},
            )
          : fire
              .collection('couches')
              .doc(widget.couchID)
              .collection('smallTables')
              .doc('guestTable')
              .set(
              {'guestTable': tableTo1DList(table)},
            );
    });
    //          QDONE
  }

  void fetchMyPunishment() async {
    widget.isOnline
        ? await fire.collection('couches').doc(widget.couchID).get().then(
            (value) async {
              widget.iAmHost
                  ? punish = value.data()!['punishHost']
                  : punish = value.data()!['punishGuest'];
              printError('punish +100 ->  ${punish + 100}');
              //punishWith(punish);
              //punish = 0;
              widget.iAmHost
                  ? await fire
                      .collection('couches')
                      .doc(widget.couchID)
                      .update({'punishHost': 0})
                  : await fire
                      .collection('couches')
                      .doc(widget.couchID)
                      .update({'punishGuest': 0});
              // pieceRotation = Rotation.base;
              // currentPiece = nextPieceToPlay;

              // nextPieceToPlay = allThePieces[rand.nextInt(7)];

              // currentPiecePosition = [
              //   currentPiece.part1,
              //   currentPiece.part2,
              //   currentPiece.part3,
              //   currentPiece.part4
              // ];
              // addToTable(currentPiecePosition);
            },
          )
        : null;
  }

  void punishWith(int punish) {
    for (int i = 0; i < punish; i++) {
      for (int m = 0; m < 19; m++) {
        for (int n = 0; n < 10; n++) {
          table[m][n] = table[m + 1][n];
        }
        if (m == 18) {
          for (int n = 0; n < 10; n++) {
            table[m + 1][n] = 0;
          }
        }
        for (int n = 0; n < 10; n++) {
          if (n != punishExcept) {
            table[m + 1][n] = 1;
          }
        }
      }
    }
  }

  void forcedOneDown() {
    if (end) {
      return;
    }
    Vibration.vibrate(duration: 10);
    ktimer.cancel();

    bool failed = downOneRow();
    if (failed && counter == 1) {
      end = true;
    }

    if (failed) {
      !end ? gameLoop() : {endScreen(), Vibration.vibrate(duration: 500)};
      ;
    }
    ++counter;
    refresh();
    gameLoop(fromForcedOneDOwn: true);
  }

  void setSpeed() {
    ktimer.cancel();
    gameLoop(fromSpeedSet: true);
  }

  void gameLoop({bool fromForcedOneDOwn = false, bool fromSpeedSet = false}) {
    if (end) {
      return;
    }
    if (!fromForcedOneDOwn && !fromSpeedSet) {
      counter = 0;
      checkForTetris();
      setCurrentPiece();
      refresh();
    }

    void setTimer(int millisecs, int counterFun) {
      counter = counterFun;
      ktimer = Timer.periodic(Duration(milliseconds: millisecs), (timer) async {
        // if (millisecs == fastSpeed && speedUp == false) {
        //   timer.cancel();
        //   setTimer(slowSpeed, counter);
        //   return;
        // }
        // if (millisecs == slowSpeed && speedUp == true) {
        //   timer.cancel();

        //   setTimer(fastSpeed, counter);
        //   return;
        // }

        //          not sure where to put it
        ++counter;
        // if reset is pressed
        if (resetPressed) {
          timer.cancel();
          reset();
        }
        // exe downOneRow
        bool failed = downOneRow();
        if (failed && counter == 1) {
          timer.cancel();
          end = true;
          widget.iAmHost
              ? await fire
                  .collection('couches')
                  .doc(widget.couchID)
                  .update({'endGuestWon': true})
              : await fire
                  .collection('couches')
                  .doc(widget.couchID)
                  .update({'endHostWon': true});
        }

        if (failed) {
          timer.cancel();
          !end ? gameLoop() : {endScreen(), Vibration.vibrate(duration: 500)};
        }

        refresh();
      });
    }

    if (fromForcedOneDOwn) {
      // ++counter;
      ktimer.cancel();
      setTimer(slowSpeed, counter);
    } else if (fromSpeedSet && speedUp == true) {
      setTimer(fastSpeed, counter);
    } else if (fromSpeedSet && speedUp == false) {
      setTimer(slowSpeed, counter);
    } else {
      speedUp ? setTimer(fastSpeed, counter) : setTimer(slowSpeed, counter);
    }
  }

  void endScreen() {
    //print('SHOW TETRIS MESSAGE');
    for (int i = 0; i < 20; i++) {
      for (int y = 0; y < 10; y++) {
        table[i][y] = 0;
      }
    }
    table[5][0] = 1;
    table[6][0] = 1;
    table[7][0] = 1;
    table[8][0] = 1;
    table[8][0] = 1;
    table[9][0] = 1;
    table[9][1] = 1;
    table[5][3] = 1;
    table[6][2] = 1;
    table[7][2] = 1;
    table[8][2] = 1;
    table[9][3] = 1;
    table[8][4] = 1;
    table[7][4] = 1;
    table[6][4] = 1;
    table[5][7] = 1;
    table[5][6] = 1;
    table[5][5] = 1;
    table[6][5] = 1;
    table[7][5] = 1;
    table[7][6] = 1;
    table[8][6] = 1;
    table[9][6] = 1;
    table[9][5] = 1;
    table[5][9] = 1;
    table[5][8] = 1;
    table[6][8] = 1;
    table[7][8] = 1;
    table[8][8] = 1;
    table[9][8] = 1;

    table[12][3] = 1;
    table[12][6] = 1;
    table[15][2] = 1;
    table[14][3] = 1;
    table[14][4] = 1;
    table[14][5] = 1;
    table[14][6] = 1;
    table[15][7] = 1;

    refresh();
  }

  void setCurrentPiece() async {
    fetchMyPunishment();
    punishWith(punish);
    punish = 0;
    pieceRotation = Rotation.base;
    currentPiece = nextPieceToPlay;

    nextPieceToPlay = allThePieces[rand.nextInt(7)];

    currentPiecePosition = [
      currentPiece.part1,
      currentPiece.part2,
      currentPiece.part3,
      currentPiece.part4
    ];
    addToTable(currentPiecePosition);
    ;
  }

  void addToTable(List<List<int>> curr) {
    table[curr[0][0]][curr[0][1]]++;
    table[curr[1][0]][curr[1][1]]++;
    table[curr[2][0]][curr[2][1]]++;
    table[curr[3][0]][curr[3][1]]++;
    refresh();
  }

  bool downOneRow() {
    table2 = [
      for (var sublist in table) [...sublist]
    ];
    if (secondChance == 0) {
      if (currentPiecePosition[0][0] < 19 &&
          currentPiecePosition[1][0] < 19 &&
          currentPiecePosition[2][0] < 19 &&
          currentPiecePosition[3][0] < 19) {
        table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]--;
        table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]--;
        table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]--;
        table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]--;
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1]],
          [currentPiecePosition[1][0] + 1, currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] + 1, currentPiecePosition[2][1]],
          [currentPiecePosition[3][0] + 1, currentPiecePosition[3][1]],
        ];

        table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]++;
        table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]++;
        table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]++;
        table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]++;
      }
    }

    if (checkCollision() == 2) {
      table = [
        for (var sublist in table2) [...sublist]
      ];

      refresh();
      return true;
    } else if (checkCollision() == 1) {
      secondChance++;
      if (secondChance == 1) {
        secondChance++;
        refresh();
        return false;
      } else if (secondChance >= 2) {
        secondChance = 0;
        refresh();
        return true;
      }
    }
    refresh();
    return false;
  }

  void movePieceRight() {
    if (end) {
      return;
    }
    Vibration.vibrate(duration: 10);
    if (currentPiecePosition[0][1] == 9 ||
        currentPiecePosition[1][1] == 9 ||
        currentPiecePosition[2][1] == 9 ||
        currentPiecePosition[3][1] == 9) {
      return;
    }
    //save table
    table2 = [
      for (var sublist in table) [...sublist]
    ];
    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]--;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]--;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]--;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]--;
    currentPiecePosition = [
      [currentPiecePosition[0][0], currentPiecePosition[0][1] + 1],
      [currentPiecePosition[1][0], currentPiecePosition[1][1] + 1],
      [currentPiecePosition[2][0], currentPiecePosition[2][1] + 1],
      [currentPiecePosition[3][0], currentPiecePosition[3][1] + 1],
    ];

    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]++;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]++;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]++;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]++;
    if (checkCollision() == 2) {
      //restore table
      table = [
        for (var sublist in table2) [...sublist]
      ];
      currentPiecePosition = [
        [currentPiecePosition[0][0], currentPiecePosition[0][1] - 1],
        [currentPiecePosition[1][0], currentPiecePosition[1][1] - 1],
        [currentPiecePosition[2][0], currentPiecePosition[2][1] - 1],
        [currentPiecePosition[3][0], currentPiecePosition[3][1] - 1],
      ];
    }
    refresh();
  }

  void movePieceLeft() {
    if (end) {
      return;
    }
    Vibration.vibrate(duration: 10);
    if (currentPiecePosition[0][1] == 0 ||
        currentPiecePosition[1][1] == 0 ||
        currentPiecePosition[2][1] == 0 ||
        currentPiecePosition[3][1] == 0) {
      return;
    }
    //save table
    table2 = [
      for (var sublist in table) [...sublist]
    ];
    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]--;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]--;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]--;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]--;
    currentPiecePosition = [
      [currentPiecePosition[0][0], currentPiecePosition[0][1] - 1],
      [currentPiecePosition[1][0], currentPiecePosition[1][1] - 1],
      [currentPiecePosition[2][0], currentPiecePosition[2][1] - 1],
      [currentPiecePosition[3][0], currentPiecePosition[3][1] - 1],
    ];

    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]++;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]++;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]++;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]++;
    if (checkCollision() == 2) {
      //restore table
      table = [
        for (var sublist in table2) [...sublist]
      ];
      currentPiecePosition = [
        [currentPiecePosition[0][0], currentPiecePosition[0][1] + 1],
        [currentPiecePosition[1][0], currentPiecePosition[1][1] + 1],
        [currentPiecePosition[2][0], currentPiecePosition[2][1] + 1],
        [currentPiecePosition[3][0], currentPiecePosition[3][1] + 1],
      ];
    }
    refresh();
  }

  // 0 -> no COLLI, 1 -> bottom COLLI, 2 -> Piece COLLI
  int checkCollision() {
    for (int i = 0; i < 20; i++) {
      for (int y = 0; y < 10; y++) {
        if (table[i][y] > 1) {
          return 2;
        }
      }
    }
    if (currentPiecePosition[0][0] == 19 ||
        currentPiecePosition[1][0] == 19 ||
        currentPiecePosition[2][0] == 19 ||
        currentPiecePosition[3][0] == 19) {
      return 1;
    }
    return 0;
  }

  void rotatePiece() {
    if (end) {
      return;
    }
    Vibration.vibrate(duration: 10);
    switch (currentPiece.name) {
      case 'Omikron':
        rotateOmikron();
      case 'Giota':
        rotateGiota();
      case 'Lamda':
        rotateLamda();
      case 'Jey':
        rotateJey();
      case 'Sigma':
        rotateSigma();
      case 'Zetta':
        rotateZetta();
      case 'Taf':
        rotateTaf();
    }
  }

  void rotateOmikron() {
    //print('Omikron');
  }

  void rotateGiota() {
    bool success = false;
    if (pieceRotation == Rotation.base) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if ((currentPiecePosition[2][0] >= 2 &&
              currentPiecePosition[2][0] <= 18) &&
          currentPiecePosition[2][1] >= 2 &&
          currentPiecePosition[2][1] <= 8 &&
          table[currentPiecePosition[0][0] - 2]
                  [currentPiecePosition[0][1] + 2] ==
              0 &&
          table[currentPiecePosition[1][0] - 1]
                  [currentPiecePosition[1][1] + 1] ==
              0 &&
          table[currentPiecePosition[2][0]][currentPiecePosition[2][1]] == 0 &&
          table[currentPiecePosition[3][0] + 1]
                  [currentPiecePosition[3][1] - 1] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] - 2, currentPiecePosition[0][1] + 2],
          [currentPiecePosition[1][0] - 1, currentPiecePosition[1][1] + 1],
          [currentPiecePosition[2][0], currentPiecePosition[2][1]],
          [currentPiecePosition[3][0] + 1, currentPiecePosition[3][1] - 1],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;

        refresh();
        pieceRotation = Rotation.t90;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    } else if (pieceRotation == Rotation.t90) {
      try {
        --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        if (currentPiecePosition[2][1] >= 2 &&
            currentPiecePosition[2][1] <= 8 &&
            currentPiecePosition[2][0] >= 2 &&
            currentPiecePosition[2][0] <= 18 &&
            table[currentPiecePosition[0][0] + 2]
                    [currentPiecePosition[0][1] - 2] ==
                0 &&
            table[currentPiecePosition[1][0] + 1]
                    [currentPiecePosition[1][1] - 1] ==
                0 &&
            table[currentPiecePosition[2][0]][currentPiecePosition[2][1]] ==
                0 &&
            table[currentPiecePosition[3][0] - 1]
                    [currentPiecePosition[3][1] + 1] ==
                0) {
          currentPiecePosition = [
            [currentPiecePosition[0][0] + 2, currentPiecePosition[0][1] - 2],
            [currentPiecePosition[1][0] + 1, currentPiecePosition[1][1] - 1],
            [currentPiecePosition[2][0], currentPiecePosition[2][1]],
            [currentPiecePosition[3][0] - 1, currentPiecePosition[3][1] + 1],
          ];
          ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
          ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
          ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
          ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
          success = true;
          refresh();
          if (currentPiecePosition[3][0] == 18) {
            secondChance = 0;
          } else if (currentPiecePosition[3][0] == 19) {
            secondChance = 1;
          }
          pieceRotation = Rotation.base;
        }
        if (success == false) {
          ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
          ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
          ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
          ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        }
      } catch (e) {
        //print('ZZZZZZZZZZZZZZZZZZZZZZz');
      }

      //print('Giota');
    }
  }

//part1: [0, 4], part2: [1, 4], part3: [2, 4], part4: [2, 5]
  void rotateLamda() {
    bool success = false;
    if (pieceRotation == Rotation.base) {
      try {
        --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        if (currentPiecePosition[1][0] >= 1 &&
            currentPiecePosition[1][0] <= 18 &&
            currentPiecePosition[1][1] >= 1 &&
            currentPiecePosition[1][1] <= 8 &&
            table[currentPiecePosition[0][0] + 1]
                    [currentPiecePosition[0][1] - 1] ==
                0 &&
            table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] ==
                0 &&
            table[currentPiecePosition[2][0] - 1]
                    [currentPiecePosition[2][1] + 1] ==
                0 &&
            table[currentPiecePosition[3][0] - 2][currentPiecePosition[3][1]] ==
                0) {
          currentPiecePosition = [
            [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] - 1],
            [currentPiecePosition[1][0], currentPiecePosition[1][1]],
            [currentPiecePosition[2][0] - 1, currentPiecePosition[2][1] + 1],
            [currentPiecePosition[3][0] - 2, currentPiecePosition[3][1]],
          ];
          ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
          ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
          ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
          ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
          success = true;
          pieceRotation = Rotation.t90;
          if (currentPiecePosition[0][0] == 18) {
            secondChance = 0;
          } else if (currentPiecePosition[0][0] == 19) {
            secondChance = 1;
          }
        }
        if (success == false) {
          ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
          ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
          ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
          ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        }
        refresh();
      } catch (e) {}
    } else if (pieceRotation == Rotation.t90) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[1][0] >= 1 &&
          currentPiecePosition[1][0] <= 18 &&
          currentPiecePosition[1][1] >= 1 &&
          currentPiecePosition[1][1] <= 8 &&
          table[currentPiecePosition[0][0] + 1]
                  [currentPiecePosition[0][1] + 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] - 1]
                  [currentPiecePosition[2][1] - 1] ==
              0 &&
          table[currentPiecePosition[3][0]][currentPiecePosition[3][1] - 2] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] + 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] - 1, currentPiecePosition[2][1] - 1],
          [currentPiecePosition[3][0], currentPiecePosition[3][1] - 2],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        pieceRotation = Rotation.t180;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    } else if (pieceRotation == Rotation.t180) {
      try {
        --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        if (currentPiecePosition[1][0] >= 1 &&
            currentPiecePosition[1][0] <= 18 &&
            currentPiecePosition[1][1] >= 1 &&
            currentPiecePosition[1][1] <= 8 &&
            table[currentPiecePosition[0][0] - 1]
                    [currentPiecePosition[0][1] + 1] ==
                0 &&
            table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] ==
                0 &&
            table[currentPiecePosition[2][0] + 1]
                    [currentPiecePosition[2][1] - 1] ==
                0 &&
            table[currentPiecePosition[3][0] + 2][currentPiecePosition[3][1]] ==
                0) {
          currentPiecePosition = [
            [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] + 1],
            [currentPiecePosition[1][0], currentPiecePosition[1][1]],
            [currentPiecePosition[2][0] + 1, currentPiecePosition[2][1] - 1],
            [currentPiecePosition[3][0] + 2, currentPiecePosition[3][1]],
          ];
          ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
          ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
          ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
          ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
          success = true;
          refresh();
          pieceRotation = Rotation.t270;
        }
        if (success == false) {
          ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
          ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
          ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
          ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        }
      } catch (e) {}
    } else if (pieceRotation == Rotation.t270) {
      try {
        --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        if (currentPiecePosition[1][0] >= 1 &&
            currentPiecePosition[1][0] <= 18 &&
            currentPiecePosition[1][1] >= 1 &&
            currentPiecePosition[1][1] <= 8 &&
            table[currentPiecePosition[0][0] - 1]
                    [currentPiecePosition[0][1] - 1] ==
                0 &&
            table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] ==
                0 &&
            table[currentPiecePosition[2][0] + 1]
                    [currentPiecePosition[2][1] + 1] ==
                0 &&
            table[currentPiecePosition[3][0]][currentPiecePosition[3][1] + 2] ==
                0) {
          currentPiecePosition = [
            [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] - 1],
            [currentPiecePosition[1][0], currentPiecePosition[1][1]],
            [currentPiecePosition[2][0] + 1, currentPiecePosition[2][1] + 1],
            [currentPiecePosition[3][0], currentPiecePosition[3][1] + 2],
          ];
          ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
          ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
          ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
          ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
          success = true;
          refresh();
          pieceRotation = Rotation.base;
        }
        if (success == false) {
          ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
          ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
          ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
          ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        }
      } catch (e) {}
    }
    //print('Lamda');
  }

  void rotateJey() {
    bool success = false;
    if (pieceRotation == Rotation.base) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[1][0] >= 1 &&
          currentPiecePosition[1][0] <= 18 &&
          currentPiecePosition[1][1] >= 1 &&
          currentPiecePosition[1][1] <= 8 &&
          table[currentPiecePosition[0][0] + 1]
                  [currentPiecePosition[0][1] - 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] - 1]
                  [currentPiecePosition[2][1] + 1] ==
              0 &&
          table[currentPiecePosition[3][0]][currentPiecePosition[3][1] + 2] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] - 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] - 1, currentPiecePosition[2][1] + 1],
          [currentPiecePosition[3][0], currentPiecePosition[3][1] + 2],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        pieceRotation = Rotation.t90;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
      refresh();
    } else if (pieceRotation == Rotation.t90) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[1][0] >= 1 &&
          currentPiecePosition[1][0] <= 18 &&
          currentPiecePosition[1][1] >= 1 &&
          currentPiecePosition[1][1] <= 8 &&
          table[currentPiecePosition[0][0] + 1]
                  [currentPiecePosition[0][1] + 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] - 1]
                  [currentPiecePosition[2][1] - 1] ==
              0 &&
          table[currentPiecePosition[3][0] - 2][currentPiecePosition[3][1]] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] + 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] - 1, currentPiecePosition[2][1] - 1],
          [currentPiecePosition[3][0] - 2, currentPiecePosition[3][1]],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        pieceRotation = Rotation.t180;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    } else if (pieceRotation == Rotation.t180) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[1][0] >= 1 &&
          currentPiecePosition[1][0] <= 18 &&
          currentPiecePosition[1][1] >= 1 &&
          currentPiecePosition[1][1] <= 8 &&
          table[currentPiecePosition[0][0] - 1]
                  [currentPiecePosition[0][1] + 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] + 1]
                  [currentPiecePosition[2][1] - 1] ==
              0 &&
          table[currentPiecePosition[3][0]][currentPiecePosition[3][1] - 2] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] + 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] + 1, currentPiecePosition[2][1] - 1],
          [currentPiecePosition[3][0], currentPiecePosition[3][1] - 2],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        pieceRotation = Rotation.t270;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    } else if (pieceRotation == Rotation.t270) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[1][0] >= 1 &&
          currentPiecePosition[1][0] <= 18 &&
          currentPiecePosition[1][1] >= 1 &&
          currentPiecePosition[1][1] <= 8 &&
          table[currentPiecePosition[0][0] - 1]
                  [currentPiecePosition[0][1] - 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] + 1]
                  [currentPiecePosition[2][1] + 1] ==
              0 &&
          table[currentPiecePosition[3][0] + 2][currentPiecePosition[3][1]] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] - 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] + 1, currentPiecePosition[2][1] + 1],
          [currentPiecePosition[3][0] + 2, currentPiecePosition[3][1]],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        pieceRotation = Rotation.base;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    }
    //print('Jey');
  }

// part1: [0, 5], part2: [0, 4], part3: [1, 4], part4: [1, 3]
  void rotateSigma() {
    bool success = false;
    if (pieceRotation == Rotation.base) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if ((currentPiecePosition[1][0] >= 1 &&
              currentPiecePosition[1][0] <= 18 &&
              currentPiecePosition[1][1] >= 1 &&
              currentPiecePosition[1][1] <= 8) &&
          table[currentPiecePosition[0][0] - 1]
                  [currentPiecePosition[0][1] - 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] - 1]
                  [currentPiecePosition[2][1] + 1] ==
              0 &&
          table[currentPiecePosition[3][0]][currentPiecePosition[3][1] + 2] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] - 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] - 1, currentPiecePosition[2][1] + 1],
          [currentPiecePosition[3][0], currentPiecePosition[3][1] + 2],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;

        refresh();
        pieceRotation = Rotation.t90;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    } else if (pieceRotation == Rotation.t90) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if ((currentPiecePosition[1][0] >= 1 &&
              currentPiecePosition[1][0] <= 18 &&
              currentPiecePosition[1][1] >= 1 &&
              currentPiecePosition[1][1] <= 8) &&
          table[currentPiecePosition[0][0] + 1]
                  [currentPiecePosition[0][1] + 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] + 1]
                  [currentPiecePosition[2][1] - 1] ==
              0 &&
          table[currentPiecePosition[3][0]][currentPiecePosition[3][1] - 2] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] + 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] + 1, currentPiecePosition[2][1] - 1],
          [currentPiecePosition[3][0], currentPiecePosition[3][1] - 2],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();

        pieceRotation = Rotation.base;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    }
    //print('Sigma');
  }

  void rotateZetta() {
    bool success = false;
    if (pieceRotation == Rotation.base) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if ((currentPiecePosition[1][0] >= 1 &&
              currentPiecePosition[1][0] <= 18 &&
              currentPiecePosition[1][1] >= 1 &&
              currentPiecePosition[1][1] <= 8) &&
          table[currentPiecePosition[0][0] + 1]
                  [currentPiecePosition[0][1] + 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] - 1]
                  [currentPiecePosition[2][1] + 1] ==
              0 &&
          table[currentPiecePosition[3][0] - 2][currentPiecePosition[3][1]] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] + 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] - 1, currentPiecePosition[2][1] + 1],
          [currentPiecePosition[3][0] - 2, currentPiecePosition[3][1]],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;

        refresh();
        pieceRotation = Rotation.t90;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    } else if (pieceRotation == Rotation.t90) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if ((currentPiecePosition[1][0] >= 1 &&
              currentPiecePosition[1][0] <= 18 &&
              currentPiecePosition[1][1] >= 1 &&
              currentPiecePosition[1][1] <= 8) &&
          table[currentPiecePosition[0][0] - 1]
                  [currentPiecePosition[0][1] - 1] ==
              0 &&
          table[currentPiecePosition[1][0]][currentPiecePosition[1][1]] == 0 &&
          table[currentPiecePosition[2][0] + 1]
                  [currentPiecePosition[2][1] - 1] ==
              0 &&
          table[currentPiecePosition[3][0] + 2][currentPiecePosition[3][1]] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] - 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] + 1, currentPiecePosition[2][1] - 1],
          [currentPiecePosition[3][0] + 2, currentPiecePosition[3][1]],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();

        pieceRotation = Rotation.base;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    }
    //print('Zetta');
  }

  //   part1: [0, 4], part2: [1, 3], part3: [1, 4], part4: [1, 5]
  void rotateTaf() {
    bool success = false;
    if (pieceRotation == Rotation.base) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[2][0] >= 1 &&
          currentPiecePosition[2][0] <= 18 &&
          currentPiecePosition[2][1] >= 1 &&
          currentPiecePosition[2][1] <= 8 &&
          table[currentPiecePosition[0][0] + 1]
                  [currentPiecePosition[0][1] - 1] ==
              0 &&
          table[currentPiecePosition[1][0] + 1]
                  [currentPiecePosition[1][1] + 1] ==
              0 &&
          table[currentPiecePosition[2][0]][currentPiecePosition[2][1]] == 0 &&
          table[currentPiecePosition[3][0] - 1]
                  [currentPiecePosition[3][1] - 1] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] - 1],
          [currentPiecePosition[1][0] + 1, currentPiecePosition[1][1] + 1],
          [currentPiecePosition[2][0], currentPiecePosition[2][1]],
          [currentPiecePosition[3][0] - 1, currentPiecePosition[3][1] - 1],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        pieceRotation = Rotation.t90;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
      refresh();
    } else if (pieceRotation == Rotation.t90) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[2][0] >= 1 &&
          currentPiecePosition[2][0] <= 18 &&
          currentPiecePosition[2][1] >= 1 &&
          currentPiecePosition[2][1] <= 8 &&
          table[currentPiecePosition[0][0] + 1]
                  [currentPiecePosition[0][1] + 1] ==
              0 &&
          table[currentPiecePosition[1][0] - 1]
                  [currentPiecePosition[1][1] + 1] ==
              0 &&
          table[currentPiecePosition[2][0]][currentPiecePosition[2][1]] == 0 &&
          table[currentPiecePosition[3][0] + 1]
                  [currentPiecePosition[3][1] - 1] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] + 1],
          [currentPiecePosition[1][0] - 1, currentPiecePosition[1][1] + 1],
          [currentPiecePosition[2][0], currentPiecePosition[2][1]],
          [currentPiecePosition[3][0] + 1, currentPiecePosition[3][1] - 1],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        pieceRotation = Rotation.t180;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    } else if (pieceRotation == Rotation.t180) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[2][0] >= 1 &&
          currentPiecePosition[2][0] <= 18 &&
          currentPiecePosition[2][1] >= 1 &&
          currentPiecePosition[2][1] <= 8 &&
          table[currentPiecePosition[0][0] - 1]
                  [currentPiecePosition[0][1] + 1] ==
              0 &&
          table[currentPiecePosition[1][0] - 1]
                  [currentPiecePosition[1][1] - 1] ==
              0 &&
          table[currentPiecePosition[2][0]][currentPiecePosition[2][1]] == 0 &&
          table[currentPiecePosition[3][0] + 1]
                  [currentPiecePosition[3][1] + 1] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] + 1],
          [currentPiecePosition[1][0] - 1, currentPiecePosition[1][1] - 1],
          [currentPiecePosition[2][0], currentPiecePosition[2][1]],
          [currentPiecePosition[3][0] + 1, currentPiecePosition[3][1] + 1],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        pieceRotation = Rotation.t270;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    } else if (pieceRotation == Rotation.t270) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[2][0] >= 1 &&
          currentPiecePosition[2][0] <= 18 &&
          currentPiecePosition[2][1] >= 1 &&
          currentPiecePosition[2][1] <= 8 &&
          table[currentPiecePosition[0][0] - 1]
                  [currentPiecePosition[0][1] - 1] ==
              0 &&
          table[currentPiecePosition[1][0] + 1]
                  [currentPiecePosition[1][1] - 1] ==
              0 &&
          table[currentPiecePosition[2][0]][currentPiecePosition[2][1]] == 0 &&
          table[currentPiecePosition[3][0] - 1]
                  [currentPiecePosition[3][1] + 1] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] - 1],
          [currentPiecePosition[1][0] + 1, currentPiecePosition[1][1] - 1],
          [currentPiecePosition[2][0], currentPiecePosition[2][1]],
          [currentPiecePosition[3][0] - 1, currentPiecePosition[3][1] + 1],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        pieceRotation = Rotation.base;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
    }
    //print('Taf');
  }

  void checkForTetris() async {
    int punishCounter = 0;
    for (int i = 0; i < 20; i++) {
      // each row
      int counter = 0;

      for (int y = 0; y < 10; y++) {
        // add to counter
        if (table[i][y] == 1) {
          counter++;
        }
      }

      //print(counter);
      //check
      if (counter == 10) {
        //print('row is ${i} ');
        for (int row = i; row > 0; row--) {
          for (int cube = 0; cube < 10; cube++) {
            table[row][cube] = table[row - 1][cube];
          }
        }
        //print('TETRIS');
        punishCounter++;
        printError('punishCounter : ${punishCounter}');
        Vibration.vibrate(duration: 100);
      }
    }
    (widget.isOnline)
        ? widget.iAmHost
            ? await fire
                .collection('couches')
                .doc(widget.couchID)
                .update({'punishGuest': punishCounter})
            : await fire
                .collection('couches')
                .doc(widget.couchID)
                .update({'punishHost': punishCounter})
        : null;
  }

  Column buildTable(List<List<int>> table,
      {required double size, required double padding, required double radius}) {
    List<Row> UIrows = [];
    List<Container> simpleRow = [];
    List<List<Container>> allTheRows = [];
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 10; j++) {
        simpleRow.add(
          Container(
            child: Center(
                // child: Text(
                //   '${i}/${j}',
                //   style: TextStyle(color: Colors.white, fontSize: 12),
                // ),
                ),
            height: size,
            width: size,
            margin: EdgeInsets.all(padding),
            decoration: BoxDecoration(
                color: table[i][j] == 0 ? Colors.black : Colors.amberAccent,
                borderRadius: BorderRadius.circular(radius)),
          ),
        );
      }
      allTheRows.add(simpleRow);
      simpleRow = [];
    }

    for (int i = 0; i < 20; i++) {
      UIrows.add(Row(
        children: [...allTheRows[i]],
      ));
    }
    return Column(
      children: [...UIrows],
    );
  }

  Column buildTable4multi4(List<List<int>> table) {
    List<Row> UIrows = [];
    List<Container> simpleRow = [];
    List<List<Container>> allTheRows = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        simpleRow.add(
          Container(
            child: Center(
                // child: Text(
                //   '${i}/${j}',
                //   style: TextStyle(color: Colors.white, fontSize: 5),
                // ),
                ),
            height: 10,
            width: 10,
            margin: EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: table[i][j] == 0 ? Colors.black : Colors.amberAccent,
                borderRadius: BorderRadius.circular(1)),
          ),
        );
      }
      allTheRows.add(simpleRow);
      simpleRow = [];
    }

    for (int i = 0; i < 4; i++) {
      UIrows.add(Row(
        children: [...allTheRows[i]],
      ));
    }
    return Column(
      children: [...UIrows],
    );
  }
}
