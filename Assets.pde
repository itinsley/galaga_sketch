PImage playerImage;
PImage bulletImage;
PImage alienShipImageDefault;
PImage alienShipAttackerImageDefault;
PImage alienExplosion1Image;
PImage alienExplosion2Image;
PImage alienExplosion3Image;
PImage playerExplosionImage1;
PImage playerExplosionImage2;
PImage playerExplosionImage3;
PImage playerExplosionImage4;

AudioPlayer bulletSound;
AudioPlayer killSound;
AudioPlayer playerDeathSound;

void loadAssets(){
  gMinim = new Minim(this);  
  bulletSound = gMinim.loadFile("sound/8d82b5_Galaga_Firing_Sound_Effect.mp3");    
  killSound = gMinim.loadFile("sound/8d82b5_Galaga_Kill_Enemy_Sound_Effect.mp3");
  playerDeathSound = gMinim.loadFile("sound/player-explosion.wav");
  bulletImage = loadImage("graphics/player-bullet.png");
  playerImage = loadImage("graphics/galaga-player-ship.png");
  alienShipImageDefault = loadImage("graphics/alien-ship.png");
  alienShipAttackerImageDefault = loadImage("graphics/alien-ship-attacker.png");
  alienExplosion1Image = loadImage("graphics/alien-explosion-1.png");
  alienExplosion2Image = loadImage("graphics/alien-explosion-2.png");
  alienExplosion3Image = loadImage("graphics/alien-explosion-3.png");
  playerExplosionImage1 = loadImage("graphics/galaga-player-ship-explosion-1.png");
  playerExplosionImage2 = loadImage("graphics/galaga-player-ship-explosion-2.png");
  playerExplosionImage3 = loadImage("graphics/galaga-player-ship-explosion-3.png");
  playerExplosionImage4 = loadImage("graphics/galaga-player-ship-explosion-4.png");
}
