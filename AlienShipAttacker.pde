class AlienShipAttacker extends AlienShipBase {
  
  ArrayList<Point> attackPath;
  int attackPathPos=0;
  ArrayList<Integer> YVectors = new ArrayList<Integer>();

  
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
      Point destination = new Point(gPlayer.X, gPlayer.Y);
      Point leftControl = new Point(gPlayer.X-50, 50);
      Point rightControl = new Point(gPlayer.X+50, 50);      
      attackPath = generateBezierPath(origin, destination, leftControl, rightControl, gPlayer.Y-Y);
      deathOnLanding=false;
    }
  }  
}
