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

  Piece currentPiece = Omikron; //dummy data
  List<List<int>> currentPiecePosition = [
    [0, 0],
    [0, 0],
    [0, 0],
    [0, 0],
  ]; //dummy data

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
        TextButton(
            onPressed: () {
              movePieceLeft();
            },
            child: Text('Left')),
        TextButton(
            onPressed: () {
              movePieceRight();
            },
            child: Text('Right'))
      ],
    );
  }

  //loop every ${time} selected
  void start() {
    gameLoop();
  }

  // refresh the board
  void refresh() {
    setState(() {
      daUI = buildTable(table);
    });
  }

  void gameLoop() {
    setCurrentPiece();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      print('TICK    IS    ${timer.tick}');
      bool failed = downOneRow();
      if (failed) {
        timer.cancel();
        gameLoop();
        return;
      }
      refresh();
    });
  }

  void setCurrentPiece() {
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

    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]--;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]--;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]--;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]--;
    currentPiecePosition = [
      [++currentPiecePosition[0][0], currentPiecePosition[0][1]],
      [++currentPiecePosition[1][0], currentPiecePosition[1][1]],
      [++currentPiecePosition[2][0], currentPiecePosition[2][1]],
      [++currentPiecePosition[3][0], currentPiecePosition[3][1]],
    ];

    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]++;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]++;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]++;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]++;

    if (checkCollision() == 2) {
      table = [
        for (var sublist in table2) [...sublist]
      ];

      refresh();
      return true;
    } else if (checkCollision() == 1) {
      refresh();
      return true;
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
    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]--;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]--;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]--;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]--;
    currentPiecePosition = [
      [currentPiecePosition[0][0], ++currentPiecePosition[0][1]],
      [currentPiecePosition[1][0], ++currentPiecePosition[1][1]],
      [currentPiecePosition[2][0], ++currentPiecePosition[2][1]],
      [currentPiecePosition[3][0], ++currentPiecePosition[3][1]],
    ];

    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]++;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]++;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]++;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]++;
    refresh();
  }

  void movePieceLeft() {
    if (currentPiecePosition[0][1] == 0 ||
        currentPiecePosition[1][1] == 0 ||
        currentPiecePosition[2][1] == 0 ||
        currentPiecePosition[3][1] == 0) {
      return;
    }
    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]--;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]--;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]--;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]--;
    currentPiecePosition = [
      [currentPiecePosition[0][0], --currentPiecePosition[0][1]],
      [currentPiecePosition[1][0], --currentPiecePosition[1][1]],
      [currentPiecePosition[2][0], --currentPiecePosition[2][1]],
      [currentPiecePosition[3][0], --currentPiecePosition[3][1]],
    ];

    table[currentPiecePosition[0][0]][currentPiecePosition[0][1]]++;
    table[currentPiecePosition[1][0]][currentPiecePosition[1][1]]++;
    table[currentPiecePosition[2][0]][currentPiecePosition[2][1]]++;
    table[currentPiecePosition[3][0]][currentPiecePosition[3][1]]++;
    refresh();
  }

  // 0 -> no COLLI, 1 -> bottom COLLI, 2 -> Piece COLLI
  int checkCollision() {
    for (int i = 0; i < 20; i++) {
      for (int y = 0; y < 10; y++) {
        if (table[i][y] > 1) {
          print('COLLISION');
          return 2;
        }
      }
    }
    if (currentPiecePosition[0][0] == 19 ||
        currentPiecePosition[1][0] == 19 ||
        currentPiecePosition[2][0] == 19 ||
        currentPiecePosition[3][0] == 19) {
      print('bottom COLLI');
      return 1;
    }
    return 0;
  }

  void rotatePiece() {}

  void rotateOmikron() {}

  void rotateGiota() {}

  void rotateLamda() {}

  void rotateJey() {}

  void rotateSigma() {}

  void rotateZetta() {}

  void rotateTaf() {}
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
