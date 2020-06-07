import ddf.minim.*;

/********* VARIABLES *********/
int screenSize = 500;
int playerX = 242;
int playerY = 483;
char playerDirection;
PlayerBullet playerBullet;
AlienShip alienShip;
ArrayList<AlienShip> alienShips;
Minim minim;
AudioPlayer player;


class PlayerBullet {
  PImage img;
  int X;
  int Y;
  int velocity=4;

  PlayerBullet(int x, int y) {
    img = loadImage("graphics/player-bullet.png");
    player = minim.loadFile("sound/8d82b5_Galaga_Firing_Sound_Effect.mp3");
    player.play();
      
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
    if (explosionStep==0) {
      return;
    }
    switch(explosionStep) {
    case 1: 
      img = loadImage("graphics/alien-explosion-1.png");
      player = minim.loadFile("sound/8d82b5_Galaga_Kill_Enemy_Sound_Effect.mp3");
      player.play();    
      explosionStep++;
      break;
    case 2:
      img = loadImage("graphics/alien-explosion-2.png");
      explosionStep++;
      break;
    case 3:
      img = loadImage("graphics/alien-explosion-3.png");
      explosionStep++;
      break;
    case 4:
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
    return(explosionStep<4);
  }

  void draw() {
    image(img, X, Y);
    drawExplosion();
  }

  void checkWall() {
    if (X>screenSize-img.width) {
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
  frameRate(20);
  initAlienArmy();
}


/********* DRAW BLOCK *********/

// We control which screen is active by settings / updating
// gameScreen variable. We display the correct screen according
// to the value of this variable.
String gameScreen = "INSTRUCTIONS";

void draw() {
  switch(gameScreen) {
    case "INSTRUCTIONS": 
      initScreen();
      gameScreen="";
      break;
    case "START":
      gameScreen();
      break;
  }
}
void initScreen() {
  background(0);
  textAlign(CENTER);
  text("Any key to start", width/2, height/2);
  text("Q to restart", width/2, height/2+50);
  text("A = Move Left | D= Move Right | SPACE=Fire", width/2, height/2+100);
  minim = new Minim(this);
  player = minim.loadFile("sound/8d82b5_Galaga_Theme_Song.mp3");
  player.play();
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
   gameScreen="START";
 
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
  int posX = 20;
  for (int i = 1; i <= 10 ; i++) {
    alienShips.add(alienShip = new AlienShip(posX, 200));
    posX = posX + 20;
  }
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
