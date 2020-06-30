class PlayerBullet {
  int X;
  int Y;
  int velocity=5;

  PlayerBullet(int x, int y) {
    bulletSound.play();
    bulletSound.rewind();
    X=x;
    Y=y;
  }

  float centreX() {
    return (bulletImage.width/2)+X;
  }

  float centreY() {
    return (bulletImage.height/2)+Y;
  }

  boolean outOfScreen() {
    return Y<=0;
  }
  void draw() {
    image(bulletImage, X, Y);
  }

  void move() {
    Y=Y-velocity;
  }
};
