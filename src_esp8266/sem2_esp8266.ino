// #include <Wifi.h>            // For ESP32

#include <ESP8266WiFi.h>        // For ESP8266
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <SoftwareSerial.h>

// const char* ssid        = "FAI'S EXAM 2.4GHz";
// const char* password    = "Fptacademy@2023";
// const char* token       = "BJE1MAIE60EjA98iTJfv";

const char* ssid        = "Nhat Truong";
const char* password    = "Team_H4T";
const char* token       = "BJE1MAIE60EjA98iTJfv";

const int ledPin = 2;         // Define the LED pin (D4)
const int buttonPin = 0;      // Define the button pin (D3)

const char CMD_OPEN     = 0x4F;
const char CMD_CLOSE    = 0x43;
const char CMD_INVALID  = 0x49;
const char CMD_LOCK     = 0x4C;
const char CMD_UNLOCK   = 0x55;

EspSoftwareSerial::UART mySerial;

WiFiClient espClient;
PubSubClient client(espClient);
char thingsboardServer[] = "demo.thingsboard.io";

void setup() {
    pinMode(ledPin, OUTPUT);
    pinMode(buttonPin, INPUT_PULLUP);
    Serial.begin(9600);
    mySerial.begin(9600, EspSoftwareSerial::SWSERIAL_8O1, 13, 15); // RX: GPIO4(D7), TX: GPIO5(D8) - 8 data bits, odd parity, 1 stop bit
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("WiFi connected");
    client.setServer(thingsboardServer, 1883);
    client.setCallback(callback);
    reconnect();
}

void loop() {
    if (!client.connected()) {
        reconnect();
    }
    client.loop();

    if (mySerial.available() > 0) {
        // Read the incoming byte
        char incomingByte = mySerial.read();
        // Print the received byte as ASCII character
        Serial.print("Receice: ");
        Serial.println(incomingByte);
        sendDoorStatus(incomingByte);
    }

    if (digitalRead(buttonPin) == LOW) {
        digitalWrite(ledPin, !digitalRead(ledPin));
        mySerial.write(digitalRead(ledPin) == HIGH ? CMD_LOCK : CMD_UNLOCK);
        Serial.println("Transmited cmd");
        delay(1000); // Debounce delay
    }
}

void reconnect() {
    while (!client.connected()) {
        Serial.print("Connecting to ThingsBoard...");
        if (client.connect("ESP_sem2", token, NULL)) {
            Serial.println("connected");
            client.subscribe("v1/devices/me/rpc/request/+");
        } else {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}

void callback(char* topic, byte* payload, unsigned int length) {
    StaticJsonDocument<200> doc;
    deserializeJson(doc, payload, length);
    const char* method = doc["method"];
    if (strcmp(method, "setDoorLock") == 0) {
        bool DoorLockStatus = doc["params"];
        if (DoorLockStatus) {
            mySerial.write(CMD_LOCK);
            Serial.println("Transmit: CMD_LOCK ");
        } else {
            mySerial.write(CMD_UNLOCK);
            Serial.println("Transmit: CMD_UNLOCK");
        }
    }
}

void sendDoorStatus(char CMD) {

    StaticJsonDocument<256> doc;
    char buffer[256];
    switch (CMD) {
        case CMD_OPEN:
            doc["uid"] = "2359A629";
            doc["name"] = "NHAT TRUONG";
            doc["status"] = "valid";
            break;
        case CMD_INVALID:
            doc["uid"] = "F3F3A414";
            doc["name"] = "unknown";
            doc["status"] = "INVALID";
            break;
        case CMD_LOCK:
            doc["uid"] = "";
            doc["name"] = "";
            doc["status"] = "LOCKED";
            break;
        case CMD_UNLOCK:
            doc["uid"] = "";
            doc["name"] = "";
            doc["status"] = "unlocked";
            break;
        default:
            break;
    }
    if (CMD == CMD_OPEN || CMD == CMD_INVALID || CMD == CMD_LOCK || CMD == CMD_UNLOCK) {
        size_t n = serializeJson(doc, buffer, sizeof(buffer));
        client.publish("v1/devices/me/telemetry", buffer, n);
        Serial.print("Send: ");
        Serial.println(buffer);
    }


    StaticJsonDocument<256> doc1;
    char buffer1[256];
    switch (CMD) {
        case CMD_OPEN:
            doc1["DoorStatus"] = true;
            break;
        case CMD_CLOSE:
            doc1["DoorStatus"] = false;
            break;
        case CMD_LOCK:
            doc1["DoorLock"] = true;
            break;
        case CMD_UNLOCK:
            doc1["DoorLock"] = false;
            break;
        default:
            break;
    }
    if (CMD == CMD_OPEN || CMD == CMD_CLOSE || CMD == CMD_LOCK || CMD == CMD_UNLOCK) {
        size_t m = serializeJson(doc1, buffer1, sizeof(buffer1));
        client.publish("v1/devices/me/attributes", buffer1, m);
        Serial.print("Send: ");
        Serial.println(buffer1);
    }
}
