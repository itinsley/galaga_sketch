import ddf.minim.*;

/********* VARIABLES *********/
int screenSize = 500;
int score=0;
Player player;
ArrayList<PlayerBullet> playerBullets;
AlienShip alienShip;
ArrayList<AlienShip> alienShips;
Minim minim;
AudioPlayer audioPlayer;


class Player {
  PImage img;
  int X = 242;
  int Y = 483;
  int initialVelocity=4;
  int velocity=initialVelocity;
  char direction;

  Player() {
    img = loadImage("graphics/galaga-player-ship.png");
    image(img, X, Y);
  }

  void shoot() {
    if (playerBullets.size()<=5){
      playerBullets.add(new PlayerBullet(X+6, Y-8));
    }
  }

  // ********Movement***********
  // Use a velocity so that movement is maintained when keys are held down
  void moveLeft(){
    velocity=initialVelocity;
    direction='l';
  }
  
  void moveRight(){
    velocity=initialVelocity;
    direction='r';
  }

  void stop(){
    velocity=0;
  }
 
  void draw() {
    if (direction=='l') {
      X=X-velocity;
    } 
    if (player.direction=='r') {
      X=X+velocity;
    }
    image(img, X, Y);
  }
};



class PlayerBullet {
  PImage img;
  int X;
  int Y;
  int velocity=5;

  PlayerBullet(int x, int y) {
    img = loadImage("graphics/player-bullet.png");
    audioPlayer = minim.loadFile("sound/8d82b5_Galaga_Firing_Sound_Effect.mp3");
    audioPlayer.play();
      
    X=x;
    Y=y;
  }

  float centreX() {
    return (img.width/2)+X;
  }

  float centreY() {
    return (img.height/2)+Y;
  }
  
  boolean outOfScreen(){
    return Y<=0;
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
    score=score+1; //Shouldn't be updating globals here
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
      audioPlayer = minim.loadFile("sound/8d82b5_Galaga_Kill_Enemy_Sound_Effect.mp3");
      audioPlayer.play();    
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
  }
}
void initScreen() {
  background(0);
  textAlign(CENTER);
  text("Any key to start", width/2, height/2);
  text("Q to restart", width/2, height/2+50);
  text("A = Move Left | D= Move Right | SPACE=Fire", width/2, height/2+100);
  minim = new Minim(this);
  audioPlayer = minim.loadFile("sound/8d82b5_Galaga_Theme_Song.mp3");
  audioPlayer.play();
}
void gameScreen() {
  background(0);
  textAlign(LEFT);
  text("SCORE: "+score, 10, 10);
  player.draw();
  drawPlayerBullets();
  drawAlienArmy();
  movePlayerBullet();
  detectCollision();
}

/********* INPUTS *********/
void keyPressed() {
   gameScreen="START";
  if (key=='a'||key=='A') {
    player.moveLeft();
  };
  if (key=='d'||key=='D') {
    player.moveRight();
  }   
  if (key==' ') {
    player.shoot();
  }
  if (key=='q'||key=='Q') {
    setup();
  }
}

//Slight bug in here when keys are pressed at the same time
void keyReleased() {
  if (key=='a'||key=='A'||key=='d'||key=='D') {
    player.stop();
  } 
}

/********* COLLISSIONS *********/
void detectCollision() {
  int collisionThreshold=5;
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
      }
      if (!alienShip.isAlive()) {
        alienShips.remove(i);
      }
    }
    if (playerBullet.outOfScreen()){
      playerBullets.remove(playerBullet);
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
