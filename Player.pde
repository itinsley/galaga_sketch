class Player {
  int X = 242;
  int Y = GROUND_LEVEL_Y;
  int velocity=4;
  int eventStep;
  ArrayList<PImage>imageSequence;
  PImage defaultImage = playerImage;

  Player() {
    image(playerImage, X, Y);
    imageSequence = new ArrayList<PImage>(); 
    imageSequence.add(this.defaultImage);
  }

  void hit() {
    playerDeathSound.play();    
    imageSequence = new ArrayList<PImage>();
    imageSequence.add(playerExplosionImage1);
    imageSequence.add(playerExplosionImage2);
    imageSequence.add(playerExplosionImage3);
    imageSequence.add(playerExplosionImage4);
    dying=true;
    eventStep=0;
  }

  PImage currentImage() {
    return imageSequence.get(eventStep);
  }

  float centreX() {
    return (playerImage.width/2)+X;
  }

  float centreY() {
    return (playerImage.height/2)+Y;
  }

  void shoot() {
    if (gPlayerBullets.size()<=BULLETS_LIMIT) {
      gPlayerBullets.add(new PlayerBullet(X+6, Y-8));
    }
  }

  void move(char direction) {
    if (direction=='l') {
      X=X-velocity;
    } 
    if (direction=='r') {
      X=X+velocity;
    }
  }

  void draw() {
    image(currentImage(), X, Y);
    //Move to next image if there is more than one image in sequence
    if (imageSequence.size()>1) {
      if (eventStep>=3) {
        //Only event in town is the explosion
        gameScreen="GAMEOVER";
      }
      eventStep++;
    }
  }
};
