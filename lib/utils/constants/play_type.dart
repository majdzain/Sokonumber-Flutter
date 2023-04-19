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

String getPlayTypeShortDisplay(PlayType playType) {
  switch (playType) {
    case PlayType.User:
      return 'User';
    case PlayType.DFS:
      return 'DFS';
    case PlayType.BFS:
      return 'BFS';
    case PlayType.UCS:
      return 'UCS';
    case PlayType.A_STAR:
      return 'A*';
    default:
      return '';
  }
}
