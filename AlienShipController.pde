class AlienShipController {
  ArrayList<Integer> YVectors = new ArrayList<Integer>();
  ArrayList<AlienShipBase> alienShips;

  AlienShipController(ArrayList<AlienShipBase> alienShips) {
    this.alienShips=alienShips;

    //Points at which to attack
    for (int i=200; i<=320; i=i+5) {
      YVectors.add(i);
    }
  }

  public void guide() {  
    for (int i = YVectors.size() - 1; i >= 0; i--) {
      if (YVectors.get(i) == alienShips.get(0).Y) {
        float r = random(0, alienShips.size());
        AlienShipBase ship = alienShips.get((int)r);
        if (ship instanceof AlienShipAttacker) {
          ((AlienShipAttacker) ship).attack();
          YVectors.remove(i);
        }
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
