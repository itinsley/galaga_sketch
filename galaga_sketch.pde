import ddf.minim.*;

/********* VARIABLES *********/
int screenSize = 500;
int score=0;
Player player;
char playerDirection;
ArrayList<PlayerBullet> playerBullets;
AlienShip alienShip;
ArrayList<AlienShip> alienShips;
Minim minim;
AudioPlayer audioPlayer;
PImage playerImage;
PImage bulletImage;
PImage alienShipImageDefault;
PImage alienExplosion1Image;
PImage alienExplosion2Image;
PImage alienExplosion3Image;

AudioPlayer bulletSound;
AudioPlayer killSound;

class Player {
  int X = 242;
  int Y = 483;
  int velocity=4;

  Player() {
    image(playerImage, X, Y);
  }
  
  float centreX() {
    return (playerImage.width/2)+X;
  }

  float centreY() {
    return (playerImage.height/2)+Y;
  }
  
  void shoot() {
    if (playerBullets.size()<=5){
      playerBullets.add(new PlayerBullet(X+6, Y-8));
    }
  }

  void move(char direction){
    if (direction=='l') {
      X=X-velocity;
    } 
    if (direction=='r') {
      X=X+velocity;
    }    
  }
  void draw() {
    image(playerImage, X, Y);
  }
};



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
  
  boolean outOfScreen(){
    return Y<=0;
  }
  void draw() {
    image(bulletImage, X, Y);
  }

  void move() {
    Y=Y-velocity;
  }
};

class AlienShip {
  int X;
  int Y;
  int descent=1;
  int descentCounter;
  int descentRate=2;
  
  char direction='r';
  int explosionStep=0;
  PImage alienShipImage;

  AlienShip(int x, int y) {
    alienShipImage = alienShipImageDefault;
    X=x;
    Y=y;
  }

  void hit() {
    explosionStep=1;
    score=score+1; //Shouldn't be updating globals here
  }
  float centreX() {
    return (alienShipImage.width/2)+X;
  }

  float centreY() {
    return (alienShipImage.height/2)+Y;
  }

  void drawExplosion() {
    switch(explosionStep) {
    case 1: 
      alienShipImage = alienExplosion1Image;
      killSound.play();    
      explosionStep++;
      break;
    case 2:
      alienShipImage = alienExplosion2Image;
      explosionStep++;
      break;
    case 3:
      alienShipImage = alienExplosion3Image;
      explosionStep++;
      break;
    case 4:
      //Wait a cycle
      explosionStep++;
      break;
    default:
      alienShipImage = alienShipImageDefault; //Return to default just for now.
      explosionStep=0;
      break;
    }
  }

  boolean isAlive() {
    return(explosionStep<4);
  }

  void draw() {
    image(alienShipImage, X, Y);
    drawExplosion();
  }

  void checkWall() {
    println(X, screenSize-alienShipImage.width, direction);
    if (X>screenSize-alienShipImage.width) {
      alienArmyChangeDirection('l');
    } 
    if (X<0+alienShipImage.width) {
      alienArmyChangeDirection('r');
    }
  }

  void move() {
    checkWall();
    if (direction=='r') {
      X=X+1;
    } else {
      X=X-1;
    }
    
    if (descentCounter>=descentRate){
      Y=Y+descent;
      descentCounter=0;
    }
    descentCounter++;    
  }
  
  void changeDirection(char direction){
    this.direction = direction;
  }
};

/********* SETUP BLOCK *********/

void setup() {
  bulletImage = loadImage("graphics/player-bullet.png");
  playerImage = loadImage("graphics/galaga-player-ship.png");
  alienShipImageDefault = loadImage("graphics/alien-ship.png");
  alienExplosion1Image = loadImage("graphics/alien-explosion-1.png");
  alienExplosion2Image = loadImage("graphics/alien-explosion-2.png");
  alienExplosion3Image = loadImage("graphics/alien-explosion-3.png");
    
  minim = new Minim(this);  
  bulletSound = minim.loadFile("sound/8d82b5_Galaga_Firing_Sound_Effect.mp3");    
  killSound = minim.loadFile("sound/8d82b5_Galaga_Kill_Enemy_Sound_Effect.mp3");
 
  size(500, 500);
  frameRate(40);
  initAlienArmy();
  initPlayer();
  initPlayerBullets();
  score=0;
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
  audioPlayer.play();
}
void gameScreen() {
  background(0);
  textAlign(LEFT);
  text("SCORE: "+score, 10, 10);
  player.move(playerDirection);
  player.draw();
  drawPlayerBullets();
  drawAlienArmy();
  movePlayerBullet();
  detectCollision();
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
  if (gameScreen=="GAMEOVER" && key!='q' && key!='Q'){
    return; 
  }
  gameScreen="START";
   
  if (key=='a'||key=='A') {
    playerDirection='l';
  };
  if (key=='d'||key=='D') {
    playerDirection='r';
  }   
  if (key==' ') {
    player.shoot();
  }
  if (key=='q'||key=='Q') {
    setup();
  }
  
  if (key=='x'||key=='X') {
     //debug
  }
  
  
}

//Slight bug in here when keys are pressed at the same time
void keyReleased() {
  if ((key=='a'||key=='A')&& playerDirection=='l'){
    playerDirection=' ';
  } 
  if ((key=='d'||key=='D')&& playerDirection=='r'){
    playerDirection=' ';
  } 
}

/********* COLLISIONS *********/
void detectCollision() {
  int collisionThreshold=5;
  int playerCollisionThreshold=15;
  
  //** Bullets **
  //Iterate backwards as we may be removing
  for (int pbIdx = playerBullets.size() - 1; pbIdx >= 0; pbIdx--) {
    PlayerBullet playerBullet = playerBullets.get(pbIdx);

    //Iterate backwards as we may be removing
    for (int i = alienShips.size() - 1; i >= 0; i--) {
      AlienShip alienShip = alienShips.get(i);
      float distanceX = abs(alienShip.centreX()-playerBullet.centreX());
      float distanceY = abs(alienShip.centreY()-playerBullet.centreY());
      if (distanceX< collisionThreshold && distanceY<collisionThreshold) {
        alienShip.hit();
        break;          
      }
      if (!alienShip.isAlive()) {
        alienShips.remove(i);
        playerBullets.remove(playerBullets.get(pbIdx));
      }
    }
    if (playerBullet !=null && playerBullet.outOfScreen()){
      playerBullet=null;
      playerBullets.remove(playerBullets.get(pbIdx));
    }
  }
  
  //** Alien Ships
  for (int i = alienShips.size() - 1; i >= 0; i--) {
    AlienShip alienShip = alienShips.get(i);
    // ** Hit Player?
    float distanceX = abs(alienShip.centreX()-player.centreX());
    float distanceY = abs(alienShip.centreY()-player.centreY());
    if (distanceX< playerCollisionThreshold && distanceY<playerCollisionThreshold) {
      gameScreen="GAMEOVER";
      break;
    }
  }

  
  
}
/********* PLAYER *********/
void initPlayer() {
  player = new Player();
}

void initPlayerBullets(){
  playerBullets = new ArrayList<PlayerBullet>();
}

/********* ALIENS *********/
void initAlienArmy() {
  alienShips = new ArrayList<AlienShip>();
  int posXMargin=20;
  int posYMargin = 20;
  int posY = posYMargin;
  for (int row = 1; row <= 3 ; row++) {
    int posX = posXMargin;
    for (int col = 1; col <= 10 ; col++) {
      alienShips.add(alienShip = new AlienShip(posX, posY));
      posX = posX + posXMargin;
    }
    posY=posY+posYMargin;
  }
}

void drawAlienArmy() { 
  for (AlienShip alienShip : alienShips) {
    alienShip.move();
    alienShip.draw();
  }
}

void alienArmyChangeDirection(char direction){
  for (AlienShip alienShip : alienShips) {
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
