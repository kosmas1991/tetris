import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/piece.dart';
import 'package:tetris/variables/vars.dart' as table_var;

class GridPanel extends StatefulWidget {
  const GridPanel({super.key});

  @override
  State<GridPanel> createState() => _GridPanelState();
}

class _GridPanelState extends State<GridPanel> {
  Random rand = Random();
  @override
  void initState() {
    //setCurrentPiece();
    super.initState();
  }

  Column daUI = Column();
  var table = table_var.table;
  var table2 = table_var.table;
  Piece currentPiece = Omikron;
  Rotation pieceRotation = Rotation.base;
  //dummy data
  List<List<int>> currentPiecePosition = [
    [0, 0],
    [0, 0],
    [0, 0],
    [0, 0],
  ]; //dummy data
  int secondChance = 0;

  @override
  Widget build(BuildContext context) {
    setState(() {
      daUI = buildTable(table);
    });

    return Column(
      children: [
        daUI,
        TextButton(
            onPressed: () {
              start();
            },
            child: Text('Start')),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                movePieceLeft();
              },
              icon: Icon(Icons.chevron_left_sharp),
              iconSize: 60,
            ),
            IconButton(
              onPressed: () {
                movePieceRight();
              },
              icon: Icon(Icons.chevron_right_sharp),
              iconSize: 60,
            )
          ],
        ),
        IconButton(
            onPressed: rotatePiece,
            icon: Icon(
              Icons.rotate_90_degrees_ccw,
              size: 40,
            )),
      ],
    );
  }

  bool end = false;
  // refresh the board
  void refresh() {
    setState(() {
      daUI = buildTable(table);
    });
  }

  //loop every ${time} selected
  void start() {
    gameLoop();
  }

  void gameLoop() {
    setCurrentPiece();
    refresh();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      bool failed = downOneRow();
      if (failed && timer.tick == 1) {
        end = true;
      }
      if (failed) {
        timer.cancel();
        !end ? gameLoop() : print('end');
      }

      refresh();
    });
  }

  void setCurrentPiece() {
    pieceRotation = Rotation.base;
    currentPiece = allThePieces[rand.nextInt(7)]; //random select
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

  // [[0,0],[0,0],[0,0],[0,0]]
  void rotateOmikron() {
    print('Omikron');
  }

  void rotateGiota() {
    if (pieceRotation == Rotation.base) {
      if (table[currentPiecePosition[0][0] - 1]
                  [currentPiecePosition[0][1] + 1] ==
              0 &&
          table[currentPiecePosition[2][0] + 1]
                  [currentPiecePosition[2][1] - 1] ==
              0 &&
          table[currentPiecePosition[3][0] + 2]
                  [currentPiecePosition[3][1] - 2] ==
              0 && //check floor an ceil
          (currentPiecePosition[0][0] - 1 >= 0 &&
              currentPiecePosition[2][0] + 1 <= 19 &&
              currentPiecePosition[3][0] + 2 <= 19)) {
        //afairesi kai prosthesi
        --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        currentPiecePosition = [
          [currentPiecePosition[0][0] - 1, currentPiecePosition[0][1] + 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] + 1, currentPiecePosition[2][1] - 1],
          [currentPiecePosition[3][0] + 2, currentPiecePosition[3][1] - 2],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        refresh();
        // Rotation.t90
        pieceRotation = Rotation.t90;
      }
    } else if (pieceRotation == Rotation.t90) {
      if (table[currentPiecePosition[0][0] + 1]
                  [currentPiecePosition[0][1] - 1] ==
              0 &&
          table[currentPiecePosition[2][0] - 1]
                  [currentPiecePosition[2][1] + 1] ==
              0 &&
          table[currentPiecePosition[3][0] - 2]
                  [currentPiecePosition[3][1] + 2] ==
              0 &&
          (currentPiecePosition[0][1] - 1 >= 0 &&
              currentPiecePosition[2][1] + 1 <= 9 &&
              currentPiecePosition[3][1] + 2 <= 9)) {
        //afairesi kai prosthesi
        --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 1, currentPiecePosition[0][1] - 1],
          [currentPiecePosition[1][0], currentPiecePosition[1][1]],
          [currentPiecePosition[2][0] - 1, currentPiecePosition[2][1] + 1],
          [currentPiecePosition[3][0] - 2, currentPiecePosition[3][1] + 2],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        refresh();
        // Rotation.t90
        pieceRotation = Rotation.base;
        // an petyxei Rotation.base
      }
      print('Giota');
    }
  }

// part1: [0, 4], part2: [1, 4], part3: [2, 4], part4: [2, 5]
  void rotateLamda() {
    bool success = false;
    //save table
    table2 = [
      for (var sublist in table) [...sublist]
    ];
    if (pieceRotation == Rotation.base) {
      --table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
      --table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
      --table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
      --table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
      if (table[currentPiecePosition[0][0] + 2]
                  [currentPiecePosition[0][1] - 1] ==
              0 &&
          table[currentPiecePosition[1][0] + 1][currentPiecePosition[1][1]] ==
              0 &&
          table[currentPiecePosition[2][0]][currentPiecePosition[2][1] + 1] ==
              0 &&
          table[currentPiecePosition[3][0] - 1][currentPiecePosition[3][1]] ==
              0) {
        currentPiecePosition = [
          [currentPiecePosition[0][0] + 2, currentPiecePosition[0][1] - 1],
          [currentPiecePosition[1][0] + 1, currentPiecePosition[1][1]],
          [currentPiecePosition[2][0], currentPiecePosition[2][1] + 1],
          [currentPiecePosition[3][0] - 1, currentPiecePosition[3][1]],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;

        // Rotation.t90
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
      if (table[currentPiecePosition[0][0]][currentPiecePosition[0][1] + 2] ==
              0 &&
          table[currentPiecePosition[1][0] - 1]
                  [currentPiecePosition[1][1] + 1] ==
              0 &&
          table[currentPiecePosition[2][0] - 2][currentPiecePosition[2][1]] ==
              0 &&
          table[currentPiecePosition[3][0] - 1]
                  [currentPiecePosition[3][1] - 1] ==
              0) {
        //afairesi kai prosthesi

        currentPiecePosition = [
          [currentPiecePosition[0][0], currentPiecePosition[0][1] + 2],
          [currentPiecePosition[1][0] - 1, currentPiecePosition[1][1] + 1],
          [currentPiecePosition[2][0] - 2, currentPiecePosition[2][1]],
          [currentPiecePosition[3][0] - 1, currentPiecePosition[3][1] - 1],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        // Rotation.t90
        pieceRotation = Rotation.t180;
        // an petyxei Rotation.base
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
      if (table[currentPiecePosition[0][0] - 2][currentPiecePosition[0][1]] ==
              0 &&
          table[currentPiecePosition[1][0] - 1]
                  [currentPiecePosition[1][1] - 1] ==
              0 &&
          table[currentPiecePosition[2][0]][currentPiecePosition[2][1] - 2] ==
              0 &&
          table[currentPiecePosition[3][0] + 1]
                  [currentPiecePosition[3][1] - 1] ==
              0) {
        //afairesi kai prosthesi

        currentPiecePosition = [
          [currentPiecePosition[0][0] - 2, currentPiecePosition[0][1]],
          [currentPiecePosition[1][0] - 1, currentPiecePosition[1][1] - 1],
          [currentPiecePosition[2][0], currentPiecePosition[2][1] - 2],
          [currentPiecePosition[3][0] + 1, currentPiecePosition[3][1] - 1],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        // Rotation.t90
        pieceRotation = Rotation.t270;
        // an petyxei Rotation.base
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
      if (table[currentPiecePosition[0][0]][currentPiecePosition[0][1] - 2] ==
              0 &&
          table[currentPiecePosition[1][0] + 1]
                  [currentPiecePosition[1][1] - 1] ==
              0 &&
          table[currentPiecePosition[2][0] + 2][currentPiecePosition[2][1]] ==
              0 &&
          table[currentPiecePosition[3][0] + 1]
                  [currentPiecePosition[3][1] + 1] ==
              0) {
        //afairesi kai prosthesi

        currentPiecePosition = [
          [currentPiecePosition[0][0], currentPiecePosition[0][1] - 2],
          [currentPiecePosition[1][0] + 1, currentPiecePosition[1][1] - 1],
          [currentPiecePosition[2][0] + 2, currentPiecePosition[2][1]],
          [currentPiecePosition[3][0] + 1, currentPiecePosition[3][1] + 1],
        ];
        ++table[currentPiecePosition[0][0]][currentPiecePosition[0][1]];
        ++table[currentPiecePosition[1][0]][currentPiecePosition[1][1]];
        ++table[currentPiecePosition[2][0]][currentPiecePosition[2][1]];
        ++table[currentPiecePosition[3][0]][currentPiecePosition[3][1]];
        success = true;
        refresh();
        // Rotation.t90
        pieceRotation = Rotation.base;
        // an petyxei Rotation.base
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
    print('Jey');
  }

  void rotateSigma() {
    print('Sigma');
  }

  void rotateZetta() {
    print('Zetta');
  }

  void rotateTaf() {
    print('Taf');
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
            child: Text(
              '${i}/${j}',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          color: table[i][j] == 0 ? Colors.black : Colors.yellow,
          height: 30,
          width: 30,
          margin: EdgeInsets.all(1),
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
