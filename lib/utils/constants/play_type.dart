enum PlayType { DFS, BFS, UCS, A_STAR, User }

String getPlayTypeDisplay(PlayType playType) {
  switch (playType) {
    case PlayType.DFS:
      return 'Depth First Search Algorithm';
    case PlayType.BFS:
      return 'Bridth First Search Algorithm';
    case PlayType.UCS:
      return 'Uniform Cost Search Algorithm';
    case PlayType.A_STAR:
      return 'A* Search Algorithm';
    default:
      return '';
  }
}
