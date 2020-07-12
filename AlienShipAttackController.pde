class AlienShipAttackController{
  ArrayList<Integer> YVectors = new ArrayList<Integer>();
  
  AlienShipAttackController(){
    for(int i=200;i<=320;i=i+5){
      YVectors.add(i);
    }    
  }
  
  public void GuideAttack(ArrayList<AlienShipBase> alienShips){  
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


}
