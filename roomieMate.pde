import TUIO.*;
import processing.video.*;
import java.util.Timer;
import java.util.TimerTask;

TuioProcessing tuioClient;
Capture cam;
boolean[][] hover;

int gridSize = 4;
float cellSize;
color bgColor = color(0, 0, 0);
color lineColor = color(255, 255, 255);
color progressBarEmpty = color(200, 200, 200);
color progressBarLoading = color(255, 165, 0);
color progressBarFull = color(0, 255, 0);
color cellFilledColor = color(200, 255, 200);
color fiducialColor = color(50, 50, 50);

float[][] progress;
boolean[][] filled;
float[][] filledTime;

void setup() {
  size(400,400);
  surface.setResizable(true);
  cam = new Capture(this, width, height, 30);
  cam.start();
  tuioClient = new TuioProcessing(this);
  
  progress = new float[gridSize][gridSize];
  filled = new boolean[gridSize][gridSize];
  hover = new boolean[gridSize][gridSize];
  filledTime = new float[gridSize][gridSize];
}

void draw() {
  cellSize = min((float) width / gridSize, (float) height / gridSize);
  background(bgColor);
  drawGrid();

  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      if (hover[i][j] && !filled[i][j]) {
        progress[i][j] += 1.0/60;
        if (progress[i][j] >= 3) {
          filled[i][j] = true;
          filledTime[i][j] = millis();
        }
      } else if (!hover[i][j] && !filled[i][j]) {
        progress[i][j] = max(0, progress[i][j] - 1.0/60);
      }

      if (filled[i][j]) {
        float timeSinceFilled = (millis() - filledTime[i][j]) / 1000.0;
        if (timeSinceFilled <= 2) {
          drawCellBackground(i, j, cellFilledColor);
          drawProgressBar(i, j, progressBarFull, 255 - map(timeSinceFilled, 0, 2, 0, 255));
        } else {
          drawCellBackground(i, j, cellFilledColor);
        }
      } else {
        drawProgressBar(i, j, progress[i][j] > 0 ? progressBarLoading : progressBarEmpty, 255);
      }
    }
  }
}

void drawGrid() {
  stroke(lineColor);
  strokeWeight(1);
  for (int i = 1; i < gridSize; i++) {
    line(i * cellSize, 0, i * cellSize, gridSize * cellSize);
    line(0, i * cellSize, gridSize * cellSize, i * cellSize);
  }
}

void drawCellBackground(int i, int j, color c) {
  fill(c);
  noStroke();
  rect(i * cellSize, j * cellSize, cellSize, cellSize);
}

void drawProgressBar(int i, int j, color c, float alpha) {
  float angle = filled[i][j] ? TWO_PI : map(progress[i][j], 0, 3, 0, TWO_PI);

  pushMatrix();
  translate((i + 0.5) * cellSize, (j + 0.5) * cellSize);
  stroke(c, alpha);
  strokeWeight(2);
  noFill();
  arc(0, 0, cellSize * 0.7, cellSize * 0.7, -HALF_PI, angle - HALF_PI);
  popMatrix();
}

// TUIO event callbacks
void addTuioObject(TuioObject tobj) {
  println("add object "+tobj.getSymbolID()+" "+tobj.getSessionID()+" "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngleDegrees());
}

void updateTuioObject(TuioObject tobj) {
  int x = (int)(tobj.getX() * width);
  int y = (int)(tobj.getY() * height);

  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      hover[i][j] = x > i * cellSize && x < (i + 1) * cellSize && y > j * cellSize && y < (j + 1) * cellSize;
    }
  }

  fill(fiducialColor);
  noStroke();
  ellipse(x, y, 5, 5);
}

void removeTuioObject(TuioObject tobj) {
  println("remove object "+tobj.getSymbolID()+" "+tobj.getSessionID());
}

void addTuioCursor(TuioCursor tcur) {
}

void updateTuioCursor(TuioCursor tcur) {
}

void removeTuioCursor(TuioCursor tcur) {
}

void keyPressed() {
  if (key == ' ') {
    delay(1000);
  }
}
