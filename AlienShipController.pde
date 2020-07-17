class AlienShipController {
  ArrayList<Integer> YVectors = new ArrayList<Integer>();
  ArrayList<AlienShipBase> alienShips;
  Player player;

  AlienShipController(ArrayList<AlienShipBase> alienShips, Player player) {
    this.alienShips=alienShips;
    this.player = player;

    //Points at which to attack
    for (int i=200; i<=320; i=i+5) {
      YVectors.add(i);
    }
  }

  public void guide() {  
    draw();
    for (int i = YVectors.size() - 1; i >= 0; i--) {
      if (YVectors.get(i) == alienShips.get(0).Y) {
        float r = random(0, alienShips.size());
        AlienShipBase ship = alienShips.get((int)r);
        if (ship instanceof AlienShipAttacker) {
          ((AlienShipAttacker) ship).attack(50);
          YVectors.remove(i);
        }
      }
    }
  }
  
  private void draw(){
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

  public int createBatallion(int posY, String shipType) {
    int posXMargin=20;
    int posYMargin = 20;
    for (int row = 1; row <= 3; row++) {
      int posX = posXMargin;
      for (int col = 1; col <= 10; col++) {
        if (shipType=="DEFAULT") {
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
}
