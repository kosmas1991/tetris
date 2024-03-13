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

    setState(() {
      a = buildTable(table);
    });

    return Column(
      children: [
        a,
        TextButton(
            onPressed: () {
              table[8][0] = 1;
              table[2][07] = 1;
              refresh();
            },
            child: Text('press me'))
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
