class Piece {
  final List<int> part1;
  final List<int> part2;
  final List<int> part3;
  final List<int> part4;
  //final List<int> part5;

  Piece({
    required this.part1,
    required this.part2,
    required this.part3,
    required this.part4,
    //this.part5 = const [-1, -1],
  });
}

// O
Piece omikron =
    Piece(part1: [0, 4], part2: [0, 5], part3: [1, 4], part4: [1, 5]);

// I
Piece giota = Piece(part1: [0, 3], part2: [0, 4], part3: [0, 5], part4: [0, 6]);

// L
Piece Lamda = Piece(part1: [0, 4], part2: [1, 4], part3: [2, 4], part4: [2, 5]);

// J
Piece Jey = Piece(part1: [0, 5], part2: [1, 5], part3: [2, 5], part4: [2, 4]);

// S
Piece Sigma = Piece(part1: [0, 5], part2: [0, 4], part3: [1, 4], part4: [1, 3]);

// Z
Piece Zetta = Piece(part1: [0, 4], part2: [0, 5], part3: [1, 5], part4: [1, 6]);

// T
Piece Taf = Piece(part1: [0, 4], part2: [1, 3], part3: [1, 4], part4: [1, 5]);
