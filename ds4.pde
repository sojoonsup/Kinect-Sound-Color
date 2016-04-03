import processing.sound.*;
AudioDevice device;
SoundFile[] file;
int numsounds = 5;
int value[] = {0,0,0};

import SimpleOpenNI.*;
SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
PVector com = new PVector();                                   
PVector com2d = new PVector();   

//Graphics
Block[][] blocks;

color[] colors = new color[]{
  color(255,0,0),
  color(255,72,0),
  color(255,157,0),
  color(255,206,0),//4
  color(231,255,0),
  color(175,255,0),
  color(63,255,0),
  color(0,255,139),//8
  color(0,255,255),
  color(0,170,255),
  color(0,92,255),
  color(0,31,255),//12
  color(105,0,255),
  color(174,0,255),
  color(255,0,237),
  color(255,255,255),//16
};

//Syphon Server
import codeanticode.syphon.*;
SyphonServer server;

// Oopen Sound Control
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup()
{
  size(640,480, P3D);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();  
  //Graphics 
   colorMode(RGB, 100);
   //blocks
   blocks = new Block[4][4];
   for (int i = 0; i < 4; i++){
    for (int j = 0; j < 4; j++){
      blocks[i][j] = new Block(i,j);
    } 
  }
  
  //Sound
  device = new AudioDevice(this, 48000, 32);
  file = new SoundFile[numsounds];
  // Load 5 soundfiles from a folder in a for loop. By naming the files 1., 2., 3., n.aif it is easy to iterate
  // through the folder and load all files in one line of code.
  for (int i = 0; i < numsounds; i++){
    file[i] = new SoundFile(this, (i+1) + ".aif");
  }
  
  //Syphon Server
  server = new SyphonServer(this, "Processing Syphon");
  
  //OSC server communication
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",1234);
}



void draw()
{
 background(0);
  // update the cam
  context.update();
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }      
      
    // draw the center of mass
    if(context.getCoM(userList[i],com))
    {
      context.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 5);
        vertex(com2d.x,com2d.y + 5);

        vertex(com2d.x - 5,com2d.y);
        vertex(com2d.x + 5,com2d.y);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userList[i]),com2d.x,com2d.y);
      
//      println("x=" + int(com2d.x) + ',' + " y=" + int(com2d.y) + " z=" + int(com2d.z));
      //generate sound based on position
        file[i].play((com2d.x / (width / 2)), (com2d.z/4500));
//      println ("soundfile_" + int(com2d.y / 128) + " / rate_" + (com2d.x / (height / 4) + " / amp_" + (com2d.z/4500) *2));
    }
  }  //end of forloop
  
  //Graphics
  for (int i = 0; i < 4; i++){
    for (int j = 0; j < 4; j++){
      blocks[i][j].display();
    } 
  }
  //syphon server
  server.sendScreen();
  
  //OSC Send
//  OscMessage myMessage = new OscMessage(int(com2d.y / 128));
//  myMessage.add();
  OscMessage myMessage = new OscMessage("/test");
  myMessage.add(com2d.x/64); /* add an int to the osc message */
  println(com2d.x/128);
  oscP5.send(myMessage, myRemoteLocation); 
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId) 
{
  // to get the 3d joint data
  /*ynn
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


//Graphics
class Block{
  int _x, _y;
  
   Block(int x, int y){
     _x = x;
     _y = y;
   } 
   void display(){
    //need forloop to run if statement for all person's points
     fill(colors[4 * _x + _y], 50);
      
     if(width/4 * _x < mouseX && mouseX < width/4 * (_x + 1)){
       if(height/4 * _y < mouseY && mouseY < height/4 * (_y + 1)){
         
         fill(colors[4 * _x + _y], 100);
         file[_x].amp(5);
         file[_x].rate(_y + 1);
       }
     }
     
     rect(width/4 * _x, height/4 * _y, width/4, height/4);
   }
}
