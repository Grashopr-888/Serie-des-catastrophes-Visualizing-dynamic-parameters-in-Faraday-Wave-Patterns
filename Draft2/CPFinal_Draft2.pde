//Serie des Catastrophes by Trent Eriksen
//Leiden University Media Technology MSc. 2024

import ddf.minim.*;
import ddf.minim.analysis.*;
import controlP5.*;

Minim minim;
AudioPlayer player;
FFT fft;
ControlWindow controlWindow;

float smoothFactor = 0.2;
float[] spectrumSmoothed;

int cols, rows;
int scale = 10;
int w = 1000; // Canvas width
int h = 1000; // Canvas height
float[][] wavePattern;

int catastropheType = 0;
int lastChangeTime = 0;
static int changeInterval = 1000; // Interval to change catastrophe type in milliseconds

String[] audioFiles = {"Melodysbeat_new_alt116.wav"}; // Array of audio file paths
int currentAudioIndex = 0;

ControlP5 cp5;
float knobValue = changeInterval; // This will store the knob's value


void settings() {
  size(w, h, P3D); // Set canvas size
}

void setup() {
  cols = w / scale; // Calculate number of columns
  rows = h / scale; // Calculate number of rows
  wavePattern = new float[cols][rows]; // Initialize wave pattern array

  minim = new Minim(this);
  loadNextAudioFile(); // Load the first audio file

  fft = new FFT(player.bufferSize(), player.sampleRate());
  fft.logAverages(22, 3);
  spectrumSmoothed = new float[fft.avgSize()];
  
     // Start the control window only if it's not already running
  
if (controlWindow == null) {
        String[] args = {"Control Window"};
        controlWindow = new ControlWindow();
        PApplet.runSketch(args, controlWindow);
    }
  
}

void loadNextAudioFile() {
  if (player != null) {
    player.close();
  }
  player = minim.loadFile(audioFiles[currentAudioIndex], 2048);
  player.play();
  
}

void draw() {
background(0);  // Clear the screen  

  if (millis() - lastChangeTime > changeInterval) {
    float rand = random(1);
    if (rand < 0.40) { // 40% chance for Cusp Catastrophe
      catastropheType = 1; // Cusp Catastrophe
    } else if (rand < 0.50) { // 10% chance for Fold Catastrophe
      catastropheType = 0; // Fold Catastrophe
    } else if (rand < 0.70) { // 20% chance for Swallowtail Catastrophe
      catastropheType = 2; // Swallowtail Catastrophe
    } else {
      catastropheType = (int) random(3,7); // 30% chance Randomly select from 3 to 6
    }
    lastChangeTime = millis();
  }

  if (!player.isPlaying()) {
    currentAudioIndex = (currentAudioIndex + 1) % audioFiles.length; // Move to the next audio file
    loadNextAudioFile(); // Load and play the new audio file
  }

  applyCatastrophe(catastropheType);

  fft.forward(player.mix);
  for (int i = 0; i < fft.avgSize(); i++) {
    spectrumSmoothed[i] += (fft.getAvg(i) - spectrumSmoothed[i]) * smoothFactor;
  }

  background(0);
  translate(width / 2, height / 2);
  noFill();
  stroke(186,212,243);
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = (i - cols / 2) * scale;
      float y = (j - rows / 2) * scale;
      float d = dist(x, y, 0, 0);
      int spectrumIndex = min((int) map(d, 0, dist(0, 0, width / 2, height / 2), 0, spectrumSmoothed.length), spectrumSmoothed.length - 1);
      float angle = (sin(d * 0.1 + frameCount * 0.1) + cos(d * 0.1 + frameCount * 0.1)) * (spectrumSmoothed[spectrumIndex] * 2.5 + 10); // Reduced impact to 2.5
      wavePattern[i][j] = angle;
}
}

for (int i = 0; i < cols - 1; i++) {
beginShape(TRIANGLE_STRIP);
for (int j = 0; j < rows; j++) {
vertex((i - cols / 2) * scale, (j - rows / 2) * scale, wavePattern[i][j]);
vertex((i + 1 - cols / 2) * scale, (j - rows / 2) * scale, wavePattern[i + 1][j]);

}
endShape();
}

// Display catastrophe name and formula in 3D
displayCatastropheInfo3D(catastropheType);
// Display Amplitude and Peak Frequency
displayAudioInfo();
// Display Wave Width
displayWaveWidth();

}

void applyCatastrophe(int type) {
float currentTime = millis() * 0.001; // Convert to seconds for convenience
int localScale;
switch (type) {
case 0: // Fold Catastrophe
localScale = (sin(currentTime) > 0) ? 10 : 20;
break;
case 1: // Cusp Catastrophe
localScale = 10 + (int)(sin(currentTime) * 5);
break;
case 2: // Swallowtail Catastrophe
localScale = 10 + (int)(sin(currentTime * 2) * 5);
break;
case 3: // Butterfly Catastrophe
localScale = 20; // Default scale for this case
break;
case 4: // Hyperbolic Umbilic Catastrophe
localScale = 20 + (int)(sin(currentTime) * 5);
break;
case 5: // Elliptic Umbilic Catastrophe
localScale = 20; // Default scale for this case
break;
case 6: // Parabolic Umbilic Catastrophe
localScale = 20 + (int)(sin(currentTime) * 5);
break;
default:
localScale = 20; // Default scale
break;
}
// Update global scale variable
scale = localScale;
}

void displayCatastropheInfo3D(int type) {
String catastropheName;
String formula;

// Determine the name and formula based on the catastrophe type
switch (type) {
case 0:
catastropheName = "Fold";
formula = "f(x) = x^3";
break;
case 1:
catastropheName = "Cusp";
formula = "f(x, y) = x^4 + y^2";
break;
case 2:
catastropheName = "Swallowtail";
formula = "f(x) = x^5";
break;
case 3:
catastropheName = "Butterfly";
formula = "f(x) = x^6";
break;
case 4:
catastropheName = "Hyperbolic Umbilic";
formula = "f(x, y, z) = x^3 + y^3 + z^2";
break;
case 5:
catastropheName = "Elliptic Umbilic";
formula = "f(x, y, z) = x^3 - 3xy^2 + z^2";
break;
case 6:
catastropheName = "Parabolic Umbilic";
formula = "f(x, y, z) = x^2y + y^4 + z^2";
break;
default:
catastropheName = "Unknown";
formula = "";
break;
}

// Set text properties for catastrophe info
textSize(32);
fill(255);
textAlign(CENTER, CENTER);

// Translate to the center for text rendering
pushMatrix();
translate(0, 0, 50); // Bring text slightly towards the viewer
text(catastropheName, 0, -20);
text(formula, 0, 20);
popMatrix();
}

//Audio info calculations
void displayAudioInfo() {
float peakFrequency = 0;
float maxAmplitude = 0;
for (int i = 0; i < fft.specSize(); i++) {
if (fft.getBand(i) > maxAmplitude) {
maxAmplitude = fft.getBand(i);
peakFrequency = fft.indexToFreq(i);
}
}

float amplitudeDb = 20 * (float)Math.log10(maxAmplitude);

// Set text properties for audio info
textSize(26);
fill(255);
textAlign(CENTER, BOTTOM);

// Translate for audio info rendering
pushMatrix();
translate(0, height / 2.5, 50); // Position for audio info
text("Amplitude: " + nf(amplitudeDb, 2, 2) + " dB", 0, -20);
text("Frequency: " + nf(peakFrequency, 0, 2) + " Hz", 0, 20);
popMatrix();
}

void displayWaveWidth() {
  int waveWidth = cols * scale; // Calculate the current width of the wave field in pixels

  textSize(26);
  fill(255);
  textAlign(CENTER, BOTTOM);

  pushMatrix();
  translate(0, height / 2.5, 50);
  text("Diameter: " + waveWidth + " px", 0, 60); // Position below the Frequency text
  popMatrix();
}

public class ControlWindow extends PApplet {

    ControlP5 cp5;
    public int changeInterval = 1000; // Interval in milliseconds

    public void settings() {
        size(300, 200);
    }

    public void setup() {
        cp5 = new ControlP5(this);
        cp5.addKnob("changeInterval")
           .setRange(10, 5000)
           .setValue(changeInterval)
           .setPosition(50, 50)
           .setRadius(40)
           .setNumberOfTickMarks(10)
           .setTickMarkLength(4)
           .snapToTickMarks(false)
           .setLabel("Interval");
    }

    public void draw() {
        background(200);
        fill(0);
        text("Change Interval: " + changeInterval, 150, 100);
         CPFinal_Draft2.changeInterval = (int) cp5.getController("changeInterval").getValue();

    }
}
  
void stop() {
player.close();
minim.stop();
super.stop();
}
