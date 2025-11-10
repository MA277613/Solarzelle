#include <Servo.h>               // Bibliothek für die Steuerung von Servomotoren
#include <Wire.h>                // Bibliothek für I2C-Kommunikation
#include <LiquidCrystal_I2C.h>   // Bibliothek für I2C LCD-Displays

// Definition der Servo-Objekte für horizontale und vertikale Bewegungen
Servo horiz; 
Servo vert;  

// Definition der Pins für Lichtsensoren
const int ldrTopLeft = A1;    // Pin für Lichtsensor oben links   (Kabel Farbe : Gelb)
const int ldrDownLeft = A0;   // Pin für Lichtsensor unten links  (Kabel Farbe : Blau )
const int ldrTopRight = A2;   // Pin für Lichtsensor oben rechts  (Kabel Farbe : Grün )
const int ldrDownRight = A3;  // Pin für Lichtsensor unten rechts (Kabel Farbe : Weiß)

// Toleranz und Zeitverzögerung für die Servosteuerung
const int tolerance = 50; 
const int timeDelay = 5;  

// Initialpositionen der Servos
int horizPos = 90; 
int vertPos = 180;  

// Grenzwerte für die Bewegung der Servos
const int horizMin = 20;
const int horizMax = 160;
const int vertMin = 20;
const int vertMax = 180;

// Initialisierung des LCD-Displays mit Adresse und Größe
LiquidCrystal_I2C lcd(0x27, 20, 4);

void setup() {
  horiz.attach(10);   // Servo für horizontale Bewegung an Pin 10 (Kabel Farbe : Gelb)
  vert.attach(9);     // Servo für vertikale Bewegung an Pin 9    (Kabel Farbe : Orange)
  horiz.write(horizPos);
  vert.write(vertPos);
  delay(2000); // Startverzögerung
  Serial.begin(9600); // Beginn der seriellen Kommunikation

  lcd.init();  // LCD initialisieren
  lcd.backlight(); // Hintergrundbeleuchtung des LCD aktivieren

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Horiz Pos: ");
  lcd.setCursor(0, 1);
  lcd.print("Vert Pos: ");
}


void loop() {
  // Auslesen der Werte von den Lichtsensoren
  int ldrTopLeftVal = analogRead(ldrTopLeft);
  int ldrDownLeftVal = analogRead(ldrDownLeft);
  int ldrTopRightVal = analogRead(ldrTopRight);
  int ldrDownRightVal = analogRead(ldrDownRight);

  // Durchschnittswerte für die Lichtintensitäten berechnen
  int avgTop = (ldrTopLeftVal + ldrTopRightVal) / 2;
  int avgDown = (ldrDownLeftVal + ldrDownRightVal) / 2;
  int avgLeft = (ldrTopLeftVal + ldrDownLeftVal) / 2;
  int avgRight = (ldrTopRightVal + ldrDownRightVal) / 2;

  // Differenzen der Durchschnittswerte bestimmen
  int vertDiff = avgTop - avgDown;
  int horizDiff = avgLeft - avgRight;

  bool updated = false; // Flag, um zu prüfen, ob eine Aktualisierung stattgefunden hat
  
  // Anpassung der Servopositionen basierend auf den Lichtintensitätsunterschieden
  if (abs(horizDiff) > tolerance) {
    if (horizDiff > 0 && horizPos > horizMin) {
      horizPos = max(horizMin, horizPos - 5);
      updated = true;
    } else if (horizDiff < 0 && horizPos < horizMax) {
      horizPos = min(horizMax, horizPos + 5);
      updated = true;
    }
    horiz.write(horizPos);
  }

  if (abs(vertDiff) > tolerance) {
    if (vertDiff > 0 && vertPos > vertMin) {
      vertPos = max(vertMin, vertPos - 3);
      updated = true;
    } else if (vertDiff < 0 && vertPos < vertMax) {
      vertPos = min(vertMax, vertPos + 3);
      updated = true;
    }
    vert.write(vertPos);
  }

  // LCD-Display aktualisieren, wenn eine Änderung erfolgt ist
  if (updated) {
    lcd.setCursor(10, 0);
    lcd.print("     "); // Vorherige Zahl löschen
    lcd.setCursor(10, 0);
    lcd.print(horizPos);
    lcd.setCursor(10, 1);
    lcd.print("     "); // Vorherige Zahl löschen
    lcd.setCursor(10, 1);
    lcd.print(vertPos);
  }

  delay(100); // Kurze Verzögerung zur Stabilisierung des Displays
}








