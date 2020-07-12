import ddf.minim.*;


/********* CONSTANTS *********/
int GROUND_LEVEL_Y=470;
int BULLETS_LIMIT=10;

/********* VARIABLES *********/
int screenSize = 500;
int score=0;
int playerCollisionThreshold=15;
boolean dying =false;

Player gPlayer;
PlayerController playerController;
ArrayList<PlayerBullet> gPlayerBullets;
ArrayList<AlienShipBase> gAlienShips;
Minim gMinim;
AudioPlayer gAudioPlayer;
AlienShipAttackController gAlienShipAttackController;

void setup() {
  bulletImage = loadImage("graphics/player-bullet.png");
  playerImage = loadImage("graphics/galaga-player-ship.png");
  alienShipImageDefault = loadImage("graphics/alien-ship.png");
  alienShipAttackerImageDefault = loadImage("graphics/alien-ship-attacker.png");
  alienExplosion1Image = loadImage("graphics/alien-explosion-1.png");
  alienExplosion2Image = loadImage("graphics/alien-explosion-2.png");
  alienExplosion3Image = loadImage("graphics/alien-explosion-3.png");
  playerExplosionImage1 = loadImage("graphics/galaga-player-ship-explosion-1.png");
  playerExplosionImage2 = loadImage("graphics/galaga-player-ship-explosion-2.png");
  playerExplosionImage3 = loadImage("graphics/galaga-player-ship-explosion-3.png");
  playerExplosionImage4 = loadImage("graphics/galaga-player-ship-explosion-4.png");
  gAlienShips = new ArrayList<AlienShipBase>();
  gAlienShipAttackController = new AlienShipAttackController();

  gMinim = new Minim(this);  
  bulletSound = gMinim.loadFile("sound/8d82b5_Galaga_Firing_Sound_Effect.mp3");    
  killSound = gMinim.loadFile("sound/8d82b5_Galaga_Kill_Enemy_Sound_Effect.mp3");
  playerDeathSound = gMinim.loadFile("sound/player-explosion.wav");

  size(500, 500);
  frameRate(30);
  initAlienArmy();
  initPlayer();
  initPlayerBullets();
  score=0;
}

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
  case "GAMEOVER":
    gameOverScreen();
    break;
  }
}
void initScreen() {
  background(0);
  textAlign(CENTER);
  text("Any key to start", width/2, height/2);
  text("Q to restart", width/2, height/2+50);
  text("A = Move Left | D= Move Right | SPACE=Fire", width/2, height/2+100);
  gAudioPlayer = gMinim.loadFile("sound/8d82b5_Galaga_Theme_Song.mp3");
  //audioPlayer.play();
}
void gameScreen() {
  background(0);
  textAlign(LEFT);
  text("SCORE: "+score, 10, 10);

  playerController.move();
  gPlayer.draw();
  if (!dying) {
    drawPlayerBullets();
    drawAlienArmy();
    gAlienShipAttackController.Guide(gAlienShips);
    movePlayerBullet();
    detectCollision();
  }
  //long maxMemory = Runtime.getRuntime().maxMemory();
  //long allocatedMemory = Runtime.getRuntime().totalMemory();
  //long freeMemory = Runtime.getRuntime().freeMemory();
  //println("Allocated Memory: "+ allocatedMemory);
}
void gameOverScreen() {
  background(0);
  textAlign(CENTER);
  text("GAME OVER", width/2, height/2);
  text("SCORE: "+score, width/2, height/2+40);
  text("Press Q to restart", width/2, height/2+80);
}

/********* INPUTS *********/
void keyPressed() {
  if (gameScreen=="GAMEOVER" && key!='q' && key!='Q') {
    return;
  }
  gameScreen="START";

  if (key=='a'||key=='A') {
    playerController.leftKeyPressed();
  };
  if (key=='d'||key=='D') {
    playerController.rightDown();
  }   
  if (key==' ') {
    gPlayer.shoot();
  }
  if (key=='q'||key=='Q') {
    dying=false;
    setup();
  }

  if (key=='x'||key=='X') {
    ((AlienShipAttacker) gAlienShips.get(50)).attack();
  }
}

void keyReleased() {
  if (key=='a'||key=='A') {
    playerController.leftKeyReleased();
  } 
  if (key=='d'||key=='D') {
    playerController.rightUp();
  }
}

/********* COLLISIONS *********/
void detectCollision() {
  int collisionThreshold=5;

  //** Bullets **
  //Iterate backwards as we may be removing
  for (int pbIdx = gPlayerBullets.size() - 1; pbIdx >= 0; pbIdx--) {
    PlayerBullet playerBullet = gPlayerBullets.get(pbIdx);

    //Iterate backwards as we may be removing
    for (int i = gAlienShips.size() - 1; i >= 0; i--) {
      AlienShipBase alienShip = gAlienShips.get(i);
      float distanceX = abs(alienShip.centreX()-playerBullet.centreX());
      float distanceY = abs(alienShip.centreY()-playerBullet.centreY());
      if (distanceX< collisionThreshold && distanceY<collisionThreshold) {
        alienShip.hit();
        gPlayerBullets.remove(gPlayerBullets.get(pbIdx));
        break;
      }
    }
    if (playerBullet !=null && playerBullet.outOfScreen()) {
      gPlayerBullets.remove(gPlayerBullets.get(pbIdx));
    }
  }
}
/********* PLAYER *********/
void initPlayer() {
  gPlayer = new Player();
  playerController = new PlayerController(gPlayer);
}

void initPlayerBullets() {
  gPlayerBullets = new ArrayList<PlayerBullet>();
}

/********* ALIENS *********/
void initAlienArmy() {
  int posY = createBatallion(200, "DEFAULT");
  posY = createBatallion(posY, "ATTACK");
}

int createBatallion(int posY, String shipType) {
  int posXMargin=20;
  int posYMargin = 20;
  for (int row = 1; row <= 3; row++) {
    int posX = posXMargin;
    for (int col = 1; col <= 10; col++) {
      if (shipType=="DEFAULT") {
        gAlienShips.add(new AlienShip(posX, posY));
      } else {
        gAlienShips.add(new AlienShipAttacker(posX, posY));
      }
      posX = posX + posXMargin;
    }
    posY=posY+posYMargin;
  }
  //DEBUG 1 ship
  //int posX = posXMargin;
  //alienShips.add(new AlienShip(posX, posY));
  return posY;
}

void drawAlienArmy() {
  //** Alien Ships
  for (int i = gAlienShips.size() - 1; i >= 0; i--) {
    AlienShipBase alienShip = gAlienShips.get(i);
    alienShip.move();
    alienShip.draw();
    if (!alienShip.isAlive()) {
      gAlienShips.remove(i);
    }

    // ** Hit Player?
    float distanceX = abs(alienShip.centreX()-gPlayer.centreX());
    float distanceY = abs(alienShip.centreY()-gPlayer.centreY());
    if (distanceX< playerCollisionThreshold && distanceY<playerCollisionThreshold) {
      gPlayer.hit();
    }
  }
}

void alienArmyChangeDirection(char direction) {
  for (AlienShipBase alienShip : gAlienShips) {
    alienShip.changeDirection(direction);
  }
}

void movePlayerBullet() {
  for (PlayerBullet playerBullet : gPlayerBullets) {
    playerBullet.move();
  }
}

void drawPlayerBullets() {
  for (PlayerBullet playerBullet : gPlayerBullets) {
    playerBullet.draw();
  }
}
