/********* VARIABLES *********/
int screenSize = 500;
int playerX = 242;
int playerY = 483;
char playerDirection;
PlayerBullet playerBullet;

class PlayerBullet {
  PImage img;  // Declare a variable of type PImage
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

/********* SETUP BLOCK *********/

void setup() {
  size(500, 500);
}


/********* DRAW BLOCK *********/

void draw() {
  gameScreen();  
}

void gameScreen() {
  background(0);
  drawPlayer();
  drawPlayerBullet();
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

/********* PLAYER *********/
void drawPlayer(){
  PImage img;  // Declare a variable of type PImage
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
