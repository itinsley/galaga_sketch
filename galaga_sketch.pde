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
PlayerController gPlayerController;
ArrayList<PlayerBullet> gPlayerBullets;
ArrayList<AlienShipBase> gAlienShips;
Minim gMinim;
AudioPlayer gAudioPlayer;
AlienShipController gAlienShipController;

void setup() {
  loadAssets();
  gPlayer = new Player();
  gPlayerController = new PlayerController(gPlayer);
  gPlayerBullets = new ArrayList<PlayerBullet>();
  gAlienShips = new ArrayList<AlienShipBase>();
  gAlienShipController = new AlienShipController(gAlienShips, gPlayer);

  size(500, 500);
  frameRate(30);
  initAlienArmy();
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

  gPlayerController.guide();
  if (!dying) {
    gAlienShipController.guide();
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
    gPlayerController.leftKeyPressed();
  };
  if (key=='d'||key=='D') {
    gPlayerController.rightDown();
  }   
  if (key==' ') {
    gPlayer.shoot();
  }
  if (key=='q'||key=='Q') {
    dying=false;
    setup();
  }
}

void keyReleased() {
  if (key=='a'||key=='A') {
    gPlayerController.leftKeyReleased();
  } 
  if (key=='d'||key=='D') {
    gPlayerController.rightUp();
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

/********* ALIENS *********/
void initAlienArmy() {
  int posY = gAlienShipController.createBatallion(200, "DEFAULT");
  posY = gAlienShipController.createBatallion(posY, "ATTACK");
}

void alienArmyChangeDirection(char direction) {
  for (AlienShipBase alienShip : gAlienShips) {
    alienShip.changeDirection(direction);
  }
}

void movePlayerBullet() {
  for (PlayerBullet playerBullet : gPlayerBullets) {
    playerBullet.move();
    playerBullet.draw();
  }
}
