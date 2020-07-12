class PlayerController {
  Player player;
  boolean isLeft;
  boolean isRight;
  char directionDefault;

  PlayerController(Player player) {
    this.player = player;
  }

  void leftKeyPressed() {
    isLeft=true;
    directionDefault='r';
  }
  void leftKeyReleased() {
    isLeft=false;
    directionDefault='l';
  }
  void rightDown() {
    isRight=true;
  }
  void rightUp() {
    isRight=false;
  }
  void move() {
    if (isLeft && isRight) {
      player.move(directionDefault);
    } else if (isLeft && !isRight) {
      player.move('l');
    } else if (!isLeft && isRight) {
      player.move('r');
    }
  }
}
