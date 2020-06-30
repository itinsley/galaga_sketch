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
AlienShip alienShip;
ArrayList<AlienShipBase> alienShips;
Minim minim;
AudioPlayer audioPlayer;
PImage playerImage;
PImage bulletImage;
PImage alienShipImageDefault;
PImage alienShipAttackerImageDefault;
PImage alienExplosion1Image;
PImage alienExplosion2Image;
PImage alienExplosion3Image;
PImage playerExplosionImage1;
PImage playerExplosionImage2;
PImage playerExplosionImage3;
PImage playerExplosionImage4;

AudioPlayer bulletSound;
AudioPlayer killSound;
AudioPlayer playerDeathSound;


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
  
  PImage currentImage(){
    return imageSequence.get(eventStep);
  }

  float centreX() {
    return (playerImage.width/2)+X;
  }

  float centreY() {
    return (playerImage.height/2)+Y;
  }

  void shoot() {
    if (playerBullets.size()<=BULLETS_LIMIT) {
      playerBullets.add(new PlayerBullet(X+6, Y-8));
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
  
  void draw(){
    image(currentImage(), X, Y);
    //Move to next image if there is more than one image in sequence
    if (imageSequence.size()>1){
      if (eventStep>=3){
        //Only event in town is the explosion
        gameScreen="GAMEOVER";
      }
      eventStep++;
    }
  }
};

class PlayerController{
  Player player;
  boolean isLeft;
  boolean isRight;
  char directionDefault;
  
  PlayerController(Player player){
    this.player = player;
  }
  
  void leftKeyPressed(){
    isLeft=true;
    directionDefault='r';
  }
  void leftKeyReleased(){
    isLeft=false;
    directionDefault='l';
  }
  void rightDown(){
    isRight=true;  
  }
  void rightUp(){
    isRight=false;
  }
  void move(){
    if(isLeft && isRight){
      player.move(directionDefault);    
    }else if (isLeft && !isRight) {
      player.move('l');
    }else if (!isLeft && isRight) {
      player.move('r');
    }
  }
}


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

class AlienShip extends AlienShipBase {
  AlienShip(int x, int y) {
    super(x, y, alienShipImageDefault);
  }
}
class AlienShipAttacker extends AlienShipBase {
  
  ArrayList<Point> attackPath;
  int attackPathPos=0;
  
  AlienShipAttacker(int x, int y) {
    super(x, y, alienShipAttackerImageDefault);
  }
  
  void move() {
    if (attackPath==null){
      super.move();
    } else {
      checkWall();
      if (attackPathPos>=attackPath.size()){
        attackPath=null;
      } else{
        Point point = attackPath.get(attackPathPos);
        Y=(int)point.getY();
        X=(int)point.getX();
        attackPathPos++;
      }
    }
  }
    
  void attack(){
    if (attackPath==null){
      Point origin = new Point(X,Y);
      Point destination = new Point(player.X, player.Y);
      Point leftControl = new Point(player.X-50, 50);
      Point rightControl = new Point(player.X+50, 50);      
      attackPath = generateBezierPath(origin, destination, leftControl, rightControl, player.Y-Y);
      deathOnLanding=false;
    }
  }  
}

class AlienShipBase {
  int X;
  int Y;
  int descent=1;
  int descentCounter;
  int descentRate=3;
  boolean deathOnLanding=true;

  char direction='r';
  int currentEvent=0;
  boolean isAlive=true;

  int eventStep=0;
  PImage defaultImage;
  ArrayList<PImage>imageSequence;
  
  AlienShipBase(int x, int y, PImage defaultImage) {
    this.defaultImage = defaultImage;
    imageSequence = new ArrayList<PImage>(); 
    imageSequence.add(this.defaultImage);
    eventStep=0;
    X=x;
    Y=y;
  }
  
  boolean deathOnLanding(){
    return deathOnLanding;
  }
  
  void hit() {
    killSound.play();    
    score=score+1; //Shouldn't be updating globals here
    imageSequence = new ArrayList<PImage>();
    imageSequence.add(alienExplosion1Image);
    imageSequence.add(alienExplosion2Image);
    imageSequence.add(alienExplosion3Image);
    eventStep=0;
  }
  PImage currentImage(){
    return imageSequence.get(eventStep);
  }
  float centreX() {
    return (currentImage().width/2)+X;
  }

  float centreY() {
    return (currentImage().height/2)+Y;
  }

  boolean isAlive() {
    return isAlive;
  }

  void draw() {
    image(currentImage(), X, Y);
    //Move to next image if there is more than one image in sequence
    if (imageSequence.size()>1){      
      eventStep++;
      if(eventStep<=1){
        isAlive=false;
      }
    }
  }

  void checkWall() {
    if (X>screenSize-currentImage().width) {
      alienArmyChangeDirection('l');
    } 
    if (X<0+currentImage().width) {
      alienArmyChangeDirection('r');
    }
    if (Y>=GROUND_LEVEL_Y){
      if (this.deathOnLanding()==true){
        player.hit();
      } else {
        isAlive=false;
      }
    }    
  }

  void move() {
    checkWall();
    if (direction=='r') {
      X=X+1;
    } else {
      X=X-1;
    }

    if (descentCounter>=descentRate) {
      Y=Y+descent;
      descentCounter=0;
    }
    descentCounter++;
  }

  void changeDirection(char direction) {
    this.direction = direction;
  }
  
  void debug(){
    println("DEBUG:");
    println("eventStep:"+eventStep);
    println("SequenceSize:"+imageSequence.size());
    println("Event:"+currentEvent);
  }
};

/********* SETUP BLOCK *********/

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

class Point{
  double x;
  double y;
  Point(){};
  Point(double x, double y){
    this.x=x;
    this.y=y;
  }
  public void setX(double x){this.x = x;}
  public void setY(double y){this.y = y;}
  public double getX(){return this.x;}
  public double getY(){return this.y;}
}

ArrayList<Point> generateBezierPath(Point origin, Point destination, Point control1, Point control2, int segments) {
    ArrayList<Point> pointsForReturn = new ArrayList<Point>();

    float t = 0;
    for (int i = 0; i < segments; i++) {
        Point p = new Point();
        p.setX(Math.pow(1 - t, 3) * origin.x + 3.0f * Math.pow(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x);
        p.setY(Math.pow(1 - t, 3) * origin.y + 3.0f * Math.pow(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y);
        t += 1.0f / segments;
        pointsForReturn.add(p);
    }
    pointsForReturn.add(destination);
    return pointsForReturn;
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
