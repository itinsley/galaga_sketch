import ddf.minim.*;


/********* CONSTANTS *********/
int GROUND_LEVEL_Y=470;
int BULLETS_LIMIT=10;

/********* VARIABLES *********/
int screenSize = 500;
int score=0;
int playerCollisionThreshold=15;
boolean dying =false;

Player player;
PlayerController playerController;
ArrayList<PlayerBullet> playerBullets;
ArrayList<AlienShipBase> alienShips;
Minim minim;
AudioPlayer audioPlayer;

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
  alienShips = new ArrayList<AlienShipBase>();

  //AlienShip Attack Vectors
  for(int i=200;i<=320;i=i+5){
    YVectors.add(i);
  }

  minim = new Minim(this);  
  bulletSound = minim.loadFile("sound/8d82b5_Galaga_Firing_Sound_Effect.mp3");    
  killSound = minim.loadFile("sound/8d82b5_Galaga_Kill_Enemy_Sound_Effect.mp3");
  playerDeathSound = minim.loadFile("sound/player-explosion.wav");
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
  audioPlayer = minim.loadFile("sound/8d82b5_Galaga_Theme_Song.mp3");
  //audioPlayer.play();
}
void gameScreen() {
  background(0);
  textAlign(LEFT);
  text("SCORE: "+score, 10, 10);

  playerController.move();
  player.draw();
  if (!dying){
    drawPlayerBullets();
    drawAlienArmy();
    alienArmyAttackController();
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
    player.shoot();
  }
  if (key=='q'||key=='Q') {
    dying=false;
    setup();
  }

  if (key=='x'||key=='X') {
    ((AlienShipAttacker) alienShips.get(50)).attack();
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
  for (int pbIdx = playerBullets.size() - 1; pbIdx >= 0; pbIdx--) {
    PlayerBullet playerBullet = playerBullets.get(pbIdx);

    //Iterate backwards as we may be removing
    for (int i = alienShips.size() - 1; i >= 0; i--) {
      AlienShipBase alienShip = alienShips.get(i);
      float distanceX = abs(alienShip.centreX()-playerBullet.centreX());
      float distanceY = abs(alienShip.centreY()-playerBullet.centreY());
      if (distanceX< collisionThreshold && distanceY<collisionThreshold) {
        alienShip.hit();
        playerBullets.remove(playerBullets.get(pbIdx));
        break;
      }          
    }
    if (playerBullet !=null && playerBullet.outOfScreen()) {
      playerBullets.remove(playerBullets.get(pbIdx));
    }
  }
}
/********* PLAYER *********/
void initPlayer() {
  player = new Player();
  playerController = new PlayerController(player);
}

void initPlayerBullets() {
  playerBullets = new ArrayList<PlayerBullet>();
}

/********* ALIENS *********/
void initAlienArmy() {
  int posY = createBatallion(200, "DEFAULT");
  posY = createBatallion(posY, "ATTACK");
}

int createBatallion(int posY, String shipType){
  int posXMargin=20;
  int posYMargin = 20;
  for (int row = 1; row <= 3; row++) {
    int posX = posXMargin;
    for (int col = 1; col <= 10; col++) {
      if (shipType=="DEFAULT"){
        alienShips.add(new AlienShip(posX, posY));
      } else {
        alienShips.add(new AlienShipAttacker(posX, posY));
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

ArrayList<Integer> YVectors = new ArrayList<Integer>();
  
void alienArmyAttackController(){
  
  for (int i = YVectors.size() - 1; i >= 0; i--) {
    if (YVectors.get(i) == alienShips.get(0).Y){
      float r = random(0, alienShips.size());
      AlienShipBase ship = alienShips.get((int)r);
      if(ship instanceof AlienShipAttacker){
        ((AlienShipAttacker) ship).attack();
        YVectors.remove(i);
      }
    }
  }
}

void drawAlienArmy() {
  //** Alien Ships
  for (int i = alienShips.size() - 1; i >= 0; i--) {
    AlienShipBase alienShip = alienShips.get(i);
    alienShip.move();
    alienShip.draw();
    if (!alienShip.isAlive()) {
      alienShips.remove(i);
    }
        
    // ** Hit Player?
    float distanceX = abs(alienShip.centreX()-player.centreX());
    float distanceY = abs(alienShip.centreY()-player.centreY());
    if (distanceX< playerCollisionThreshold && distanceY<playerCollisionThreshold) {
      player.hit();
    }
  }
}

void alienArmyChangeDirection(char direction) {
  for (AlienShipBase alienShip : alienShips) {
    alienShip.changeDirection(direction);
  }
}

void movePlayerBullet() {
  for (PlayerBullet playerBullet : playerBullets) {
    playerBullet.move();
  }
}

void drawPlayerBullets() {
  for (PlayerBullet playerBullet : playerBullets) {
    playerBullet.draw();
  }
}
