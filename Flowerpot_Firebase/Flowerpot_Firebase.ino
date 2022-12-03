/*
1. 환경설정 -> 보드 매니저 -> https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_dev_index.json입력
2. Tools -> 보드 -> 보드 매니저 -> ESP32 검색 후, install
3. Tools -> 보드 -> esp32 -> ESP32 Dev Module 선택
4. Sketch -> Include Library -> Manage Libraries -> Firebase 검색
5. Firebase ESP32 Client by Mobizt 설치

*/
#if defined(ESP32)
#include <WiFi.h>
#include <FirebaseESP32.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#endif

// Provide the token generation process info.
#include <addons/TokenHelper.h>

// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "EAI-402"
#define WIFI_PASSWORD "lab402-1"

// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

/* 2. Define the API Key */
#define API_KEY "AIzaSyBizaUwKHiKztwwTOXKAPyPpF1GLKfOSoo"

/* 3. Define the RTDB URL */
#define DATABASE_URL "https://fir-test-158a3-default-rtdb.asia-southeast1.firebasedatabase.app/"  //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "16615028@konyang.ac.kr"
#define USER_PASSWORD "Eh4312741004@"

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

bool taskCompleted = false;


#define PUMP_PIN 27
#define R_PIN 13
#define G_PIN 12
#define B_PIN 14
#define HUMI_PIN 33
#define LEVEL_PIN 32

void setup() {

  Serial.begin(115200);
  Serial.println();
  Serial.println();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  config.api_key = API_KEY;

  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;  // see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  pinMode(PUMP_PIN, OUTPUT);
  pinMode(R_PIN, OUTPUT);
  pinMode(G_PIN, OUTPUT);
  pinMode(B_PIN, OUTPUT);
  digitalWrite(PUMP_PIN, 0);
  digitalWrite(R_PIN, 0);
  digitalWrite(G_PIN, 0);
  digitalWrite(B_PIN, 0);
}


#define THRESHOLD 0.3
void loop() {
  static float humi = 0.0;
  static float level = 0.0;
  static int pump = 0;
  humi = float(map(analogRead(HUMI_PIN), 0, 4095, 0, 100)) / 100.0;
  level = float(map(analogRead(LEVEL_PIN), 0, 4095, 0, 100)) / 100.0;


  static unsigned long getInterval = 0;
  if (millis() - getInterval > 1000 * 1 || getInterval == 0) {
    static bool flag = true;
    getInterval = millis();
    pump = getData();
    if (pump == 1 && flag == true) {
      Serial.println(humi);
      Serial.println(pump);
      sendData(humi, pump);
      current(humi, level);
      setPump(pump);
      digitalWrite(PUMP_PIN, pump);
      flag = false;
    }
    if (pump == 0) {
      digitalWrite(PUMP_PIN, pump);
      flag = true;
    }
  }

  static unsigned long sendInterval = 0;
  if (millis() - sendInterval > 1000 * 60 * 10 || sendInterval == 0) {
    sendInterval = millis();
    sendData(humi, pump);
  }

  static unsigned long currentInterval = 0;
  if (millis() - currentInterval > 1000 * 2 || currentInterval == 0) {
    currentInterval = millis();
    humi += 0.1;
    level += 0.1;
    current(humi, level);
  }


  static unsigned auto_pumping_interval = 0;

  if (humi <= 1) {  //  자동 급수
    static bool flag = true;
    if (humi <= THRESHOLD && flag == true) {
      pump = 1;
      Serial.println("auto pump on");
      digitalWrite(PUMP_PIN, pump);
      //      setPump(pump);
      sendData(humi, pump);
      flag = false;
    } else if (humi > THRESHOLD - 0.01) {
      Serial.println("auto pump off");
      pump = 0;
      //      setPump(pump);
      digitalWrite(PUMP_PIN, pump);
      flag = true;
    }
  }

  if (level * 100 < 33) {
    digitalWrite(R_PIN, HIGH);
    digitalWrite(G_PIN, LOW);
    digitalWrite(B_PIN, LOW);
  } else if (level * 100 >= 30 && level * 100 < 66) {

    digitalWrite(R_PIN, LOW);
    digitalWrite(G_PIN, HIGH);
    digitalWrite(B_PIN, LOW);
  } else if (level * 100 >= 60) {
    digitalWrite(R_PIN, LOW);
    digitalWrite(G_PIN, LOW);
    digitalWrite(B_PIN, HIGH);
  }
}









void current(float humi, float level) {
  if (Firebase.ready()) {
    FirebaseJson json;
    json.set("humi", humi);
    json.set("level", level);
    Serial.printf("Set json... %s\n", Firebase.set(fbdo, "/current", json) ? "ok" : fbdo.errorReason().c_str());
  }
}

void setPump(int pump) {
  if (Firebase.ready()) {
    Serial.printf("Set int... %s\n", Firebase.setInt(fbdo, F("/control/watering"), pump) ? "ok" : fbdo.errorReason().c_str());
  }
}
void sendData(float humi, int pump) {
  data(1, 0, humi, pump);
}
int getData(void) {
  return data(0, 1, 0, 0);
}

int data(int set_data, int get_watering, float humi, int pump) {
  static int n = 0;
  static int watering = 0;

  if (Firebase.ready()) {
    if (set_data == 1) {
      Serial.printf("Set timestamp... %s\n", Firebase.setTimestamp(fbdo, "/test/timestamp") ? "ok" : fbdo.errorReason().c_str());
    }
    if (fbdo.httpCode() == FIREBASE_ERROR_HTTP_CODE_OK) {
      if (set_data == 1) {
        int now = fbdo.to<int>();

        Serial.print("TIMESTAMP (Seconds): ");
        Serial.println(now);
        Serial.printf("Get int... %s\n", Firebase.getInt(fbdo, F("/data/n")) ? String(n = fbdo.to<int>()).c_str() : fbdo.errorReason().c_str());

        FirebaseJson json;
        json.set("humi", humi);
        json.set("pump", pump);
        Serial.printf("Set json... %s\n", Firebase.set(fbdo, "/data/" + String(now), json) ? "ok" : fbdo.errorReason().c_str());
        Serial.printf("Set int... %s\n", Firebase.setInt(fbdo, F("/data/n"), ++n) ? "ok" : fbdo.errorReason().c_str());
      }
      if (get_watering == 1) {
        Serial.printf("Get int... %s\n", Firebase.getInt(fbdo, F("/control/watering")) ? String(watering = fbdo.to<int>()).c_str() : fbdo.errorReason().c_str());
        return watering;
      }
    }
  }
}