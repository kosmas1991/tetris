class Piece {
  final String name;
  final List<int> part1;
  final List<int> part2;
  final List<int> part3;
  final List<int> part4;
  //final List<int> part5;

  Piece({
    required this.name,
    required this.part1,
    required this.part2,
    required this.part3,
    required this.part4,
    //this.part5 = const [-1, -1],
  });
}

// O
final Piece Omikron =
    Piece(name: 'Omikron', part1: [0, 4], part2: [0, 5], part3: [1, 4], part4: [1, 5]);

// I
final Piece Giota = Piece(name: 'Giota', part1: [0, 3], part2: [0, 4], part3: [0, 5], part4: [0, 6]);

// L
final Piece Lamda = Piece( name: 'Lamda', part1: [0, 4], part2: [1, 4], part3: [2, 4], part4: [2, 5]);

// J
final Piece Jey = Piece(name: 'Jey', part1: [0, 5], part2: [1, 5], part3: [2, 5], part4: [2, 4]);

// S
final Piece Sigma = Piece(name: 'Sigma', part1: [0, 5], part2: [0, 4], part3: [1, 4], part4: [1, 3]);

// Z
final Piece Zetta = Piece(name: 'Zetta', part1: [0, 4], part2: [0, 5], part3: [1, 5], part4: [1, 6]);

// T
final Piece Taf = Piece(name: 'Taf', part1: [0, 4], part2: [1, 3], part3: [1, 4], part4: [1, 5]);

final List<Piece> allThePieces = [Omikron, Giota, Lamda, Jey, Sigma, Zetta, Taf];
