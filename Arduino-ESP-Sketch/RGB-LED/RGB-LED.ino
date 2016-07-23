
/*
  To upload through terminal you can use: curl -F "image=@firmware.bin" esp8266-webupdate.local/update
*/
#include <ArduinoJson.h>
#include <DNSServer.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <ESP8266HTTPUpdateServer.h>
#include <WiFiManager.h>   
#include <ESP8266HTTPClient.h>
#include <FS.h>
#include <Hash.h>
#include <WebSocketsServer.h>

const char* host = "led-controller";

ESP8266WebServer httpServer(80);
ESP8266HTTPUpdateServer httpUpdater;
WebSocketsServer webSocket = WebSocketsServer(81);

const int redPin = 12;
const int greenPin = 13;
const int bluePin = 14;

bool onOff;
File file;
int red, green, blue;
int targetRed, targetGreen, targetBlue;

StaticJsonBuffer<2200> jsonBuffer;

JsonObject& node = jsonBuffer.createObject();
JsonArray& actuatorArr = node.createNestedArray("actuators");
JsonObject& rgbObj = actuatorArr.createNestedObject();

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t lenght) {

    switch(type) {
        case WStype_DISCONNECTED:
            Serial.printf("[%u] Disconnected!\n", num);
            break;
        case WStype_CONNECTED: {
            IPAddress ip = webSocket.remoteIP(num);
            Serial.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);

            // send message to client
            webSocket.sendTXT(num, "Connected");
        }
            break;
        case WStype_TEXT:
            Serial.printf("[%u] get Text: %s\n", num, payload);
            //payload is r=255g=212b=1
            char* payloadRequest = (char *) &payload[0];

            /*sscanf(payloadRequest,
                "%*[^0123456789]%d%*[^0123456789]%d%*[^0123456789]%d",
                &targetRed,
                &targetGreen,
                &targetBlue);
                */
            
            char *str = payloadRequest, *p = str;
            int vals[3];
            int i=0;
            while (*p) { // While there are more characters to process...
                if (isdigit(*p)) { // Upon finding a digit, ...
                    vals[i] = strtol(p, &p, 10); // Read a number, ...
                    i++;
                } else { // Otherwise, move on to the next character.
                    p++;
                }
            }
            targetRed = vals[0];
            targetGreen = vals[1];
            targetBlue = vals[2];
            Serial.printf("%d %d %d", targetRed, targetGreen, targetBlue);
            /*
            if(payload[0] == '#') {
                // we get RGB data

                // decode rgb data
                uint32_t rgb = (uint32_t) strtol((const char *) &payload[1], NULL, 16);

                targetRed = ((rgb >> 16) & 0xFF);
                targetGreen = ((rgb >> 8) & 0xFF);
                targetBlue = ((rgb >> 0) & 0xFF);
            } */

            break;
    }

}
 
void setup(void){

  pinMode(redPin,OUTPUT);
  pinMode(greenPin,OUTPUT);
  pinMode(bluePin,OUTPUT);
  
  analogWrite(12,0);
  analogWrite(13,0);
  analogWrite(14,0);
  
  Serial.begin(115200);

  WiFiManager wifiManager;
  wifiManager.autoConnect("led-controller");

  Serial.println("Connection Successful");

  MDNS.begin(host);
  MDNS.addService("ws", "tcp", 81);

  httpUpdater.setup(&httpServer);
  httpServer.begin();

  httpServer.on("/led", [](){
    
    String r=httpServer.arg(0);
    String g=httpServer.arg(1);
    String b=httpServer.arg(2);

    targetRed =   r.toInt();
    targetGreen = g.toInt();
    targetBlue  = b.toInt();

    httpServer.send(200, "text/plain", "LEDs Updated");
  });

  httpServer.on( "/001", handleColorChange );
  httpServer.on("/ledstatus", [](){
      httpServer.send(200, "text/plain", "r=" + String(red) + ",g=" + String(green) + ",b=" + String(blue) + "\nStatus OK");
  });
  
  MDNS.addService("http", "tcp", 80);
  Serial.printf("HTTPUpdateServer ready! Open http://%s.local/update in your browser\n", host);

  // start webSocket server
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
  Serial.printf("Web Socket ready");
  
}

int timer = 0;

void loop(void){
  httpServer.handleClient();
  webSocket.loop();
  //delay of 1 no longer needed as the check acts as a delay.
  if ((millis() - timer) > 120000){ 
    timer = millis();
  }

  checkUpdateLED(redPin,   targetRed,   &red);
  checkUpdateLED(greenPin, targetGreen, &green);
  checkUpdateLED(bluePin,  targetBlue,  &blue);
  delay(3);
}

void checkUpdateLED(int pin, int target, int *current){
  if(target < *current){
    *current = *current -1;
    updateLED(pin, current);
  }else if (target > *current){
    *current = *current +1;
    updateLED(pin, current);
  }

}

void updateLED(int pin, int *color){
  analogWrite(pin, *color);
}

void handleColorChange(){
    
    String r=httpServer.arg("r");
    String g=httpServer.arg("g");
    String b=httpServer.arg("b");

    targetRed =   r.toInt();
    targetGreen = g.toInt();
    targetBlue  = b.toInt();

    file = SPIFFS.open("data", "w+");
    file.printf("%d %d %d %d", onOff, red, green, blue);
    file.close();

    //server.send(200, "text/plain", "LEDs Updated");
    httpServer.send(200, "text/plain", "");
}

String ipToString(IPAddress ip){
  String s="";
  for (int i=0; i<4; i++)
    s += i  ? "." + String(ip[i]) : String(ip[i]);
  return s;
}

