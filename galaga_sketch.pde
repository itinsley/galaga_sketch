/********* VARIABLES *********/
int screenSize = 500;
int playerX = 242;
int playerY = 483;
char playerDirection;


// We control which screen is active by settings / updating
// gameScreen variable. We display the correct screen according
// to the value of this variable.
//
// 0: Initial Screen
// 1: Game Screen
// 2: Game-over Screen

int gameScreen = 0;

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
  movePlayer();
}

/********* INPUTS *********/
void keyPressed() {
   if (key=='a'||key=='A'){
     playerDirection='l';
   };
  if (key=='d'||key=='D'){
     playerDirection='r';
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

void movePlayer(){
  if (playerDirection=='l'){
    playerX=playerX-3;
  } 
  if (playerDirection=='r'){
    playerX=playerX+3;
  } 
}
