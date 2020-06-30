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
