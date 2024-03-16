import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tetris/variables/vars.dart' as table_var;

class GridPanel extends StatefulWidget {
  const GridPanel({super.key});

  @override
  State<GridPanel> createState() => _GridPanelState();
}

class _GridPanelState extends State<GridPanel> {
  var table = table_var.table;
  Column a = Column();

  @override
  Widget build(BuildContext context) {
    void refresh() {
      setState(() {
        a = buildTable(table);
      });
    }

    void playButton() {
      table[0][4] = 1;
      table[0][5] = 1;
      table[1][4] = 1;
      table[1][5] = 1;
      var plusOne = 0;
      Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (plusOne != 0) {
          table[plusOne - 1][4] = 0;
          table[plusOne - 1][5] = 0;
        }

        table[plusOne][4] = 1;
        table[plusOne][5] = 1;
        table[plusOne + 1][4] = 1;
        table[plusOne + 1][5] = 1;

        refresh();

        plusOne++;
        //collision checker
        if (plusOne == 19 || table[plusOne + 1][4] == 1) {
          timer.cancel();
          playButton();
        }
      });
      //print(table);
    }

    setState(() {
      a = buildTable(table);
    });

    return Column(
      children: [
        a,
        TextButton(
            onPressed: () {
              playButton();
            },
            child: Text('Play')),
        TextButton(onPressed: () {}, child: Text('Left')),
        TextButton(onPressed: () {}, child: Text('Right'))
      ],
    );
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
