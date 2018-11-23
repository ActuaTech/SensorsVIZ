PFont myFont;

PImage BG;
boolean showBG = true;

// 3D Model projection
WarpSurface surface;

// Canvas canvas;
Canvas canvas;

// Roadnetwork
Lanes roadnetwork;

// MQTT client
MQTTClient client;

// Sensors facade;
Sensors sensors;


// Canvas and Surface configuration
int simWidth = 1000;
int simHeight = 847;
final String bgPath = "bg/orto_small.jpg";
final PVector[] bounds = new PVector[] {
    new PVector(42.482119, 1.489794),
    new PVector(42.533768, 1.572122)
};
PVector[] roi = new PVector[] {
    new PVector(42.505086, 1.509961),
    new PVector(42.517066, 1.544024),
    new PVector(42.508161, 1.549798),
    new PVector(42.496164, 1.515728)
};


// Roadnetwork configuration
String roadnetworkPath = "roads/roads.geojson";

// MQTT configuration
String broker = "ssl://eu.thethings.network:8883";
String user = "****";
String password = "ttn-account-v2.*******";
String topic = "******";

// Sensors configuration
String sensorsPath = "sensors/sensors.json";


void setup() {
    size(1400, 800, P2D);
    smooth();
    
    myFont = createFont("Montserrat-Light", 32);
    
    BG = loadImage(bgPath);
    simWidth = BG.width;
    simHeight = BG.height;
    
    surface = new WarpSurface(this, 900, 300, 10, 5);
    surface.loadConfig();
    canvas = new Canvas(this, simWidth, simHeight, bounds, roi);
    
    roadnetwork = new Lanes(roadnetworkPath, simWidth, simHeight, bounds);
    
    client = new MQTTClient(broker, user, password);
    client.connect();
    client.setCallback();
    client.subscribe(topic);
    
    sensors = new Sensors(sensorsPath, client, roadnetwork);

}


void draw() {
    
    background(255);

    canvas.beginDraw();
    canvas.background(255);
    if(showBG)canvas.image(BG, 0, 0);
    roadnetwork.draw(canvas, 1, #c0c0c0);
    sensors.draw(canvas, 6, #ff0000);
    canvas.endDraw();
    
    surface.draw((Canvas)canvas);
}


void keyPressed() {

    switch(key) {
        case 'b':
            showBG = !showBG;
            break;
            
        case 'w':
            surface.toggleCalibration();
            break;
    } 
}
