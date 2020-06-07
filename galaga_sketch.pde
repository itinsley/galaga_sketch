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

  PlayerBullet(int x, int y){
    img = loadImage("graphics/player-bullet.png");      
    X=x;
    Y=y;
  }
  
  void draw(){
    image(img,X,Y);
  }
  
  void move(){
    Y=Y-velocity;
  }
};

class AlienShip {
  PImage img;  
  int X;
  int Y;
  int gravity=1;
  char direction='r';

  AlienShip(int x, int y){
    img = loadImage("graphics/alien-ship.png");      
    X=x;
    Y=y;
  }
  
  void draw(){
    image(img,X,Y);
  }
  
  void checkWall(){
    if (X>screenSize-img.width){
      println("Wall!");
      direction='l';
    }
  }
  
  void move(){
    checkWall();
    if (direction=='r'){
      X=X+1;
    }else{
      X=X-1;
    }
    Y=Y+gravity;
  }
};

/********* SETUP BLOCK *********/

void setup() {
  size(500, 500);
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
}

/********* INPUTS *********/
void keyPressed() {
   if (key=='a'||key=='A'){
     playerDirection='l';
   };
  if (key=='d'||key=='D'){
     playerDirection='r';
  }   
  if (key==' '){
     playerShoot();
  }   
}
void keyReleased() {
   if ((key=='a'||key=='A') && playerDirection=='l'){
     playerDirection=' ';
   } 
   if ((key=='d'||key=='D') && playerDirection=='r'){
     playerDirection=' ';
   } 
}

/********* ALIENS *********/
void initAlienArmy(){
  alienShips = new ArrayList<AlienShip>();
  alienShips.add(alienShip = new AlienShip(250, 10));
}

void drawAlienArmy(){ 
  for (AlienShip alienShip : alienShips) {
    alienShip.move();
    alienShip.draw();
  }
}

/********* PLAYER *********/
void drawPlayer(){
  PImage img; 
  img = loadImage("graphics/galaga-player-ship.png");
  image(img,playerX,playerY);
}

void playerShoot(){
  playerBullet = new PlayerBullet(playerX+6, playerY-15);
}

void movePlayer(){
  if (playerDirection=='l'){
    playerX=playerX-3;
  } 
  if (playerDirection=='r'){
    playerX=playerX+3;
  } 
}

void movePlayerBullet(){
  if (playerBullet !=null){
    playerBullet.move();
  }
}

void drawPlayerBullet(){
  if (playerBullet !=null){
    playerBullet.draw();
  }
}
