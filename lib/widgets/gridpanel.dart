import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetris/models/piece.dart';
import 'package:tetris/variables/vars.dart' as table_var;
import 'package:vibration/vibration.dart';


class GridPanel extends StatefulWidget {
  const GridPanel({super.key});

  @override
  State<GridPanel> createState() => _GridPanelState();
}

class _GridPanelState extends State<GridPanel> {
  bool speedUp = false;
  bool resetPressed = false;
  Random rand = Random();
  Column daUI = Column();
  var table = table_var.table;
  var table2 = table_var.table;
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
    setState(() {
      daUI = buildTable(table);
    });

    return Column(
      children: [
        daUI,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  start();
                },
                child: Text(
                  'Start',
                  style: TextStyle(color: Color.fromARGB(255, 36, 116, 39)),
                )),
            TextButton(
                onPressed: () {
                  resetPressed = true;
                },
                child: Text(
                  'Reset',
                  style:
                      TextStyle(color: const Color.fromARGB(255, 117, 41, 36)),
                ))
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: Colors.yellow,
              ),
              child: IconButton(
                onPressed: () {
                  movePieceLeft();
                },
                icon: Icon(Icons.chevron_left_sharp),
                iconSize: 50,
              ),
            ),
            SizedBox(
              width: 30,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: Colors.yellow),
              child: IconButton(
                onPressed: () {
                  movePieceRight();
                },
                icon: Icon(Icons.chevron_right_sharp),
                iconSize: 50,
              ),
            ),
            SizedBox(
              width: 30,
            ),
            Listener(
              //speedUp
              onPointerDown: (event) {
                speedUp = true;
              },
              //speedDown
              onPointerUp: (event) {
                speedUp = false;
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    color: Colors.yellow),
                child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.keyboard_double_arrow_down,
                      size: 50,
                    )),
              ),
            ),
            SizedBox(
              width: 30,
            ),
            Container(
              decoration: BoxDecoration(
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
    );
  }

  bool end = false;
  void refresh() {
    setState(() {
      daUI = buildTable(table);
    });
  }

  void reset() {
    for (int line = 0; line < 20; line++) {
      for (int number = 0; number < 10; number++) {
        table[line][number] = 0;
      }
    }
    gameLoop();
    resetPressed = false;
  }

  void start() {
    gameLoop();
  }

  void gameLoop() {
    int counter = 0;
    checkForTetris();
    setCurrentPiece();
    refresh();

    setTimer(int millisecs, int counterFun) {
      counter = counterFun;
      Timer.periodic(Duration(milliseconds: millisecs), (timer) {
        if (millisecs == 80 && speedUp == false) {
          timer.cancel();
          setTimer(500, counter);
          return;
        }
        if (millisecs == 500 && speedUp == true) {
          timer.cancel();

          setTimer(80, counter);
          return;
        }
        counter++;
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
        }

        if (failed) {
          timer.cancel();
          !end ? gameLoop() : Vibration.vibrate(duration: 500);;
        }
        refresh();
      });
    }

    speedUp ? setTimer(80, counter) : setTimer(500, counter);
  }

  void setCurrentPiece() {
    pieceRotation = Rotation.base;
    currentPiece = allThePieces[rand.nextInt(7)];

    currentPiecePosition = [
      currentPiece.part1,
      currentPiece.part2,
      currentPiece.part3,
      currentPiece.part4
    ];
    addToTable(currentPiecePosition);
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
    print('Omikron');
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
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (currentPiecePosition[2][1] >= 2 &&
          currentPiecePosition[2][1] <= 8 &&
          table[currentPiecePosition[0][0] + 2]
                  [currentPiecePosition[0][1] - 2] ==
              0 &&
          table[currentPiecePosition[1][0] + 1]
                  [currentPiecePosition[1][1] - 1] ==
              0 &&
          table[currentPiecePosition[2][0]][currentPiecePosition[2][1]] == 0 &&
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

        pieceRotation = Rotation.base;
      }
      if (success == false) {
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      }
      print('Giota');
    }
  }

//part1: [0, 4], part2: [1, 4], part3: [2, 4], part4: [2, 5]
  void rotateLamda() {
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
    }
    print('Lamda');
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
    print('Jey');
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
    print('Sigma');
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
    print('Zetta');
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
    print('Taf');
  }

  void checkForTetris() {
    for (int i = 0; i < 20; i++) {
      // each row
      int counter = 0;

      for (int y = 0; y < 10; y++) {
        // add to counter
        if (table[i][y] == 1) {
          counter++;
        }
      }

      print(counter);
      //check
      if (counter == 10) {
        print('row is ${i} ');
        for (int row = i; row > 0; row--) {
          for (int cube = 0; cube < 10; cube++) {
            table[row][cube] = table[row - 1][cube];
          }
        }
        print('TETRIS');
        Vibration.vibrate(duration: 100);
      }
    }
  }

  Column buildTable(List<List<int>> table) {
    List<Row> UIrows = [];
    List<Container> simpleRow = [];
    List<List<Container>> allTheRows = [];
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 10; j++) {
        simpleRow.add(
          Container(
            child: Center(
                // child:
                // Text(
                //   '${i}/${j}',
                //   style: TextStyle(color: Colors.white, fontSize: 12),
                // ),
                ),
            height: 25,
            width: 25,
            margin: EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: table[i][j] == 0 ? Colors.black : Colors.yellow,
                borderRadius: BorderRadius.circular(3)),
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
}
