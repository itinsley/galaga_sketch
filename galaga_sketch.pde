/********* VARIABLES *********/
int screenSize = 500;
int playerX = 242;
int playerY = 483;
char playerDirection;
PlayerBullet playerBullet;
AlienShip alienShip;
ArrayList<AlienShip> alienShips;

class PlayerBullet {
  PImage img;
  int X;
  int Y;
  int velocity=4;

  PlayerBullet(int x, int y) {
    img = loadImage("graphics/player-bullet.png");      
    X=x;
    Y=y;
  }

  float centreX() {
    return (img.width/2)+X;
  }

  float centreY() {
    return (img.height/2)+Y;
  }

  void draw() {
    image(img, X, Y);
  }

  void move() {
    Y=Y-velocity;
  }
};

class AlienShip {
  PImage img;  
  int X;
  int Y;
  int gravity=1;
  char direction='r';
  int explosionStep=0;

  AlienShip(int x, int y) {
    img = loadImage("graphics/alien-ship.png");      
    X=x;
    Y=y;
  }

  void hit() {
    explosionStep=1;
  }
  float centreX() {
    return (img.width/2)+X;
  }

  float centreY() {
    return (img.height/2)+Y;
  }

  void drawExplosion() {
    println(explosionStep);
    if (explosionStep==0) {
      return;
    }
    switch(explosionStep) {
    case 1: 
      img = loadImage("graphics/alien-explosion-1.png");
      explosionStep++;
      break;
    case 2:
      img = loadImage("graphics/alien-explosion-2.png");
      explosionStep++;
      break;
    case 3:
      //Wait a cycle
      explosionStep++;
      break;
    default:
      img = loadImage("graphics/alien-ship.png"); //Return to default just for now.
      explosionStep=0;
      break;
    }
  }

  boolean isAlive() {
    println (explosionStep);
    return(explosionStep<4);
  }

  void draw() {
    image(img, X, Y);
    drawExplosion();
  }

  void checkWall() {
    if (X>screenSize-img.width) {
      println("Wall!");
      direction='l';
    }
  }

  void move() {
    checkWall();
    if (direction=='r') {
      X=X+1;
    } else {
      X=X-1;
    }
    Y=Y+gravity;
  }
};

/********* SETUP BLOCK *********/

void setup() {
  size(500, 500);
  frameRate(10);
  initAlienArmy();
}


/********* DRAW BLOCK *********/

void draw() {
  gameScreen();
}

void gameScreen() {
  background(0);
  drawPlayer();
  drawPlayerBullet();
  drawAlienArmy();
  movePlayer();
  movePlayerBullet();
  detectCollision();
}

/********* INPUTS *********/
void keyPressed() {
  if (key=='a'||key=='A') {
    playerDirection='l';
  };
  if (key=='d'||key=='D') {
    playerDirection='r';
  }   
  if (key==' ') {
    playerShoot();
  }
  if (key=='q'||key=='Q') {
    setup();
  }
}
void keyReleased() {
  if ((key=='a'||key=='A') && playerDirection=='l') {
    playerDirection=' ';
  } 
  if ((key=='d'||key=='D') && playerDirection=='r') {
    playerDirection=' ';
  }
}

/********* COLLISSIONS *********/
void detectCollision() {
  int collisionThreshold=5;
  if (playerBullet ==null) {
    return;
  }

  for (int i = alienShips.size() - 1; i >= 0; i--) {
    AlienShip alienShip = alienShips.get(i);
    float distanceX = abs(alienShip.centreX()-playerBullet.centreX());
    float distanceY = abs(alienShip.centreY()-playerBullet.centreY());
    if (distanceX< collisionThreshold && distanceY<collisionThreshold) {
      alienShip.hit();
    }
    if (!alienShip.isAlive()) {
      alienShips.remove(i);
    }
  }
}

/********* ALIENS *********/
void initAlienArmy() {
  alienShips = new ArrayList<AlienShip>();
  alienShips.add(alienShip = new AlienShip(250, 400));
}

void drawAlienArmy() { 
  for (AlienShip alienShip : alienShips) {
    alienShip.move();
    alienShip.draw();
  }
}

/********* PLAYER *********/
void drawPlayer() {
  PImage img; 
  img = loadImage("graphics/galaga-player-ship.png");
  image(img, playerX, playerY);
}

void playerShoot() {
  playerBullet = new PlayerBullet(playerX+6, playerY-15);
}

void movePlayer() {
  if (playerDirection=='l') {
    playerX=playerX-3;
  } 
  if (playerDirection=='r') {
    playerX=playerX+3;
  }
}

void movePlayerBullet() {
  if (playerBullet !=null) {
    playerBullet.move();
  }
}

void drawPlayerBullet() {
  if (playerBullet !=null) {
    playerBullet.draw();
  }
}
