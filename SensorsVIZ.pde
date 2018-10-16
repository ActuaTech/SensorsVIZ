PFont myFont;

PImage BG;
boolean showBG = true;

// PROJECTION 3D MODEL
WarpSurface surface;
// Canvas canvas;
PGraphics canvas;

// Roadnetwork
Lanes roadnetwork;

// SIMULACIÓ FONS DE VALL
int simWidth = 1000;
int simHeight = 847;
final String bgPath = "orto_small.jpg";
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


void setup() {
    fullScreen(P2D,1);
    smooth();
    
    myFont = createFont("Montserrat-Light", 32);
    
    BG = loadImage(bgPath);
    simWidth = BG.width;
    simHeight = BG.height;
    
    surface = new WarpSurface(this, 900, 300, 10, 5);
    surface.loadConfig();
    canvas = new Canvas(this, simWidth, simHeight, bounds, roi);
    
    roadnetwork = new Lanes("roads.geojson", simWidth, simHeight, bounds);
}


void draw() {
    
    background(255);
    
    canvas.beginDraw();
    canvas.background(255);
    if(showBG)canvas.image(BG, 0, 0);
    roadnetwork.draw(canvas, 1, #c0c0c0);
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
