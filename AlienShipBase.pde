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
