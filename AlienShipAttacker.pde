class AlienShipAttacker extends AlienShipBase {

  ArrayList<Point> attackPath;
  int attackPathPos=0;
  ArrayList<Integer> YVectors = new ArrayList<Integer>();


  AlienShipAttacker(int x, int y) {
    super(x, y, alienShipAttackerImageDefault);
  }
  void draw(){
    int REATTACK_Y=50;
    if (gPlayer.Y-Y==REATTACK_Y){
      gPlayer.Y++;
      attack(20, true);
    } 
    super.draw();
  } 
  void move() {
    if (attackPath==null) {
      super.move();
    } else {
      checkWall();
      if (attackPathPos>=attackPath.size()) {
        attackPath=null;
      } else {
        Point point = attackPath.get(attackPathPos);
        Y=(int)point.getY();
        X=(int)point.getX();
        attackPathPos++;
      }
    }
  }

  void attack(int offset) {
    attack(offset, false);
  }
  void attack(int offset, boolean reset) {
    if (attackPath==null || reset) {
      int PLAYER_CLEARANCE = 20  ;
      float r = random(0, gPlayer.Y-PLAYER_CLEARANCE);
      Point origin = new Point(X, Y);
      Point destination = new Point(gPlayer.X, gPlayer.Y);
      Point leftControl = new Point(X-offset, r);
      Point rightControl = new Point(X+offset, r);         
      int attackSpeedMultiplier =(int) random(1,5); 
      attackPath = generateBezierPath(origin, destination, leftControl, rightControl, (gPlayer.Y-Y)/attackSpeedMultiplier);
      attackPathPos = 0;
      deathOnLanding=false;
    }
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
  
}
